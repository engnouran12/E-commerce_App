import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../data/models/product_rating_model.dart';
import '../view_models/ratings_cubit.dart';
import '../view_models/ratings_state.dart';
import '../widgets/rating_list_tile.dart';
import '../widgets/star_rating_display.dart';
import 'add_rating_view.dart';

/// View to display all ratings for a product and add new ones.
class RatingsView extends StatelessWidget {
  final int productId;
  final String? reviewerName;
  final String? reviewerEmail;

  const RatingsView({
    super.key,
    required this.productId,
    this.reviewerName,
    this.reviewerEmail,
  });

  Future<void> _openEdit(
    BuildContext context,
    ProductRatingModel rating,
  ) async {
    final cubit = context.read<RatingsCubit>();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddRatingView(
            productId: productId,
            rating: rating,
          ),
        ),
      ),
    );
    if (result == true) {
      cubit.loadRatings();
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProductRatingModel rating,
  ) async {
    final cubit = context.read<RatingsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete rating'),
        content: const Text('Are you sure you want to delete this rating?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && rating.id != null) {
      cubit.deleteRating(rating.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
      ),
      body: BlocBuilder<RatingsCubit, RatingsState>(
        builder: (context, state) {
          if (state is RatingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RatingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.read<RatingsCubit>().loadRatings(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is RatingsLoaded) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(context.spacing.md),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            state.averageRating.toStringAsFixed(1),
                            style: context.textStyles.heading1,
                          ),
                          StarRatingDisplay(
                            rating: state.averageRating,
                            size: 20,
                            showValue: false,
                          ),
                          const SizedBox(height: 4),
                          Text('${state.ratingCount} reviews'),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final cubit = context.read<RatingsCubit>();
                          final result = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: AddRatingView(
                                  productId: productId,
                                  reviewerName: reviewerName,
                                  reviewerEmail: reviewerEmail,
                                ),
                              ),
                            ),
                          );
                          if (result == true) {
                            cubit.loadRatings();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Rating'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: state.ratings.isEmpty
                      ? const Center(
                          child: Text('No ratings yet. Be the first to rate!'),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(context.spacing.md),
                          itemCount: state.ratings.length,
                          itemBuilder: (context, index) {
                            final rating = state.ratings[index];
                            return RatingListTile(
                              rating: rating,
                              onEdit: () => _openEdit(context, rating),
                              onDelete: () => _confirmDelete(context, rating),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
