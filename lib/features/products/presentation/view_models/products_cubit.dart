import 'package:e_commerce/core/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/products_repository.dart';
import 'products_state.dart';

/// Drives the products grid state machine: loading → success / empty / error.
class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(const ProductsInitial());

get _repository => getIt<ProductsRepository>();
    
      

  /// Loads the first page of products.
  Future<void> loadProducts({int limit = 30, int skip = 0}) async {
    //abstract
    //completer
    emit(const ProductsLoading());

    try {
      final products = await _repository.getProducts(limit: limit, skip: skip);

      if (products.isEmpty) {
        emit(const ProductsEmpty());
      } else {
        emit(ProductsSuccess(products));
      }
    } on ApiException catch (error) {
      emit(ProductsError(error.message));
    } catch (_) {
      emit(const ProductsError('Something went wrong. Please try again.'));
    }
  }

  /// Retries the load after a failure.
  Future<void> retry() => loadProducts();
}
