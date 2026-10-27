import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';

/// Loading placeholder for cart list.
class CartLoadingSliver extends StatelessWidget {
  const CartLoadingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Empty state for cart list.
class CartEmptySliver extends StatelessWidget {
  const CartEmptySliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: context.spacing.md),
          Text(
            'No carts found',
            style: context.textStyles.heading4,
          ),
        ],
      ),
    );
  }
}

/// Error state for cart list.
class CartErrorSliver extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CartErrorSliver({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.discount,
          ),
          SizedBox(height: context.spacing.md),
          Text(
            message,
            style: context.textStyles.body.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.spacing.md),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
