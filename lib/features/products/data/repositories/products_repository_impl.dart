import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/products_api_datasource.dart';
import '../models/product_model.dart';
import 'products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsApiDatasource _datasource;
  final SharedPreferences _preferences;

  ProductsRepositoryImpl({
    required ProductsApiDatasource datasource,
    required SharedPreferences preferences,
  }) : _datasource = datasource,
       _preferences = preferences;

  @override
  Future<List<ProductModel>> getProducts({int limit = 30, int skip = 0}) {
    return _datasource.fetchProducts(limit: limit, skip: skip);
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final cacheKey = 'cached_product_$id';

    try {
      final product = await _datasource.fetchProductById(id);

      await _preferences.setString(cacheKey, jsonEncode(product.toJson()));

      return product;
    } catch (error) {
      final cachedData = _preferences.getString(cacheKey);

      if (cachedData != null) {
        return ProductModel.fromJson(
          jsonDecode(cachedData) as Map<String, dynamic>,
        );
      }

      rethrow;
    }
  }

  @override
  Future<List<ProductReview>> getLocalReviews(int productId) async {
    final key = 'local_reviews_$productId';
    final cachedReviews = _preferences.getString(key);

    if (cachedReviews == null) {
      return [];
    }

    final decoded = jsonDecode(cachedReviews) as List<dynamic>;

    return decoded
        .map(
          (item) =>
              ProductReview.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<void> addLocalReview(int productId, ProductReview review) async {
    final reviews = await getLocalReviews(productId);

    reviews.add(review);

    await _preferences.setString(
      'local_reviews_$productId',
      jsonEncode(reviews.map((review) => review.toJson()).toList()),
    );
  }
}
