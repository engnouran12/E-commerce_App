import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Read-only star rating display (1-5).
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showValue;
  final TextStyle? valueStyle;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
    this.activeColor,
    this.inactiveColor,
    this.showValue = false,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            if (index < fullStars) {
              return Icon(
                Icons.star,
                color: activeColor ?? AppColors.star,
                size: size,
              );
            } else if (index == fullStars && hasHalfStar) {
              return Icon(
                Icons.star_half,
                color: activeColor ?? AppColors.star,
                size: size,
              );
            } else {
              return Icon(
                Icons.star_border,
                color: inactiveColor ?? AppColors.textSecondary,
                size: size,
              );
            }
          }),
        ),
        if (showValue) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: valueStyle ?? Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
