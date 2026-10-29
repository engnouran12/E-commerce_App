import '../datasources/category_api_datasource.dart';
import '../models/category_model.dart';
import 'category_repository.dart';

/// Default [CategoryRepository] implementation backed by the remote API.
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryApiDatasource _datasource;

  CategoryRepositoryImpl(this._datasource);

  @override
  Future<List<CategoryModel>> getCategories() {
    return _datasource.fetchCategories();
  }
}
