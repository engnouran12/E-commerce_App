import '../models/cart_model.dart';

/// Clean contract for carts data.
abstract class CartRepository {
  /// Returns all carts.
  Future<CartsResponse> getCarts({int limit, int skip});

  /// Returns a single cart by its id.
  Future<CartModel> getCartById(int id);

  /// Returns carts for a specific user.
  Future<CartsResponse> getCartsByUserId(int userId);
}
