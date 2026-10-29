import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Centered loading indicator for the product detail screen.
class ProductDetailLoadingView extends StatelessWidget {
  const ProductDetailLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

/// Centered error message with a retry action.
class ProductDetailViewError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ProductDetailViewError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: context.spacing.md),
            Text(
              'Something went wrong',
              style: context.textStyles.heading4,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.xs),
            Text(
              message,
              style: context.textStyles.body,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.lg),
            SizedBox(
              width: 180,
              child: AppButton(text: 'Retry', onPressed: onRetry),
            ),
          ],
        ),
      ),
    );
  }
}
