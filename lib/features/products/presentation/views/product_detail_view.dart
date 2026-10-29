import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../view_models/product_detail_cubit.dart';
import '../view_models/product_detail_state.dart';
import '../widgets/add_to_cart_bar.dart';
import '../widgets/color_selector.dart';
import '../widgets/product_detail_status.dart';
import '../widgets/product_image_slider.dart';
import '../widgets/product_price_row.dart';
import '../widgets/product_rating.dart';
import '../widgets/product_review_tile.dart';
import '../widgets/section_title.dart';
import '../widgets/size_selector.dart';
import '../widgets/specification_list.dart';
import 'add_review_view.dart';

class ProductDetailView extends StatelessWidget {
  final int productId;

  const ProductDetailView({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailCubit()..loadProduct(productId),
      child: _ProductDetailBody(productId: productId),
    );
  }
}

class _ProductDetailBody extends StatefulWidget {
  final int productId;

  const _ProductDetailBody({required this.productId});

  @override
  State<_ProductDetailBody> createState() => _ProductDetailBodyState();
}

class _ProductDetailBodyState extends State<_ProductDetailBody> {
  int _selectedImageIndex = 2;

  Future<void> _openAddReviewPage() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProductDetailCubit>(),
          child: AddReviewView(productId: widget.productId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          return switch (state) {
            ProductDetailSuccess(:final product) => SingleChildScrollView(
              padding: EdgeInsets.all(context.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImageSlider(
                    images: product.images,
                    selectedIndex: product.images.isEmpty
                        ? 0
                        : _selectedImageIndex.clamp(
                            0,
                            product.images.length - 1,
                          ),
                    onImageChanged: (index) {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                  ),
                  SizedBox(height: context.spacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: context.textStyles.heading3,
                        ),
                      ),
                      const Icon(
                        Icons.favorite_border,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  SizedBox(height: context.spacing.sm),
                  ProductRating(rating: product.rating, showValue: true),
                  SizedBox(height: context.spacing.md),
                  ProductPriceRow(
                    discountedPrice: product.discountedPrice,
                    originalPrice: product.price,
                    discountPercentage: product.discountPercentage,
                  ),
                  SizedBox(height: context.spacing.lg),
                  SizeSelector(
                    selectedIndex: product.images.isEmpty
                        ? 2
                        : _selectedImageIndex
                              .clamp(0, 5)
                              .clamp(0, product.images.length - 1),
                    onSizeSelected: (index) {
                      setState(() {
                        _selectedImageIndex = product.images.isEmpty
                            ? 0
                            : index.clamp(0, product.images.length - 1);
                      });
                    },
                  ),
                  SizedBox(height: context.spacing.lg),
                  const ColorSelector(),
                  SizedBox(height: context.spacing.lg),
                  SpecificationList(product: product),
                  SizedBox(height: context.spacing.lg),
                  SectionTitle('Review Product (${product.reviews.length})'),
                  SizedBox(height: context.spacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openAddReviewPage,
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Write a Review'),
                    ),
                  ),
                  SizedBox(height: context.spacing.md),
                  if (product.reviews.isEmpty)
                    const Text('No reviews yet.')
                  else
                    ...product.reviews.map(
                      (review) => Padding(
                        padding: EdgeInsets.only(bottom: context.spacing.md),
                        child: ProductReviewTile(review: review),
                      ),
                    ),
                ],
              ),
            ),
            ProductDetailError(:final message) => ProductDetailViewError(
              message: message,
              onRetry: () =>
                  context.read<ProductDetailCubit>().retry(widget.productId),
            ),
            _ => const ProductDetailLoadingView(),
          };
        },
      ),
      bottomNavigationBar: const AddToCartBar(),
    );
  }
}
