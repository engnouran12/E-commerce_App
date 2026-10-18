import '../datasources/products_data_source.dart';

class ProductsRepository {
  final ProductsDataSource dataSource;

  ProductsRepository({required this.dataSource});

  Future<ProductsPage> getProducts({required int limit, required int skip}) {
    return dataSource.getProducts(limit: limit, skip: skip);
  }
}
