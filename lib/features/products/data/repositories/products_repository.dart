import '../models/product_model.dart';

/// Clean contract for products data. The presentation layer depends on this
/// abstraction only, so the datasource/API coupling stays in the data layer.
abstract class ProductsRepository {
  /// Returns a page of products.
  Future<List<ProductModel>> getProducts({
    int limit,
    int skip
  });
  Future<ProductModel>getProductById(int id);
}
