import '../models/product_rating_model.dart';

/// Ratings repository contract (local).
abstract class RatingsRepository {
  Future<ProductRatingModel> addRating(ProductRatingModel rating);
  Future<ProductRatingModel> updateRating(ProductRatingModel rating);
  Future<List<ProductRatingModel>> getRatings(int productId);
  Future<double> getAverageRating(int productId);
  Future<int> getRatingCount(int productId);
  Future<void> deleteRating(int id);

  /// Copies a picked photo into the app-local cache and returns its path.
  Future<String> cachePhoto(String sourcePath);

  /// Removes a cached photo file, if it exists.
  Future<void> deletePhoto(String? path);
  //serch rating
  Future<List<ProductRatingModel>> searchRatings(int productId, String query);
}
