
import '../models/product_model.dart';

abstract class ProductsRepository {
  Future<List<ProductModel>> getProducts({
    int limit = 30,
    int skip = 0,
  });

  Future<ProductModel> getProductById(int id);

  Future<List<ProductReview>> getLocalReviews(int productId);

  Future<void> addLocalReview(
      int productId,
      ProductReview review,
      );
}
