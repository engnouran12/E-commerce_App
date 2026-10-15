import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/core/services/service_locator.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/products_repository.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit() : super(const ProductDetailsInitial());

  final ProductsRepository _repository = getIt<ProductsRepository>();

  Future<void> loadProduct(int id) async {
    emit(const ProductDetailsLoading());

    try {
      final product = await _repository.getProductById(id);

      emit(ProductDetailsSuccess(product));
    } on ApiException catch (error) {
      emit(ProductDetailsError(error.message));
    } catch (_) {
      emit(
        const ProductDetailsError(
          'Something went wrong. Please try again.',
        ),
      );
    }
  }
}