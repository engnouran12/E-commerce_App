import '../datasources/cart_api_datasource.dart';
import '../models/cart_model.dart';
import 'cart_repository.dart';

/// Default [CartRepository] implementation backed by the remote API.
class CartRepositoryImpl implements CartRepository {
  final CartApiDatasource _datasource;

  CartRepositoryImpl({required CartApiDatasource datasource})
    : _datasource = datasource;

  @override
  Future<CartsResponse> getCarts({int limit = 30, int skip = 0}) {
    return _datasource.fetchCarts(limit: limit, skip: skip);
  }

  @override
  Future<CartModel> getCartById(int id) {
    return _datasource.fetchCartById(id);
  }

  @override
  Future<CartsResponse> getCartsByUserId(int userId) {
    return _datasource.fetchCartsByUserId(userId);
  }
}
