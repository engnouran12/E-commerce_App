import '../../data/models/category_model.dart';

/// States emitted by [CategoryCubit] for the categories list.
sealed class CategoryState {
  const CategoryState();
}

/// Initial state before any load has been triggered.
class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

/// A load is in progress.
class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

/// Categories loaded successfully with a non-empty list.
class CategorySuccess extends CategoryState {
  final List<CategoryModel> categories;

  const CategorySuccess(this.categories);
}

/// The request succeeded but returned no categories.
class CategoryEmpty extends CategoryState {
  const CategoryEmpty();
}

/// The request failed. [message] is safe to show to the user.
class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);
}
