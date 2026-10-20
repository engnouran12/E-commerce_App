import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_rating_model.dart';
import '../../data/repositories/ratings_repository.dart';
import 'ratings_state.dart';

/// Cubit to manage product ratings (local).
class RatingsCubit extends Cubit<RatingsState> {
  final RatingsRepository repository;
  final int productId;

  RatingsCubit({
    required this.repository,
    required this.productId,
  }) : super(const RatingsInitial());

  Future<void> loadRatings() async {
    emit(const RatingsLoading());
    try {
      final ratings = await repository.getRatings(productId);
      final average = await repository.getAverageRating(productId);
      final count = await repository.getRatingCount(productId);
      emit(RatingsLoaded(
        ratings: ratings,
        averageRating: average,
        ratingCount: count,
      ));
    } catch (e) {
      emit(RatingsError(message: e.toString()));
    }
  }

  Future<void> addRating(ProductRatingModel rating) async {
    try {
      final cached = await _cachePhoto(rating);
      await repository.addRating(cached);
      await loadRatings();
    } catch (e) {
      emit(RatingsError(message: e.toString()));
    }
  }

  Future<void> updateRating(
    ProductRatingModel rating, {
    String? previousPhotoPath,
  }) async {
    try {
      final cached = await _cachePhoto(rating);
      await repository.updateRating(cached);
      if (previousPhotoPath != null &&
          previousPhotoPath != cached.photoPath) {
        await repository.deletePhoto(previousPhotoPath);
      }
      await loadRatings();
    } catch (e) {
      emit(RatingsError(message: e.toString()));
    }
  }

  /// Copies a picked photo into the app-local cache, preserving [photoPath]
  /// when it already points to a cached/kept file.
  Future<ProductRatingModel> _cachePhoto(ProductRatingModel rating) async {
    final path = rating.photoPath;
    if (path == null || path.isEmpty) return rating;
    final cached = await repository.cachePhoto(path);
    return rating.copyWith(photoPath: cached);
  }

  Future<void> deleteRating(int id) async {
    try {
      await repository.deleteRating(id);
      await loadRatings();
    } catch (e) {
      emit(RatingsError(message: e.toString()));
    }
  }
}
