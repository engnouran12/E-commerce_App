import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Interactive star rating input (1-5).
class StarRatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 36,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isActive = starIndex <= rating;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: size, height: size),
          onPressed: () => onRatingChanged(starIndex),
          icon: Icon(
            isActive ? Icons.star : Icons.star_border,
            color: isActive
                ? (activeColor ?? AppColors.star)
                : (inactiveColor ?? AppColors.textSecondary),
            size: size,
          ),
        );
      }),
    );
  }
}
