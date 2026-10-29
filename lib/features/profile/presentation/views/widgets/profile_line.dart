import 'package:e_commerce/core/responsive/responsive_context.dart';
import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class ProfileLine extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ProfileLine({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          SizedBox(width: context.spacing.sm),
          Text(
            title,
            style: context.textStyles.title,
          ),
          SizedBox(width: context.spacing.md),
          Expanded(
            child: Text(
              subtitle,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}
