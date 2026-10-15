import 'package:shared_preferences/shared_preferences.dart';

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
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }

  @override
  Future<bool> hasAccessToken() async =>
      _accessToken != null && _accessToken!.isNotEmpty;
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
  Future<String?> getAccessToken() async => _prefs.getString(accessTokenKey);

  @override
  Future<String?> getRefreshToken() async => _prefs.getString(refreshTokenKey);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(accessTokenKey, accessToken);
    await _prefs.setString(refreshTokenKey, refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await _prefs.remove(accessTokenKey);
    await _prefs.remove(refreshTokenKey);
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = _prefs.getString(accessTokenKey);
    return token != null && token.isNotEmpty;
  }
}
