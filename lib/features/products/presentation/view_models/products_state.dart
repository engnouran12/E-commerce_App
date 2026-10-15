import '../../data/models/product_model.dart';

/// States emitted by [ProductsCubit] for the products grid.
sealed class ProductsState {
  const ProductsState();
}

/// Initial state before any load has been triggered.
class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

/// A load is in progress.
class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

/// Products loaded successfully with a non-empty list.
class ProductsSuccess extends ProductsState {
  final List<ProductModel> products;

  const ProductsSuccess(this.products);
}

/// The request succeeded but returned no products.
class ProductsEmpty extends ProductsState {
  const ProductsEmpty();
}

/// The request failed. [message] is safe to show to the user.
class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);
}
