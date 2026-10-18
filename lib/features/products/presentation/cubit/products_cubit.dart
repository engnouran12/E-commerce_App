import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/products_repository.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRepository repository;

  static const int pageSize = 20;

  ProductsCubit({required this.repository}) : super(const ProductsState());

  Future<void> fetchProducts() async {
    if (state.status == ProductsStatus.loading) return;

    emit(state.copyWith(status: ProductsStatus.loading, clearError: true));

    try {
      final page = await repository.getProducts(limit: pageSize, skip: 0);

      emit(
        ProductsState(
          status: ProductsStatus.success,
          products: page.products,
          hasMore: page.products.length < page.total,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProductsStatus.error,
          errorMessage: 'Failed to load products. Please try again.',
        ),
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.status != ProductsStatus.success ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final page = await repository.getProducts(
        limit: pageSize,
        skip: state.products.length,
      );

      final updatedProducts = [...state.products, ...page.products];

      emit(
        state.copyWith(
          products: updatedProducts,
          isLoadingMore: false,
          hasMore: updatedProducts.length < page.total,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Could not load more products.',
        ),
      );
    }
  }
}
