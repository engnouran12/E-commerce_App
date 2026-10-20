import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ratings/data/repositories/ratings_repository.dart';
import '../../../ratings/presentation/view_models/ratings_cubit.dart';
import '../../../ratings/presentation/views/ratings_view.dart';
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

/// Product detail screen. Receives only the product id — the data is loaded
/// through [ProductDetailCubit] following the app's MVVM flow.
class ProductDetailView extends StatelessWidget {
  final int productId;

  const ProductDetailView({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    //named nav, go_router, auto_route, etc. can be used to pass the productId as a parameter to this view.
    return BlocProvider(
      create: (_) => ProductDetailCubit()..loadProduct(productId),
      child: _ProductDetailBody(productId: productId),
    );
  }
}
//
class _ProductDetailBody extends StatelessWidget {
  final int productId;

  const _ProductDetailBody({required this.productId});

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
                  ProductImageSlider(images: product.images),
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
                  const SizeSelector(),
                  SizedBox(height: context.spacing.lg),
                  const ColorSelector(),
                  SizedBox(height: context.spacing.lg),
                  SpecificationList(product: product),
                  SizedBox(height: context.spacing.lg),
                  SectionTitle('Review Product (${product.reviews.length})'),
                  SizedBox(height: context.spacing.md),
                  if (product.reviews.isNotEmpty)
                    ProductReviewTile(review: product.reviews.first),
                  SizedBox(height: context.spacing.md),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => RatingsCubit(
                            repository: getIt<RatingsRepository>(),
                            productId: productId,
                          )..loadRatings(),
                          child: RatingsView(productId: productId),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Ratings & Reviews'),
                  ),
                ],
              ),
            ),
            ProductDetailError(:final message) => ProductDetailViewError(
              message: message,
              onRetry: () =>
                  context.read<ProductDetailCubit>().retry(productId),
            ),
            _ => const ProductDetailLoadingView(),
          };
        },
      ),
      bottomNavigationBar: const AddToCartBar(),
    );
  }
}
