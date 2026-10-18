class ProductModel {
  final String id;
  final String name;
  final double price;
  final double discountPrice;
  final double rating;
  final String imageUrl;

  final String description;
  final String category;
  final String brand;
  final double discountPercentage;
  final int stock;
  final String availabilityStatus;
  final List<String> images;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPrice,
    required this.rating,
    required this.imageUrl,
    this.description = '',
    this.category = '',
    this.brand = '',
    this.discountPercentage = 0,
    this.stock = 0,
    this.availabilityStatus = '',
    this.images = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final price = _toDouble(json['price']);
    final discountPercentage = _toDouble(json['discountPercentage']);

    final thumbnail = json['thumbnail']?.toString() ?? '';

    final images =
        (json['images'] as List<dynamic>?)
            ?.map((image) => image.toString())
            .toList() ??
        <String>[];

    return ProductModel(
      id: json['id'].toString(),
      name: json['title']?.toString() ?? '',
      price: price,
      discountPrice: price * (1 - discountPercentage / 100),
      rating: _toDouble(json['rating']),
      imageUrl: thumbnail.isNotEmpty
          ? thumbnail
          : (images.isNotEmpty ? images.first : ''),
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      discountPercentage: discountPercentage,
      stock: _toInt(json['stock']),
      availabilityStatus: json['availabilityStatus']?.toString() ?? '',
      images: images,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
