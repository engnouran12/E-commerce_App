import '../datasources/product_details_data_source.dart';
import '../models/product_model.dart';

class ProductDetailsRepository {
  final ProductDetailsDataSource dataSource;

  ProductDetailsRepository({required this.dataSource});

  Future<ProductModel> getProductDetails(String id) {
    return dataSource.getProductDetails(id);
  }
}
