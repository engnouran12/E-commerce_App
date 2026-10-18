import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_model.dart';

class ProductsDataSource {
  final DioClient dioClient;

  ProductsDataSource({required this.dioClient});

  Future<ProductsPage> getProducts({
    required int limit,
    required int skip,
  }) async {
    final response = await dioClient.get<dynamic>(
      '${ApiEndpoints.products}?limit=$limit&skip=$skip',
      requiresAuth: false,
    );

    final data = response.data;

    if (data is! Map || data['products'] is! List) {
      throw const FormatException('Invalid products response');
    }

    final products = (data['products'] as List).map((item) {
      if (item is! Map) {
        throw const FormatException('Invalid product item');
      }

      return ProductModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();

    return ProductsPage(products: products, total: _toInt(data['total']));
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ProductsPage {
  final List<ProductModel> products;
  final int total;

  const ProductsPage({required this.products, required this.total});
}
