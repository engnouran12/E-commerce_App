import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import 'product_rating.dart';

/// A single customer review: avatar, name, stars, comment and images.
class ProductReviewTile extends StatelessWidget {
  final ProductReview review;

  const ProductReviewTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: AppColors.border,
          child: Text(
            review.reviewerName.isNotEmpty ? review.reviewerName[0] : '?',
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
        SizedBox(width: context.spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review.reviewerName, style: context.textStyles.title),
              ProductRating(rating: review.rating.toDouble(), size: 14),
              SizedBox(height: context.spacing.xs),
              Text(review.comment, style: context.textStyles.body),
              if (review.images.isNotEmpty) ...[
                SizedBox(height: context.spacing.sm),
                SizedBox(
                  height: 76,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.images.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(width: context.spacing.sm),
                    itemBuilder: (context, index) {
                      try {
                        final bytes = base64Decode(review.images[index]);
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            bytes,
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        );
                      } on FormatException {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
