import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../widgets/product_card.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorites', style: context.textStyles.heading4),
      ),
      body: SafeArea(
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          bloc: getIt<FavoritesCubit>(),
          builder: (context, state) {
            if (state.products.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(context.spacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: context.spacing.lg),
                      Text(
                        'Your Favorites Are Empty',
                        textAlign: TextAlign.center,
                        style: context.textStyles.heading4,
                      ),
                      SizedBox(height: context.spacing.sm),
                      Text(
                        'Tap the heart on any product to save it here.',
                        textAlign: TextAlign.center,
                        style: context.textStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: context.spacing.lg),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Explore Products'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(context.spacing.md),
                  child: Text(
                    '${state.products.length} Favorite Products',
                    style: context.textStyles.title,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.md,
                    ),
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
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: state.products[index]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
