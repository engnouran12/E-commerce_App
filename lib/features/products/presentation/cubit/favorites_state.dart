import '../../data/models/product_model.dart';

class FavoritesState {
  final List<ProductModel> products;

  const FavoritesState({this.products = const []});

  bool contains(String productId) {
    return products.any((product) => product.id == productId);
  }
}
