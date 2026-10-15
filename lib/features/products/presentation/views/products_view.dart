import 'package:e_commerce/features/favorites/presentation/views/favorites_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/responsive/responsive_context.dart';
import '../view_models/products_cubit.dart';
import '../view_models/products_state.dart';
import '../widgets/products_grid.dart';
import '../widgets/products_status.dart';
import '../widgets/category_item.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      ProductsCubit()
        ..loadProducts(),
      child: const _ProductsScreen(),
    );
  }
}

class _ProductsScreen extends StatelessWidget {
  const _ProductsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<ProductsCubit>().loadProducts(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Search Bar
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
                            icon: const Icon(Icons.favorite_border,
                                color: AppColors.textSecondary),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return FavoritesView();
                                  },)
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none,
                                color: AppColors.textSecondary),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // Categories Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsive(
                            mobile: 16.0, tablet: 40.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Category', style: context.textStyles.heading4),
                          Flexible(
                            child: Text(
                              'More Category',
                              style: context.textStyles.heading4
                                  .copyWith(color: AppColors.primary),
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
                          horizontal: context.spacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CategoryItem(icon: Icons.checkroom,
                              title: 'Shirt'),
                          SizedBox(width: context.spacing.md),
                          const CategoryItem(icon: Icons.work_outline,
                              title: 'Bag'),
                          SizedBox(width: context.spacing.md),
                          const CategoryItem(
                              icon: Icons.computer, title: 'Equipment'),
                          SizedBox(width: context.spacing.md),
                          const CategoryItem(icon: Icons.watch, title: 'Watch'),
                          SizedBox(width: context.spacing.md),
                          const CategoryItem(
                              icon: Icons.diamond, title: 'Jewelry'),
                        ],
                      ),
                    ),

                    // Products Section Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
                        vertical: context.spacing.md,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Flash Sale', style: context.textStyles
                              .heading4),
                          Flexible(
                            child: Text(
                              'See More',
                              style: context.textStyles.heading4
                                  .copyWith(color: AppColors.primary),
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

              // Product grid reflects the cubit state machine.
              BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  return switch (state) {
                    ProductsSuccess(:final products) =>
                        ProductsGrid(products: products),
                    ProductsEmpty() => const ProductsEmptySliver(),
                    ProductsError(:final message) =>
                        ProductsErrorSliver(
                          message: message,
                          onRetry: () =>
                              context.read<ProductsCubit>().loadProducts(),
                        ),
                    ProductsLoading() || ProductsInitial() =>
                    const ProductsLoadingSliver(),
                  };
                },
              ),

              SliverToBoxAdapter(
                child: SizedBox(height: context.spacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
