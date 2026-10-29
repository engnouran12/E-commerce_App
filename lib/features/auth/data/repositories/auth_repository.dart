import '../models/user_model.dart';

/// Clean contract for authentication. The presentation layer depends on this
/// abstraction only, so the local cache / remote API coupling stays in data.
abstract class AuthRepository {
  /// Logs in through the API, then syncs the returned tokens into the local
  /// cache. Returns the authenticated [UserModel].
  Future<UserModel> login({
    required String username,
    required String password,
  });

  /// Restores a session from the locally cached token.
  ///
  /// Returns the authenticated [UserModel] when a valid cached session exists,
  /// otherwise `null`. This is the "local cache first" entry point used at app
  /// startup to decide whether to skip the login screen.
  Future<UserModel?> restoreSession();

  /// Clears the local token cache and any in-memory auth state.
  Future<void> logout();

  /// Whether a cached access token currently exists.
  Future<bool> isLoggedIn();

  /// Returns the cached access token, if any.
  Future<String?> getAccessToken();

  /// Returns the cached refresh token, if any.
  Future<String?> getRefreshToken();
}
