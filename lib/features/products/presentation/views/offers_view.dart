import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';

class OffersView extends StatelessWidget {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = <_OfferItem>[
      const _OfferItem(
        title: 'Summer Collection',
        subtitle: 'Refresh your style with special prices.',
        discount: '30%',
        oldPrice: 120.00,
        newPrice: 84.00,
        icon: Icons.checkroom,
      ),
      const _OfferItem(
        title: 'Tech Accessories',
        subtitle: 'Upgrade your everyday essentials.',
        discount: '20%',
        oldPrice: 75.00,
        newPrice: 60.00,
        icon: Icons.headphones_outlined,
      ),
      const _OfferItem(
        title: 'Bags Collection',
        subtitle: 'Find your next everyday bag.',
        discount: '15%',
        oldPrice: 100.00,
        newPrice: 85.00,
        icon: Icons.shopping_bag_outlined,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Special Offers', style: context.textStyles.heading4),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(context.spacing.md),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.spacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.local_offer_outlined,
                    color: Colors.white,
                    size: 36,
                  ),
                  SizedBox(height: context.spacing.md),
                  Text(
                    'Special Deals For You',
                    style: context.textStyles.heading4.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.spacing.sm),
                  Text(
                    'Discover selected products at lower prices.',
                    style: context.textStyles.body.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.spacing.lg),
            Text('Today\'s Offers', style: context.textStyles.heading4),
            SizedBox(height: context.spacing.md),
            ...offers.map(
              (offer) => Padding(
                padding: EdgeInsets.only(bottom: context.spacing.md),
                child: _OfferCard(offer: offer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferItem {
  final String title;
  final String subtitle;
  final String discount;
  final double oldPrice;
  final double newPrice;
  final IconData icon;

  const _OfferItem({
    required this.title,
    required this.subtitle,
    required this.discount,
    required this.oldPrice,
    required this.newPrice,
    required this.icon,
  });
}

class _OfferCard extends StatelessWidget {
  final _OfferItem offer;

  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(offer.icon, size: 36, color: AppColors.primary),
          ),
          SizedBox(width: context.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: context.textStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.spacing.xs),
                Text(
                  offer.subtitle,
                  style: context.textStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.spacing.sm),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '\$${offer.newPrice.toStringAsFixed(2)}',
                        style: context.textStyles.price,
                      ),
                    ),
                    SizedBox(width: context.spacing.sm),
                    Flexible(
                      child: Text(
                        '\$${offer.oldPrice.toStringAsFixed(2)}',
                        style: context.textStyles.oldPrice,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: context.spacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.sm,
              vertical: context.spacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '-${offer.discount}',
              style: context.textStyles.discount,
            ),
          ),
        ],
      ),
    );
  }
}
