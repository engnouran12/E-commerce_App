import '../datasources/ratings_image_store.dart';
import '../datasources/ratings_local_datasource.dart';
import '../models/product_rating_model.dart';
import 'ratings_repository.dart';

/// Ratings repository implementation using local SQLite datasource.
class RatingsRepositoryImpl implements RatingsRepository {
  final RatingsLocalDatasource datasource;
  final RatingsImageStore imageStore;

  const RatingsRepositoryImpl({
    required this.datasource,
    required this.imageStore,
  });

  @override
  Future<ProductRatingModel> addRating(ProductRatingModel rating) async {
    return datasource.insertRating(rating);
  }

  @override
  Future<ProductRatingModel> updateRating(ProductRatingModel rating) async {
    await datasource.updateRating(rating);
    return rating;
  }

  @override
  Future<List<ProductRatingModel>> getRatings(int productId) async {
    return datasource.getRatingsForProduct(productId);
  }

  @override
  Future<double> getAverageRating(int productId) async {
    return datasource.getAverageRatingForProduct(productId);
  }

  @override
  Future<int> getRatingCount(int productId) async {
    return datasource.getRatingCountForProduct(productId);
  }

  @override
  Future<void> deleteRating(int id) async {
    final rating = await datasource.getRatingById(id);
    await datasource.deleteRating(id);
    await imageStore.delete(rating?.photoPath);
  }

  @override
  Future<String> cachePhoto(String sourcePath) {
    return imageStore.save(sourcePath);
  }

  @override
  Future<void> deletePhoto(String? path) {
    return imageStore.delete(path);
  }

  @override
  Future<List<ProductRatingModel>> searchRatings(int productId, String query) {
    // TODO: implement searchRatings
    throw UnimplementedError();
  }
}
