import '../../data/models/product_rating_model.dart';

/// States emitted by [RatingsCubit] for product ratings.
sealed class RatingsState {
  const RatingsState();
}

/// Initial state before any load has been triggered.
class RatingsInitial extends RatingsState {
  const RatingsInitial();
}

/// A load is in progress.
class RatingsLoading extends RatingsState {
  const RatingsLoading();
}

/// Ratings loaded successfully.
class RatingsLoaded extends RatingsState {
  final List<ProductRatingModel> ratings;
  final double averageRating;
  final int ratingCount;

  const RatingsLoaded({
    required this.ratings,
    required this.averageRating,
    required this.ratingCount,
  });
}

/// Loading or saving ratings failed. [message] is safe to show to the user.
class RatingsError extends RatingsState {
  final String message;

  const RatingsError({required this.message});
}
