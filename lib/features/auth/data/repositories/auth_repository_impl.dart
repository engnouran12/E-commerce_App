import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/token_storage.dart';
import '../datasource/loginservice.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// Default [AuthRepository] implementation.
///
/// Flow:
/// 1. **Login** — hits the API via [LoginService], then writes the token pair
///    to the local [TokenStorage] cache (API → local sync).
/// 2. **Restore** — reads the cached token, validates it against the API, and
///    transparently refreshes it through the interceptor when expired.
/// 3. **Logout** — wipes the local cache.
class AuthRepositoryImpl implements AuthRepository {
  final LoginService _loginService;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required LoginService loginService,
    required TokenStorage tokenStorage,
  })  : _loginService = loginService,
        _tokenStorage = tokenStorage;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final data = await _loginService.login(
      username: username,
      password: password,
    );

    final accessToken = _readToken(data, 'accessToken', 'access_token', 'token');
    final refreshToken =
        _readToken(data, 'refreshToken', 'refresh_token') ?? accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw const ApiException(
        message: 'Login succeeded but no access token was returned.',
      );
    }

    // Sync API response into the persistent local cache.
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
    );

    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel?> restoreSession() async {
    // Local cache first: no token means no session.
    if (!await _tokenStorage.hasAccessToken()) return null;

    try {
      // Validate/sync against the API. The interceptor refreshes the token
      // on 401 and writes the new pair back to the local cache.
      return await _loginService.fetchCurrentUser();
    } on ApiException {
      // Cached session is no longer usable.
      await _tokenStorage.clearTokens();
      return null;
    }
  }

  @override
  Future<void> logout() => _tokenStorage.clearTokens();

  @override
  Future<bool> isLoggedIn() => _tokenStorage.hasAccessToken();

  @override
  Future<String?> getAccessToken() => _tokenStorage.getAccessToken();

  @override
  Future<String?> getRefreshToken() => _tokenStorage.getRefreshToken();

  String? _readToken(Map<String, dynamic> data, String a, [String? b, String? c]) {
    final value = data[a] ?? (b != null ? data[b] : null) ?? (c != null ? data[c] : null);
    final token = value?.toString();
    return (token == null || token.isEmpty) ? null : token;
  }
}
