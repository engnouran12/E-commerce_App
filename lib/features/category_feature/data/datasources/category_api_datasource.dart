import 'package:e_commerce/core/services/service_locator.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';

/// Low-level categories API datasource.
///
/// All traffic goes through [DioClient], which attaches the auth header and
/// turns every [DioException] into an [ApiException].
class CategoryApiDatasource {
  static const _tag = '[CategoryAPI]';

  DioClient get _dioClient => getIt<DioClient>();

  /// Fetches all categories from `GET /products/category-list`.
  ///
  /// The response may be a list of plain names or category objects. Each
  /// category is enriched with a representative product thumbnail so the list
  /// can render an image. Throws [ApiException] when categories fail.
  Future<List<CategoryModel>> fetchCategories() async {
    debugPrint('$_tag fetchCategories() -> GET ${ApiEndpoints.categories}');

    try {
      final response = await _dioClient.get(
        ApiEndpoints.categories,
        requiresAuth: false,
      );
      debugPrint(
        '$_tag categories response received '
        '(status: ${response.statusCode}, body: ${response.data.runtimeType})',
      );

      final rawCategories = response.data is List
          ? response.data as List
          : null;
      if (rawCategories == null) {
        debugPrint(
          '$_tag unexpected categories format: ${response.data.runtimeType}',
        );
        throw const ApiException(message: 'Unexpected response format.');
      }
      final stringCount = rawCategories.whereType<String>().length;
      final objectCount = rawCategories.whereType<Map>().length;
      debugPrint(
        '$_tag raw categories: ${rawCategories.length} '
        '(strings: $stringCount, objects: $objectCount)',
      );

      final categories = rawCategories
          .map(_toCategory)
          .whereType<CategoryModel>()
          .where(
            (category) => category.slug.isNotEmpty && category.name.isNotEmpty,
          )
          .toList();
      debugPrint('$_tag parsed categories: ${categories.length}');

      final images = await _fetchCategoryImages();
      debugPrint('$_tag category thumbnails resolved: ${images.length}');

      final enriched = categories
          .map((category) => category.copyWith(imageUrl: images[category.slug]))
          .toList();
      debugPrint('$_tag returning ${enriched.length} categories');
      return enriched;
    } on ApiException catch (error, stackTrace) {
      debugPrint('$_tag fetchCategories() failed: ${error.message}');
      debugPrintStack(stackTrace: stackTrace, label: _tag);
      rethrow;
    }
  }

  CategoryModel? _toCategory(dynamic raw) {
    if (raw is Map) {
      return CategoryModel.fromJson(Map<String, dynamic>.from(raw));
    }
    if (raw is String) {
      return CategoryModel.fromName(raw);
    }
    return null;
  }

  /// Maps each category slug to the first available product thumbnail.
  ///
  /// Image enrichment is best-effort: if it fails the categories are still
  /// returned without images.
  Future<Map<String, String>> _fetchCategoryImages() async {
    debugPrint('$_tag fetching category thumbnails via ${ApiEndpoints.products}');

    try {
      final response = await _dioClient.get(
        ApiEndpoints.products,
        queryParameters: {'limit': 0, 'select': 'category,thumbnail'},
        requiresAuth: false,
      );

      final data = response.data;
      final map = data is Map<String, dynamic>
          ? data
          : (data is Map ? Map<String, dynamic>.from(data) : null);

      final rawProducts = map?['products'];
      if (rawProducts is! List) {
        debugPrint(
          '$_tag unexpected products format: ${response.data.runtimeType}',
        );
        return const {};
      }
      debugPrint('$_tag thumbnail source products: ${rawProducts.length}');

      final images = <String, String>{};
      for (final raw in rawProducts.whereType<Map>()) {
        final category = raw['category']?.toString();
        final thumbnail = raw['thumbnail']?.toString();
        if (category == null || category.isEmpty) continue;
        if (thumbnail == null || thumbnail.isEmpty) continue;
        images.putIfAbsent(category, () => thumbnail);
      }
      debugPrint('$_tag thumbnail map built: ${images.length} categories');
      return images;
    } on ApiException catch (error) {
      debugPrint('$_tag thumbnail enrichment skipped: ${error.message}');
      return const {};
    }
  }
}
