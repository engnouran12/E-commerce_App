import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/product_rating_model.dart';
import 'star_rating_display.dart';

/// Displays a single rating item with optional edit/delete actions.
class RatingListTile extends StatelessWidget {
  final ProductRatingModel rating;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RatingListTile({
    super.key,
    required this.rating,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    rating.reviewerName.isNotEmpty
                        ? rating.reviewerName
                        : 'Anonymous',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                StarRatingDisplay(rating: rating.rating.toDouble(), size: 18),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit',
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'Delete',
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              rating.date.toLocal().toString().split(' ').first,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (rating.comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(rating.comment),
            ],
            if (rating.hasPhoto) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(rating.photoPath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
