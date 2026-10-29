/// Product entity returned by `GET /products`.
class ProductModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final String sku;
  final int weight;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String availabilityStatus;
  final String? returnPolicy;
  final int minimumOrderQuantity;
  final String? thumbnail;
  final List<String> images;
  final List<String> tags;
  final List<ProductReview> reviews;
  final ProductDimensions? dimensions;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    this.brand,
    this.sku = '',
    this.weight = 0,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus = '',
    this.returnPolicy,
    this.minimumOrderQuantity = 0,
    this.thumbnail,
    this.images = const [],
    this.tags = const [],
    this.reviews = const [],
    this.dimensions,
  });

  /// Creates a copy of this product with updated reviews.
  ProductModel copyWith({List<ProductReview>? reviews}) {
    return ProductModel(
      id: id,
      title: title,
      description: description,
      category: category,
      price: price,
      discountPercentage: discountPercentage,
      rating: rating,
      stock: stock,
      brand: brand,
      sku: sku,
      weight: weight,
      warrantyInformation: warrantyInformation,
      shippingInformation: shippingInformation,
      availabilityStatus: availabilityStatus,
      returnPolicy: returnPolicy,
      minimumOrderQuantity: minimumOrderQuantity,
      thumbnail: thumbnail,
      images: images,
      tags: tags,
      reviews: reviews ?? this.reviews,
      dimensions: dimensions,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand']?.toString(),
      sku: json['sku']?.toString() ?? '',
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      warrantyInformation: json['warrantyInformation']?.toString(),
      shippingInformation: json['shippingInformation']?.toString(),
      availabilityStatus: json['availabilityStatus']?.toString() ?? '',
      returnPolicy: json['returnPolicy']?.toString(),
      minimumOrderQuantity:
          (json['minimumOrderQuantity'] as num?)?.toInt() ?? 0,
      thumbnail: json['thumbnail']?.toString(),
      images: _stringList(json['images']),
      tags: _stringList(json['tags']),
      reviews:
          (json['reviews'] as List?)
              ?.whereType<Map>()
              .map((e) => ProductReview.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      dimensions: json['dimensions'] is Map
          ? ProductDimensions.fromJson(
              Map<String, dynamic>.from(json['dimensions'] as Map),
            )
          : null,
    );
  }

  /// Price after applying [discountPercentage].
  double get discountedPrice => price - (price * discountPercentage / 100);

  /// Whether the product currently has stock available.
  bool get inStock => stock > 0;

  /// Whether the product is discounted at all.
  bool get hasDiscount => discountPercentage > 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'discountPercentage': discountPercentage,
    'rating': rating,
    'stock': stock,
    'brand': brand,
    'sku': sku,
    'weight': weight,
    'warrantyInformation': warrantyInformation,
    'shippingInformation': shippingInformation,
    'availabilityStatus': availabilityStatus,
    'returnPolicy': returnPolicy,
    'minimumOrderQuantity': minimumOrderQuantity,
    'thumbnail': thumbnail,
    'images': images,
    'tags': tags,
    'reviews': reviews.map((e) => e.toJson()).toList(),
    'dimensions': dimensions?.toJson(),
  };

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }
}

/// A single customer review embedded in a ProductModel.
class ProductReview {
  final int rating;
  final String comment;
  final DateTime? date;
  final String reviewerName;
  final String reviewerEmail;

  // Base64-encoded image data stored locally.
  final List<String> images;

  const ProductReview({
    required this.rating,
    required this.comment,
    this.date,
    required this.reviewerName,
    required this.reviewerEmail,
    this.images = const [],
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      reviewerName: json['reviewerName']?.toString() ?? '',
      reviewerEmail: json['reviewerEmail']?.toString() ?? '',
      images:
          (json['images'] as List?)?.whereType<String>().toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'rating': rating,
    'comment': comment,
    'date': date?.toIso8601String(),
    'reviewerName': reviewerName,
    'reviewerEmail': reviewerEmail,
    'images': images,
  };
}

/// Physical dimensions of a ProductModel.
class ProductDimensions {
  final double width;
  final double height;
  final double depth;

  const ProductDimensions({
    required this.width,
    required this.height,
    required this.depth,
  });

  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(
      width: (json['width'] as num?)?.toDouble() ?? 0,
      height: (json['height'] as num?)?.toDouble() ?? 0,
      depth: (json['depth'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'width': width,
    'height': height,
    'depth': depth,
  };
}
