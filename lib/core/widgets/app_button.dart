import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutline;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutline = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 57,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutline ? Colors.transparent : AppColors.primary,
          foregroundColor: isOutline ? AppColors.textSecondary : Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: isOutline ? const BorderSide(color: AppColors.border) : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.sm,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: AppTextStyles.title.copyWith(
                  color: isOutline ? AppColors.textSecondary : Colors.white,
                ),
              ),
      ),
    );
  }
}
