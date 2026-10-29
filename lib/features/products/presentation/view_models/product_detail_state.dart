import '../../data/models/product_model.dart';

/// States emitted by [ProductDetailCubit] for the product detail screen.
sealed class ProductDetailState {
  const ProductDetailState();
}

/// Initial state before any load has been triggered.
class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

/// A load is in progress.
class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

/// The product loaded successfully.
class ProductDetailSuccess extends ProductDetailState {
  final ProductModel product;

  const ProductDetailSuccess(this.product);
}

/// The request failed. [message] is safe to show to the user.
class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);
}
