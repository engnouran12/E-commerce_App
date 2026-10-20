import 'dart:convert';

/// Local product rating entity stored in SQLite.
class ProductRatingModel {
  final int? id;
  final int productId;
  final int rating;
  final String comment;
  final DateTime date;
  final String reviewerName;
  final String reviewerEmail;
  final String? photoPath;

  const ProductRatingModel({
    this.id,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
    this.photoPath,
  });

  ProductRatingModel copyWith({
    int? id,
    int? productId,
    int? rating,
    String? comment,
    DateTime? date,
    String? reviewerName,
    String? reviewerEmail,
    String? photoPath,
  }) {
    return ProductRatingModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerEmail: reviewerEmail ?? this.reviewerEmail,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  factory ProductRatingModel.fromMap(Map<String, dynamic> map) {
    return ProductRatingModel(
      id: map['id'] as int?,
      productId: (map['productId'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      comment: map['comment']?.toString() ?? '',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      reviewerName: map['reviewerName']?.toString() ?? '',
      reviewerEmail: map['reviewerEmail']?.toString() ?? '',
      photoPath: map['photoPath']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
      'reviewerName': reviewerName,
      'reviewerEmail': reviewerEmail,
      'photoPath': photoPath,
    };
  }

  String toJson() => json.encode(toMap());

  factory ProductRatingModel.fromJson(String source) =>
      ProductRatingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;
}
