import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';

/// Reusable star-rating row: 5 stars + optional numeric value.
///
/// Reused by the product header and the review tile.
class ProductRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showValue;

  const ProductRating({
    super.key,
    required this.rating,
    this.size = 18,
    this.showValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final rounded = rating.round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          5,
          (i) => Icon(
            Icons.star,
            size: size,
            color: i < rounded ? AppColors.star : AppColors.border,
          ),
        ),
        if (showValue) ...[
          SizedBox(width: context.spacing.xs),
          Text(rating.toStringAsFixed(1), style: context.textStyles.body),
        ],
      ],
    );
  }
}
