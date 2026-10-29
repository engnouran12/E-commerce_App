import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../data/models/product_model.dart';
import 'section_title.dart';

/// Product specification rows (brand, category, shipping, warranty, stock)
/// followed by the description.
class SpecificationList extends StatelessWidget {
  final ProductModel product;

  const SpecificationList({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Specification'),
        SizedBox(height: context.spacing.md),
        _SpecRow('Brand', product.brand ?? '-'),
        _SpecRow('Category', product.category),
        _SpecRow('Shipping', product.shippingInformation ?? '-'),
        _SpecRow('Warranty', product.warrantyInformation ?? '-'),
        _SpecRow('In stock', '${product.stock}'),
        SizedBox(height: context.spacing.sm),
        Text(
          product.description,
          style: context.textStyles.body.copyWith(height: 1.5),
        ),
      ],
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textStyles.body),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: context.textStyles.title,
            ),
          ),
        ],
      ),
    );
  }
}
