import 'package:e_commerce/core/services/service_locator.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cart_model.dart';

/// Low-level cart API datasource.
///
/// All traffic goes through [DioClient], which attaches the auth header,
/// transparently refreshes tokens, and turns every [DioException] into an
/// [ApiException].
class CartApiDatasource {
  DioClient get _dioClient => getIt<DioClient>();

  CartApiDatasource();

  /// Fetches all carts from `GET /carts`.
  ///
  /// Throws [ApiException] on any failure.
  Future<CartsResponse> fetchCarts({
    int limit = 50,
    int skip = 0,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.carts,
      queryParameters: {
        'limit': limit,
        'skip': skip,
      },
    );

    final data = response.data;
    final map = data is Map<String, dynamic>
        ? data
        : (data is Map ? Map<String, dynamic>.from(data) : null);

    if (map == null) {
      throw const ApiException(message: 'Unexpected response format.');
    }

    return CartsResponse.fromJson(map);
  }

  /// Fetches a single cart by id from `GET /carts/{id}`.
  Future<CartModel> fetchCartById(int id) async {
    final response = await _dioClient.get('${ApiEndpoints.carts}/$id');

    final data = response.data;
    final map = data is Map<String, dynamic>
        ? data
        : (data is Map ? Map<String, dynamic>.from(data) : null);

    if (map == null) {
      throw const ApiException(message: 'Unexpected response format.');
    }

    return CartModel.fromJson(map);
  }

  /// Fetches carts for a specific user from `GET /carts/user/{userId}`.
  Future<CartsResponse> fetchCartsByUserId(int userId) async {
    final response = await _dioClient.get('${ApiEndpoints.carts}/user/$userId');

    final data = response.data;
    final map = data is Map<String, dynamic>
        ? data
        : (data is Map ? Map<String, dynamic>.from(data) : null);

    if (map == null) {
      throw const ApiException(message: 'Unexpected response format.');
    }

    return CartsResponse.fromJson(map);
  }
}
