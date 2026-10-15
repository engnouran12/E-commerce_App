import '../datasources/products_api_datasource.dart';
import '../models/product_model.dart';
import 'products_repository.dart';

/// Default [ProductsRepository] implementation backed by the remote API.




class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsApiDatasource _datasource;

  ProductsRepositoryImpl({required ProductsApiDatasource datasource})
      : _datasource = datasource;

  @override
  Future<List<ProductModel>> getProducts({
    int limit = 30,
    int skip = 0
  }) {
    return _datasource.fetchProducts(
        limit: limit,
        skip: skip
    );
  }

  @override
  Future<ProductModel> getProductById(int id) {
    return _datasource.fetchProductById(id);
  }


}
