import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_model.dart';

class ProductDetailsDataSource {
  final DioClient dioClient;

  ProductDetailsDataSource({required this.dioClient});

  Future<ProductModel> getProductDetails(String id) async {
    final response = await dioClient.get<dynamic>(
      '${ApiEndpoints.products}/$id',
      requiresAuth: false,
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException('Invalid product details response');
    }

    return ProductModel.fromJson(Map<String, dynamic>.from(data));
  }
}
