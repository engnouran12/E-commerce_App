import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';

/// Price row: discounted price + struck-through original + discount percentage.
class ProductPriceRow extends StatelessWidget {
  final double discountedPrice;
  final double originalPrice;
  final double discountPercentage;

  const ProductPriceRow({
    super.key,
    required this.discountedPrice,
    required this.originalPrice,
    required this.discountPercentage,
  });

  bool get _hasDiscount => discountPercentage > 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${discountedPrice.toStringAsFixed(2)}',
          style: context.textStyles.heading3.copyWith(color: AppColors.primary),
        ),
        if (_hasDiscount) ...[
          SizedBox(width: context.spacing.md),
          Text(
            '\$${originalPrice.toStringAsFixed(2)}',
            style: context.textStyles.body.copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),
          SizedBox(width: context.spacing.sm),
          Flexible(
            child: Text(
              '${discountPercentage.toStringAsFixed(0)}% Off',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.title.copyWith(
                color: AppColors.discount,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
