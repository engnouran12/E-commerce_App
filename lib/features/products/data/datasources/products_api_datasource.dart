import 'package:e_commerce/core/services/service_locator.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_model.dart';

/// Low-level products API datasource.
///
/// All traffic goes through [DioClient], which attaches the auth header,
/// transparently refreshes tokens, and turns every [DioException] into an
/// [ApiException]. This class only knows how to call the endpoints and parse.
class ProductsApiDatasource {
  //use dio from service locator instead of passing it in constructor, to avoid having to pass it through multiple layers of repositories and cubits. This is a common pattern in Flutter apps using service locators like GetIt.


  
  get _dioClient => getIt<DioClient>();

  ProductsApiDatasource() ;

  /// Fetches a page of products from `GET /products`.
  ///
  /// Throws [ApiException] on any failure.
  Future<List<ProductModel>> fetchProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.products,
      queryParameters: {
        
        'limit': limit,
        'skip': skip,
      },
    );

    final data = response.data;
    final map = data is Map<String, dynamic>
        ? data
        : (data is Map ? Map<String, dynamic>.from(data) : null);

    final rawProducts = map?['products'];
    if (rawProducts is! List) {
      throw const ApiException(message: 'Unexpected response format.');
    }

    return rawProducts
        .whereType<Map>()
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Fetches a single product from `GET /products/{id}`.
  ///
  /// Throws [ApiException] on any failure.
  Future<ProductModel> fetchProductById(int id) async {
    final response = await _dioClient.get(ApiEndpoints.productById(id));

    final data = response.data;
    final map = data is Map<String, dynamic>
        ? data
        : (data is Map ? Map<String, dynamic>.from(data) : null);

    if (map == null) {
      throw const ApiException(message: 'Unexpected response format.');
    }

    return ProductModel.fromJson(map);
  }
  /// Searches products by name from `GET /products/search?q={query}`.
  ///
  /// Throws [ApiException] on any failure.
  /// TODO: change model to result and apilink
  Future<List<ProductModel>> searchProducts({
    required String query,
    int limit = 30,
    int skip = 0,
  }) async {
    final response = await _dioClient.get(
      ApiEndpoints.searchProducts,
      queryParameters: {
        'q': query,
        'limit': limit,
        'skip': skip,
      },
    );

    return _parseProducts(response.data);
  }

  List<ProductModel> _parseProducts(dynamic data) {
    final map = data is Map<String, dynamic>
        ? data
        : (data is Map ? Map<String, dynamic>.from(data) : null);

    final rawProducts = map?['products'];
    if (rawProducts is! List) {
      throw const ApiException(message: 'Unexpected response format.');
    }

    return rawProducts
        .whereType<Map>()
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

//steps
// get result from api 
//save to local db using sql
//ui disply history list
//sync with api 