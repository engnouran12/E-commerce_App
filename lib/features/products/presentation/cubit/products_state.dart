import '../../data/models/product_model.dart';

enum ProductsStatus { initial, loading, success, error }

class ProductsState {
  final ProductsStatus status;
  final List<ProductModel> products;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  ProductsState copyWith({
    ProductsStatus? status,
    List<ProductModel>? products,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
