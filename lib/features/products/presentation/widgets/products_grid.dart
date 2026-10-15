import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../data/models/product_model.dart';
import 'product_card.dart';

/// Renders **only** the products grid as a sliver.
///
/// Kept as a standalone widget so the parent screen owns page chrome and
/// state handling, while this widget stays a pure presentational grid.
class ProductsGrid extends StatelessWidget {
  final List<ProductModel> products;

  const ProductsGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
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
            mobile: 0.62,
            tablet: 0.68,
            desktop: 0.72,
          ),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(product: products[index]),
          childCount: products.length,
        ),
      ),
    );
  }
}
