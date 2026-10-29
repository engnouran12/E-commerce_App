import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _tag = '[TokenStorage]';

String _maskToken(String? token) {
  if (token == null || token.isEmpty) return 'null';
  if (token.length <= 12) return '*** (len=${token.length})';
  return '${token.substring(0, 6)}...${token.substring(token.length - 4)} '
      '(len=${token.length})';
}

/// Contract for storing and retrieving authentication tokens.
///
/// Implemented by [InMemoryTokenStorage] for session-only usage and by
/// [SharedPrefsTokenStorage] for persistent local caching across app launches.
abstract class TokenStorage {
  /// Returns the current access token, or null if not set.
  Future<String?> getAccessToken();

  /// Returns the current refresh token, or null if not set.
  Future<String?> getRefreshToken();

  /// Persists both access and refresh tokens.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Clears the access token while keeping the refresh token, so an expired
  /// access token can be dropped without losing the ability to refresh.
  Future<void> clearAccessToken();

  /// Clears stored tokens (e.g., on logout or expired refresh token).
  Future<void> clearTokens();

  /// Checks if a valid access token exists.
  Future<bool> hasAccessToken();
}

/// Default in-memory implementation of [TokenStorage].
///
/// Useful for quick testing, session-only tokens, or default client setups.
class InMemoryTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;

  InMemoryTokenStorage({
    this._accessToken,
    this._refreshToken,
  });

  @override
  Future<String?> getAccessToken() async {
    debugPrint('$_tag [memory] read access token: ${_maskToken(_accessToken)}');
    return _accessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    debugPrint(
      '$_tag [memory] read refresh token: ${_maskToken(_refreshToken)}',
    );
    return _refreshToken;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    debugPrint(
      '$_tag [memory] save tokens -> access=${_maskToken(accessToken)}, '
      'refresh=${_maskToken(refreshToken)}',
    );
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearAccessToken() async {
    debugPrint('$_tag [memory] clear access token (refresh token kept)');
    _accessToken = null;
  }

  @override
  Future<void> clearTokens() async {
    debugPrint('$_tag [memory] clear all tokens');
    _accessToken = null;
    _refreshToken = null;
  }

  @override
  Future<bool> hasAccessToken() async {
    final hasToken = _accessToken != null && _accessToken!.isNotEmpty;
    debugPrint('$_tag [memory] hasAccessToken -> $hasToken');
    return hasToken;
  }
}

/// Persistent [TokenStorage] backed by `shared_preferences`.
///
/// Tokens are cached locally so the session survives app restarts. The
/// [AuthInterceptor] keeps this cache in sync with the API by writing refreshed
/// tokens back through this storage.
class SharedPrefsTokenStorage implements TokenStorage {
  static const String accessTokenKey = 'auth_access_token';
  static const String refreshTokenKey = 'auth_refresh_token';

  final SharedPreferences _prefs;

  SharedPrefsTokenStorage(this._prefs);

  @override
  Future<String?> getAccessToken() async {
    final token = _prefs.getString(accessTokenKey);
    debugPrint('$_tag [prefs] read access token: ${_maskToken(token)}');
    return token;
  }

  @override
  Future<String?> getRefreshToken() async {
    final token = _prefs.getString(refreshTokenKey);
    debugPrint('$_tag [prefs] read refresh token: ${_maskToken(token)}');
    return token;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    debugPrint(
      '$_tag [prefs] save tokens -> access=${_maskToken(accessToken)}, '
      'refresh=${_maskToken(refreshToken)}',
    );
    await _prefs.setString(accessTokenKey, accessToken);
    await _prefs.setString(refreshTokenKey, refreshToken);
  }

  @override
  Future<void> clearAccessToken() async {
    debugPrint('$_tag [prefs] clear access token (refresh token kept)');
    await _prefs.remove(accessTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    debugPrint('$_tag [prefs] clear all tokens');
    await _prefs.remove(accessTokenKey);
    await _prefs.remove(refreshTokenKey);
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = _prefs.getString(accessTokenKey);
    final hasToken = token != null && token.isNotEmpty;
    debugPrint('$_tag [prefs] hasAccessToken -> $hasToken');
    return hasToken;
  }
}
