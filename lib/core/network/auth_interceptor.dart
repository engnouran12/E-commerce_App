import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_endpoints.dart';
import 'token_storage.dart';

const _tag = '[AuthInterceptor]';

String _maskToken(String? token) {
  if (token == null || token.isEmpty) return 'null';
  if (token.length <= 12) return '*** (len=${token.length})';
  return '${token.substring(0, 6)}...${token.substring(token.length - 4)} '
      '(len=${token.length})';
}

/// Returns true when [token] is a JWT whose `exp` claim is in the past.
///
/// Non-JWT tokens (or tokens without an `exp` claim) are treated as not
/// expired because only the server can validate them.
bool _isExpired(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return false;

  try {
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final json = jsonDecode(payload);
    if (json is! Map) return false;

    final exp = json['exp'];
    if (exp is! num) return false;

    final expiry = DateTime.fromMillisecondsSinceEpoch(
      exp.toInt() * 1000,
      isUtc: true,
    );
    return DateTime.now().toUtc().isAfter(expiry);
  } catch (error) {
    debugPrint('$_tag could not decode token expiry: $error');
    return false;
  }
}

/// Callback invoked when refresh token fails or user is unauthenticated.
typedef OnUnauthorizedCallback = void Function();

/// Callback invoked whenever tokens are refreshed successfully.
typedef OnTokenRefreshedCallback = void Function(
  String newAccessToken,
  String newRefreshToken,
);

/// A [QueuedInterceptor] that automatically manages Authorization headers,
/// injects Bearer tokens, and transparently refreshes expired access tokens
/// when encountering a 401 Unauthorized response.
class AuthInterceptor extends QueuedInterceptor {
  final TokenStorage tokenStorage;
  

  /// Bare Dio (no interceptors) used only to hit the refresh endpoint, so the
  /// refresh call can never recursively trigger this interceptor.
  final Dio _refreshDio;

  /// The main Dio this interceptor is attached to. Used to replay the original
  /// request once a fresh token has been synced to local storage.
  final Dio? _retryDio;

  final String refreshEndpoint;
  final OnUnauthorizedCallback? onUnauthorized;
  final OnTokenRefreshedCallback? onTokenRefreshed;

  AuthInterceptor({
    required this.tokenStorage,
    Dio? refreshDio,
    Dio? retryDio,
    this.refreshEndpoint = ApiEndpoints.refresh,
    this.onUnauthorized,
    this.onTokenRefreshed,
  })  : _refreshDio = refreshDio ?? _defaultRefreshDio(),
        _retryDio = retryDio;

  static Dio _defaultRefreshDio() => Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: ApiEndpoints.connectTimeout,
          receiveTimeout: ApiEndpoints.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if the request explicitly disables authentication
    final bool requiresAuth = options.extra['requiresAuth'] ?? true;
    debugPrint(
      '$_tag onRequest ${options.method} ${options.uri.path} '
      'requiresAuth=$requiresAuth',
    );

    if (!requiresAuth) {
      debugPrint('$_tag auth skipped (public endpoint)');
      return handler.next(options);
    }

    // Pull the token from the local cache (shared_preferences) so the API
    // call always carries the last synced session.
    final accessToken = await tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('$_tag no cached access token to attach');
      return handler.next(options);
    }

    if (_isExpired(accessToken)) {
      // Drop only the expired access token. The refresh token is kept so the
      // 401 flow below can still mint a new pair.
      debugPrint(
        '$_tag cached access token expired (${_maskToken(accessToken)}) '
        '-> clearing it from the local cache',
      );
      await tokenStorage.clearAccessToken();
      return handler.next(options);
    }

    options.headers['Authorization'] = 'Bearer $accessToken';
    debugPrint('$_tag attached cached access token ${_maskToken(accessToken)}');
    return handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final isUnauthorized = response?.statusCode == 401;
    final isRetry = err.requestOptions.extra['isRetry'] == true;
    final requiresAuth = err.requestOptions.extra['requiresAuth'] ?? true;

    debugPrint(
      '$_tag onError ${err.requestOptions.method} '
      '${err.requestOptions.uri.path} status=${response?.statusCode} '
      'isRetry=$isRetry requiresAuth=$requiresAuth',
    );

    // Handle token refresh only on 401, if not already retried, and if auth was required
    if (!isUnauthorized || isRetry || !requiresAuth) {
      return handler.next(err);
    }

    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null ||
        refreshToken.isEmpty ||
        _isExpired(refreshToken)) {
      // No usable refresh token: the locally cached session is dead.
      debugPrint(
        '$_tag refresh token missing/expired (${_maskToken(refreshToken)}) '
        '-> clearing local tokens',
      );
      await tokenStorage.clearTokens();
      onUnauthorized?.call();
      return handler.next(err);
    }

    try {
      // Ask the API for a fresh token via the isolated Dio instance.
      debugPrint(
        '$_tag refreshing access token using cached refresh token '
        '${_maskToken(refreshToken)}',
      );
      //api refreshtoken
      final refreshResponse = await _refreshDio.post(
        refreshEndpoint,
        data: {
          'refreshToken': refreshToken,
          'expiresInMins': 30,
        },
      );

      final data = refreshResponse.data;
      final newAccessToken =
          (data is Map ? data['accessToken'] ?? data['access_token'] ?? data['token'] : null)
              ?.toString();
      final newRefreshToken =
          (data is Map ? data['refreshToken'] ?? data['refresh_token'] : null)
                  ?.toString() ??
              refreshToken;

      if (refreshResponse.statusCode != 200 ||
          newAccessToken == null ||
          newAccessToken.isEmpty) {
        debugPrint(
          '$_tag refresh failed (status=${refreshResponse.statusCode}, '
          'token present=${newAccessToken != null}) -> clearing local tokens',
        );
        await tokenStorage.clearTokens();
        onUnauthorized?.call();
        return handler.next(err);
      }

      // 1. Sync the refreshed tokens back into the local cache.
      await tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // 2. Notify callback
      onTokenRefreshed?.call(newAccessToken, newRefreshToken);

      // 3. Update the failed request headers and mark it as retried.
      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      requestOptions.extra['isRetry'] = true;

      // 4. Replay the request through the main client so the fresh
      //    token (and all other interceptors) apply.
      debugPrint('$_tag retrying original request with refreshed token');
      final retryResponse =
          await (_retryDio ?? _refreshDio).fetch(requestOptions);
      debugPrint(
        '$_tag retry completed status=${retryResponse.statusCode}',
      );
      return handler.resolve(retryResponse);
    } catch (refreshError) {
      // Refresh token has expired or is invalid
      debugPrint('$_tag refresh threw ($refreshError) -> clearing local tokens');
      await tokenStorage.clearTokens();
      onUnauthorized?.call();
      return handler.next(err);
    }
  }
}
