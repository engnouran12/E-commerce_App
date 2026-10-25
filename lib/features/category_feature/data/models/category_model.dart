/// Category entity returned by the categories endpoints.
///
/// `GET /products/category-list` returns plain names (e.g. `home-decoration`),
/// while `GET /products/categories` returns objects with slug, name and url.
/// [imageUrl] is enriched from a representative product thumbnail by the
/// datasource.
class CategoryModel {
  final String slug;
  final String name;
  final String url;
  final String? imageUrl;

  const CategoryModel({
    required this.slug,
    required this.name,
    this.url = '',
    this.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  /// Builds a category from a plain slug such as `home-decoration`.
  factory CategoryModel.fromName(String value) {
    final slug = value.trim();
    return CategoryModel(slug: slug, name: _titleCase(slug));
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return '';
    return value
        .split('-')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  CategoryModel copyWith({String? imageUrl}) {
    return CategoryModel(
      slug: slug,
      name: name,
      url: url,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'name': name,
    'url': url,
    'imageUrl': imageUrl,
  };
}
