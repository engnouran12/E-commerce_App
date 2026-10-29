import 'package:e_commerce/core/services/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/products_repository.dart';
import 'product_detail_state.dart';

/// Drives the product detail state machine: loading → success / error.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit() : super(const ProductDetailInitial());

  ProductsRepository get _repository => getIt<ProductsRepository>();

  /// Loads the product and merges API reviews with locally saved reviews.
  Future<void> loadProduct(int productId) async {
    emit(const ProductDetailLoading());

    try {
      final product = await _repository.getProductById(productId);
      final localReviews = await _repository.getLocalReviews(productId);
      debugPrint('Product ID: $productId');
      debugPrint('Saved reviews count: ${localReviews.length}');
      debugPrint('Saved reviews: ${localReviews.map((review) => review.comment).toList()}');

      final updatedProduct = product.copyWith(
        reviews: [...product.reviews, ...localReviews],
      );

      emit(ProductDetailSuccess(updatedProduct));
    } on ApiException catch (error) {
      emit(ProductDetailError(error.message));
    } catch (_) {
      emit(const ProductDetailError('Something went wrong. Please try again.'));
    }
  }

  /// Saves a new review and updates the displayed product immediately.
  Future<void> addReview(int productId, ProductReview review) async {
    final currentState = state;

    if (currentState is! ProductDetailSuccess) {
      return;
    }

    try {
      await _repository.addLocalReview(productId, review);

      final updatedProduct = currentState.product.copyWith(
        reviews: [...currentState.product.reviews, review],
      );

      emit(ProductDetailSuccess(updatedProduct));
    } catch (_) {
      emit(
        const ProductDetailError(
          'Could not save your review. Please try again.',
        ),
      );
    }
  }

  /// Retries loading the product after a failure.
  Future<void> retry(int productId) => loadProduct(productId);
}
// final localReviews = await _repository.getLocalReviews(productId);