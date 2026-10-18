import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/product_details_repository.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final ProductDetailsRepository repository;

  ProductDetailsCubit({required this.repository})
    : super(ProductDetailsInitial());

  Future<void> fetchProductDetails(String id) async {
    emit(ProductDetailsLoading());

    try {
      final product = await repository.getProductDetails(id);
      emit(ProductDetailsSuccess(product));
    } catch (e) {
      emit(
        ProductDetailsError(
          'Failed to load product details. Please try again.',
        ),
      );
    }
  }
}
