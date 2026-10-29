

/// Cart item as returned by the carts API.
class CartProduct {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedTotal;
  final String? thumbnail;

  const CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    this.thumbnail,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0,
      thumbnail: json['thumbnail']?.toString(),
    );
  }
}

/// Cart model as returned by `GET /carts`.
class CartModel {
  final int id;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  const CartModel({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    return CartModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      products: rawProducts is List
          ? rawProducts
              .whereType<Map>()
              .map((e) => CartProduct.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      total: (json['total'] as num?)?.toDouble() ?? 0,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Response model for carts list.
class CartsResponse {
  final List<CartModel> carts;
  final int total;
  final int skip;
  final int limit;

  const CartsResponse({
    required this.carts,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory CartsResponse.fromJson(Map<String, dynamic> json) {
    final rawCarts = json['carts'];
    return CartsResponse(
      carts: rawCarts is List
          ? rawCarts
              .whereType<Map>()
              .map((e) => CartModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }
}
