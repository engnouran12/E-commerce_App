import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState());

  void toggleFavorite(ProductModel product) {
    final updatedProducts = [...state.products];

    final index = updatedProducts.indexWhere((item) => item.id == product.id);

    if (index >= 0) {
      updatedProducts.removeAt(index);
    } else {
      updatedProducts.add(product);
    }

    emit(FavoritesState(products: updatedProducts));
  }

  bool isFavorite(String productId) {
    return state.contains(productId);
  }

  void removeFavorite(String productId) {
    final updatedProducts = state.products
        .where((product) => product.id != productId)
        .toList();

    emit(FavoritesState(products: updatedProducts));
  }
}
