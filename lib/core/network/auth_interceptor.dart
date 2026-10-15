import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'token_storage.dart';

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

    if (requiresAuth) {
      // Pull the token from the local cache (shared_preferences) so the API
      // call always carries the last synced session.
      final accessToken = await tokenStorage.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

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

    // Handle token refresh only on 401, if not already retried, and if auth was required
    if (isUnauthorized && !isRetry && requiresAuth) {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Ask the API for a fresh token via the isolated Dio instance.
          final refreshResponse = await _refreshDio.post(
            refreshEndpoint,
            data: {
              'refreshToken': refreshToken,
              'expiresInMins': 30,
            },
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final data = refreshResponse.data;
            final newAccessToken = (data['accessToken'] ??
                    data['access_token'] ??
                    data['token'])
                ?.toString();
            final newRefreshToken = (data['refreshToken'] ??
                    data['refresh_token'] ??
                    refreshToken)
                ?.toString();

            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              // 1. Sync the refreshed tokens back into the local cache.
              await tokenStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken ?? refreshToken,
              );

              // 2. Notify callback
              onTokenRefreshed?.call(
                newAccessToken,
                newRefreshToken ?? refreshToken,
              );

              // 3. Update the failed request headers and mark it as retried.
              final requestOptions = err.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              requestOptions.extra['isRetry'] = true;

              // 4. Replay the request through the main client so the fresh
              //    token (and all other interceptors) apply.
              final retryResponse =
                  await (_retryDio ?? _refreshDio).fetch(requestOptions);
              return handler.resolve(retryResponse);
            }
          }
        } catch (refreshError) {
          // Refresh token has expired or is invalid
          await tokenStorage.clearTokens();
          onUnauthorized?.call();
          return handler.next(err);
        }
      } else {
        // No refresh token available in storage
        await tokenStorage.clearTokens();
        onUnauthorized?.call();
      }
    }

    return handler.next(err);
  }
}
