import 'package:e_commerce/core/responsive/responsive_context.dart';
import 'package:e_commerce/core/widgets/app_text_field.dart';
import 'package:e_commerce/features/products/presentation/view_models/products_cubit.dart';
import 'package:e_commerce/features/products/presentation/view_models/products_state.dart' show ProductsState, ProductsSuccess, ProductsEmpty, ProductsError, ProductsLoading, ProductsInitial;
import 'package:e_commerce/features/products/presentation/widgets/products_grid.dart';
import 'package:e_commerce/features/products/presentation/widgets/products_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfferView extends StatelessWidget {
  const OfferView({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the ProductsCubit to the widget tree.
    return BlocProvider(
      create: (_) => ProductsCubit()..loadProducts(),
      child: 
    
      Scaffold(
      body: CustomScrollView(
        slivers: 
        [
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
                            color: Colors.grey),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined,
                            color: Colors.grey),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Products Grid or Status
          BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              return switch (state) {
                ProductsSuccess(:final products) =>
                  ProductsGrid(products: products),
                ProductsEmpty() => const ProductsEmptySliver(),
                ProductsError(:final message) => ProductsErrorSliver(
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
          child: SizedBox(height: 100),
        ),
        ],
            ),
      
        
        
      )


    );
  }
}