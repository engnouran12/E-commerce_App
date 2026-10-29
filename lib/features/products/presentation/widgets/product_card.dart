import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/responsive/responsive_context.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  void _openDetail(BuildContext context) {
    Navigator.of(context).pushNamed('/product-details', arguments: product.id);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        product.thumbnail ??
        (product.images.isNotEmpty ? product.images.first : null);

    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: AppRadius.card,
      child: Container(
        padding: EdgeInsets.all(context.spacing.sm),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: AppRadius.card,
                child: _ProductImage(url: imageUrl),
              ),
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              product.title,
              style: context.textStyles.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: context.spacing.xs),
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.star, size: 14),
                SizedBox(width: context.spacing.xs),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: context.textStyles.caption,
                ),
                const Spacer(),
                if (!product.inStock)
                  Text(
                    'Out of stock',
                    style: context.textStyles.caption.copyWith(
                      color: AppColors.discount,
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.spacing.xs),
            Text(
              '\$${product.discountedPrice.toStringAsFixed(2)}',
              style: context.textStyles.price,
            ),
            SizedBox(height: context.spacing.xs),
            if (product.hasDiscount)
              Row(
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: context.textStyles.oldPrice,
                  ),
                  SizedBox(width: context.spacing.xs),
                  Flexible(
                    child: Text(
                      '${product.discountPercentage.toStringAsFixed(0)}% Off',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.discount,
                    ),
                  ),
                ],
              )
            else
              Text(
                product.brand ?? product.category,
                style: context.textStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  //todo: replace with cash network img
  final String? url;

  const _ProductImage({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return const _ImagePlaceholder();

    return Image.network(
      url!,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _ImagePlaceholder(showLoader: true);
      },
      errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final bool showLoader;

  const _ImagePlaceholder({this.showLoader = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: Center(
        child: showLoader
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Icon(Icons.image, size: 50, color: AppColors.border),
      ),
    );
  }
}
