import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/responsive/responsive_context.dart';

/// Full-height sliver shown while products are loading.
class ProductsLoadingSliver extends StatelessWidget {
  const ProductsLoadingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

/// Full-height sliver shown when the API returns an empty list.
class ProductsEmptySliver extends StatelessWidget {
  const ProductsEmptySliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: _StatusMessage(
        icon: Icons.inventory_2_outlined,
        title: 'No products yet',
        message: 'There is nothing to show right now. Check back soon.',
      ),
    );
  }
}

/// Full-height sliver shown when loading products fails, with a retry action.
class ProductsErrorSliver extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ProductsErrorSliver({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: _StatusMessage(
        icon: Icons.wifi_off_rounded,
        title: 'Something went wrong',
        message: message,
        action: SizedBox(
          width: 180,
          child: AppButton(text: 'Retry', onPressed: onRetry),
        ),
      ),
    );
  }
}
// img:"hhtp.//fgfg"

//
//clear //
//401

/// Shared centered icon + title + message layout for the status slivers.
class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              child: Icon(icon, size: 40, color: AppColors.textSecondary),
            ),
            SizedBox(height: context.spacing.md),
            Text(
              title,
              style: context.textStyles.heading4,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.xs),
            Text(
              message,
              style: context.textStyles.body,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: context.spacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
