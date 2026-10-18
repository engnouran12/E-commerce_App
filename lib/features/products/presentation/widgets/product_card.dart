import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/product_model.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../views/product_details_view.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final discountPercent = product.price > 0
        ? ((product.price - product.discountPrice) / product.price * 100)
              .round()
        : 0;

    final favoritesCubit = getIt<FavoritesCubit>();

    return Material(
      color: AppColors.background,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProductDetailsView(productId: product.id),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(context.spacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: AppRadius.card,
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        product.imageUrl.isEmpty ||
                                product.imageUrl == 'placeholder'
                            ? Container(
                                color: AppColors.surface,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 50,
                                    color: AppColors.border,
                                  ),
                                ),
                              )
                            : Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }

                                      final totalBytes =
                                          loadingProgress.expectedTotalBytes;
                                      final loadedBytes =
                                          loadingProgress.cumulativeBytesLoaded;

                                      return Container(
                                        color: AppColors.surface,
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(
                                          value: totalBytes != null
                                              ? loadedBytes / totalBytes
                                              : null,
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.surface,
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        size: 50,
                                        color: AppColors.border,
                                      ),
                                    ),
                                  );
                                },
                              ),

                        // Favorite button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Material(
                            color: AppColors.background,
                            shape: const CircleBorder(),
                            child: BlocBuilder<FavoritesCubit, FavoritesState>(
                              bloc: favoritesCubit,
                              builder: (context, state) {
                                final isFavorite = state.contains(product.id);

                                return IconButton(
                                  tooltip: isFavorite
                                      ? 'Remove from favorites'
                                      : 'Add to favorites',
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.red
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    favoritesCubit.toggleFavorite(product);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.spacing.sm),
              Text(
                product.name,
                style: context.textStyles.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: context.spacing.xs),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.star, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: context.textStyles.title,
                  ),
                ],
              ),
              SizedBox(height: context.spacing.xs),
              Text(
                '\$${product.discountPrice.toStringAsFixed(2)}',
                style: context.textStyles.price,
              ),
              SizedBox(height: context.spacing.xs),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: context.textStyles.oldPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: context.spacing.xs),
                  Flexible(
                    child: Text(
                      '$discountPercent% Off',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.discount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
