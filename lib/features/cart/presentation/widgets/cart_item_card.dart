import 'package:e_commerce/core/widgets/cash_img.dart';
import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/cart_model.dart';

/// Card widget displaying a single cart with its products.
class CartItemCard extends StatelessWidget {
  final CartModel cart;

  const CartItemCard({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cart #${cart.id}',
                  style: context.textStyles.heading4,
                ),
                Text(
                  'User: ${cart.userId}',
                  style: context.textStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              'Items: ${cart.totalProducts} • Qty: ${cart.totalQuantity}',
              style: context.textStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: context.spacing.md),
            ...cart.products.map(
              (product) => Padding(
                padding: EdgeInsets.only(bottom: context.spacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppNetworkImage(
                        url: product.thumbnail,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      // Image.network(
                      //   product.thumbnail ?? '',
                      //   width: 60,
                      //   height: 60,
                      //   fit: BoxFit.cover,
                      //   errorBuilder: (context, error, stackTrace) =>
                      //       Container(
                      //     width: 60,
                      //     height: 60,
                      //     color: AppColors.border,
                      //     child: const Icon(Icons.image_not_supported),
                      //   ),
                      // ),
                    ),
                    SizedBox(width: context.spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: context.textStyles.body.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: context.spacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${product.discountedTotal.toStringAsFixed(2)}',
                                style: context.textStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'x${product.quantity}',
                                style: context.textStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: context.textStyles.heading4,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${cart.discountedTotal.toStringAsFixed(2)}',
                      style: context.textStyles.heading4.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    if (cart.total != cart.discountedTotal)
                    Text(
                      '\$${cart.total.toStringAsFixed(2)}',
                      style: context.textStyles.body.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textSecondary,
                      ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
