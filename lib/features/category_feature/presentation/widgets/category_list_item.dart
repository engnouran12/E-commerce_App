import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cash_img.dart';
import '../../data/models/category_model.dart';

/// A single category row with its representative image and title.
class CategoryListItem extends StatelessWidget {
  final CategoryModel category;

  const CategoryListItem({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final imageSize = context.responsive(
      mobile: 64.0,
      tablet: 76.0,
      desktop: 88.0,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.all(context.spacing.sm),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.card,
            child: AppNetworkImage(
              url: category.imageUrl,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: context.spacing.md),
          Expanded(
            child: Text(
              category.name,
              style: context.textStyles.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
