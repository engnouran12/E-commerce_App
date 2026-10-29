import '../models/category_model.dart';

/// Clean contract for category data. The presentation layer depends on this
/// abstraction only.
abstract class CategoryRepository {
  /// Returns all product categories.
  Future<List<CategoryModel>> getCategories();
}
