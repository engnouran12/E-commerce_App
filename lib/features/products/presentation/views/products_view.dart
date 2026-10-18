import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'favorites_view.dart';
import 'offers_view.dart';
import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../widgets/category_item.dart';
import '../widgets/product_card.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductsCubit>()..fetchProducts(),
      child: const _ProductsContent(),
    );
  }
}

class _ProductsContent extends StatefulWidget {
  const _ProductsContent();

  @override
  State<_ProductsContent> createState() => _ProductsContentState();
}

class _ProductsContentState extends State<_ProductsContent> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<ProductsCubit>().fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar and actions
                      Padding(
                        padding: EdgeInsets.all(context.spacing.md),
                        child: Row(
                          children: [
                            const Expanded(
                              child: AppTextField(
                                hintText: 'Search Product',
                                prefixIcon: Icons.search,
                              ),
                            ),
                            SizedBox(width: context.spacing.md),
                            IconButton(
                              icon: const Icon(
                                Icons.favorite_border,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const FavoritesView(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const OffersView(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Categories
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsive(
                            mobile: 16.0,
                            tablet: 40.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Category',
                              style: context.textStyles.heading4,
                            ),
                            Flexible(
                              child: Text(
                                'More Category',
                                style: context.textStyles.heading4.copyWith(
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.spacing.md),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CategoryItem(
                              icon: Icons.checkroom,
                              title: 'Shirt',
                            ),
                            SizedBox(width: context.spacing.md),
                            const CategoryItem(
                              icon: Icons.work_outline,
                              title: 'Bag',
                            ),
                            SizedBox(width: context.spacing.md),
                            const CategoryItem(
                              icon: Icons.computer,
                              title: 'Equipment',
                            ),
                            SizedBox(width: context.spacing.md),
                            const CategoryItem(
                              icon: Icons.watch,
                              title: 'Watch',
                            ),
                            SizedBox(width: context.spacing.md),
                            const CategoryItem(
                              icon: Icons.diamond,
                              title: 'Jewelry',
                            ),
                          ],
                        ),
                      ),

                      // Products heading
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                          vertical: context.spacing.md,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Flash Sale',
                              style: context.textStyles.heading4,
                            ),
                            Flexible(
                              child: Text(
                                'See More',
                                style: context.textStyles.heading4.copyWith(
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Initial loading
                if (state.status == ProductsStatus.loading &&
                    state.products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                // Initial loading error
                else if (state.status == ProductsStatus.error &&
                    state.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(context.spacing.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.wifi_off,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: context.spacing.md),
                            Text(
                              state.errorMessage ?? 'Failed to load products.',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.spacing.md),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ProductsCubit>().fetchProducts();
                              },
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                // Product grid
                else ...[
                  if (state.products.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.responsive(
                            mobile: 2,
                            tablet: 4,
                            desktop: 6,
                          ),
                          mainAxisSpacing: context.spacing.md,
                          crossAxisSpacing: context.spacing.md,
                          childAspectRatio: context.responsive(
                            mobile: 0.65,
                            tablet: 0.7,
                            desktop: 0.75,
                          ),
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return ProductCard(product: state.products[index]);
                        }, childCount: state.products.length),
                      ),
                    ),

                  // Loading more products
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),

                  // Pagination error
                  if (state.errorMessage != null && state.products.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(context.spacing.md),
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              context.read<ProductsCubit>().fetchNextPage();
                            },
                            child: const Text(
                              'Could not load more products. Tap to retry.',
                            ),
                          ),
                        ),
                      ),
                    ),
                ],

                SliverToBoxAdapter(
                  child: SizedBox(height: context.spacing.xxl),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
