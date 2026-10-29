import '../models/product_model.dart';

/// Clean contract for products data. The presentation layer depends on this
/// abstraction only, so the datasource/API coupling stays in the data layer.
abstract class ProductsRepository {
  /// Returns a page of products.
  Future<List<ProductModel>> getProducts({int limit, int skip});

  /// Returns a single product by its id.
  Future<ProductModel> getProductById(int id);

  /// Returns products whose title matches [query].
  Future<List<ProductModel>> searchProducts({
    required String query,
    int limit,
    int skip,
  });
}
