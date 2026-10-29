import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../view_models/cart_cubit.dart';
import '../view_models/cart_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_status.dart';

/// Cart screen displaying all carts from the API.
class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit()..loadCarts(),
      child: const _CartScreen(),
    );
  }
}

class _CartScreen extends StatelessWidget {
  const _CartScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<CartCubit>().loadCarts(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BlocBuilder<CartCubit, CartState>(
              
              builder: (context, state) {
                print('CartState: $state'); // Debug print to check the state
                return switch (state) {
                  CartSuccess(:final carts) => SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => CartItemCard(cart: carts[index]),
                        childCount: carts.length,
                      ),
                    ),
                  CartEmpty() => const CartEmptySliver(),
                  CartError(:final message) => CartErrorSliver(
                      message: message,
                      onRetry: () => context.read<CartCubit>().loadCarts(),
                    ),
                  CartLoading() ||
                  CartInitial() =>
                    const CartLoadingSliver(),
                };
              },
            ),
            SliverToBoxAdapter(child: SizedBox(height: context.spacing.xxl)),
          ],
        ),
      ),
    );
  }
}
