import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/responsive/responsive_context.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';

class ProductDetailsView extends StatelessWidget {
  final String productId;

  const ProductDetailsView({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProductDetailsCubit>()..fetchProductDetails(productId),
      child: _ProductDetailsContent(productId: productId),
    );
  }
}

class _ProductDetailsContent extends StatelessWidget {
  final String productId;

  const _ProductDetailsContent({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Product Details'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          if (state is ProductDetailsLoading ||
              state is ProductDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductDetailsCubit>().fetchProductDetails(
                          productId,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProductDetailsSuccess) {
            final product = state.product;
            final hasDiscount = product.discountPercentage > 0;

            return SingleChildScrollView(
              padding: EdgeInsets.all(context.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: product.imageUrl.isEmpty
                          ? const Icon(
                              Icons.image_not_supported_outlined,
                              size: 72,
                            )
                          : Image.network(
                              product.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 72,
                                ),
                              ),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(product.name, style: context.textStyles.heading4),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 22,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      if (product.brand.isNotEmpty)
                        Expanded(
                          child: Text(
                            product.brand,
                            style: TextStyle(color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${product.discountPrice.toStringAsFixed(2)}',
                        style: context.textStyles.price.copyWith(fontSize: 26),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 12),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: context.textStyles.oldPrice,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                          style: context.textStyles.discount,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Description', style: context.textStyles.heading4),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty
                        ? 'No description available.'
                        : product.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _InfoRow(
                    label: 'Category',
                    value: product.category.isEmpty
                        ? 'Not available'
                        : product.category,
                  ),
                  _InfoRow(
                    label: 'Availability',
                    value: product.availabilityStatus.isEmpty
                        ? (product.stock > 0 ? 'In stock' : 'Out of stock')
                        : product.availabilityStatus,
                  ),
                  _InfoRow(label: 'Stock', value: product.stock.toString()),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: product.stock <= 0
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Cart integration will be added next.',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
