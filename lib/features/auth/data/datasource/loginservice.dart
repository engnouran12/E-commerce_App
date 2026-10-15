import 'package:e_commerce/core/services/service_locator.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

/// Low-level auth API datasource.
///
/// All traffic goes through [DioClient], which attaches the auth header,
/// transparently refreshes tokens, and turns every [DioException] into an
/// [ApiException]. This class only knows how to call the endpoints.
class LoginService {
get _dioClient => getIt<DioClient>();
  LoginService();

  /// Authenticates with the API and returns the raw JSON payload.
  ///
  /// Throws [ApiException] on any failure. Tokens are intentionally *not*
  /// persisted here — the repository owns the local cache / API sync.
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
      },
      requiresAuth: false,
    );

    return _asJsonMap(response.data);
  }

  /// Fetches the profile of the currently authenticated user.
  Future<UserModel> fetchCurrentUser() async {
    final response = await _dioClient.get(ApiEndpoints.me);
    return UserModel.fromJson(_asJsonMap(response.data));
  }

  /// Exchanges a refresh token for a new token pair.
  ///
  /// Exposed for repositories that need to refresh eagerly. The
  /// [AuthInterceptor] handles lazy/automatic refresh on `401` responses.
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      ApiEndpoints.refresh,
      data: {
        'refreshToken': refreshToken,
        'expiresInMins': 30,
      },
      requiresAuth: false,
    );

    return _asJsonMap(response.data);
  }

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException(message: 'Unexpected response format.');
  }
}
