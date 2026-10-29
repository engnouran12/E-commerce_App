import 'package:e_commerce/core/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/products_repository.dart';
import 'product_detail_state.dart';

/// Drives the product detail state machine: loading → success / error.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit() : super(const ProductDetailInitial());

  get _repository => getIt<ProductsRepository>();

  /// Loads the product with the given [productId].
  Future<void> loadProduct(int productId) async {
    emit(const ProductDetailLoading());

    try {
      final product = await _repository.getProductById(productId);
      emit(ProductDetailSuccess(product));
    } on ApiException catch (error) {
      emit(ProductDetailError(error.message));
    } catch (_) {
      emit(const ProductDetailError('Something went wrong. Please try again.'));
    }
  }

  /// Retries the load after a failure.
  Future<void> retry(int productId) => loadProduct(productId);
}
