import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/widgets/app_button.dart';

/// Bottom bar with the primary "Add To Cart" action, reused across the
/// product detail screen via `Scaffold.bottomNavigationBar`.
class AddToCartBar extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddToCartBar({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.md),
        child: AppButton(
          text: 'Add To Cart',
          onPressed:
              onPressed ??
              () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Added to cart')));
              },
        ),
      ),
    );
  }
}
