import '../../data/models/cart_model.dart';

/// Cart state machine following the app's pattern.
sealed class CartState {
  const CartState();
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartSuccess extends CartState {
  final List<CartModel> carts;

  const CartSuccess({required this.carts});
}

class CartEmpty extends CartState {
  const CartEmpty();
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);
}
