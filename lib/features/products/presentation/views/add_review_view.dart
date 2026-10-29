import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../view_models/product_detail_cubit.dart';
import '../view_models/product_detail_state.dart';

class AddReviewView extends StatefulWidget {
  final int productId;

  const AddReviewView({super.key, required this.productId});

  @override
  State<AddReviewView> createState() => _AddReviewViewState();
}

class _AddReviewViewState extends State<AddReviewView> {
  final TextEditingController _reviewController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<Uint8List> _selectedImages = [];

  int _selectedRating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 70,
      );

      if (!mounted || images.isEmpty) return;

      final remainingSlots = 3 - _selectedImages.length;

      if (remainingSlots <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can add up to 3 photos.')),
        );
        return;
      }

      final bytesList = <Uint8List>[];

      for (final image in images.take(remainingSlots)) {
        bytesList.add(await image.readAsBytes());
      }

      if (!mounted) return;

      setState(() {
        _selectedImages.addAll(bytesList);
      });
    } catch (error, stackTrace) {
      debugPrint('Image picking error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not select photos. Please try again.'),
        ),
      );
    }
  }

  Future<void> _submitReview() async {
    final comment = _reviewController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write your review first.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final review = ProductReview(
        rating: _selectedRating,
        comment: comment,
        date: DateTime.now(),
        reviewerName: 'You',
        reviewerEmail: '',
        images: _selectedImages.map((image) => base64Encode(image)).toList(),
      );

      await context.read<ProductDetailCubit>().addReview(
        widget.productId,
        review,
      );

      if (!mounted) return;

      if (context.read<ProductDetailCubit>().state is ProductDetailSuccess) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your review. Please try again.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your review. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please write Overall level of satisfaction with your shipping / Delivery Service',
              style: context.textStyles.title,
            ),

            SizedBox(height: context.spacing.sm),

            Row(
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final starRating = index + 1;

                    return IconButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _selectedRating = starRating;
                              });
                            },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      icon: Icon(
                        starRating <= _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                SizedBox(width: context.spacing.sm),
                Text('$_selectedRating/5', style: context.textStyles.body),
              ],
            ),

            SizedBox(height: context.spacing.lg),

            Text('Write Your Review', style: context.textStyles.title),

            SizedBox(height: context.spacing.sm),

            TextField(
              controller: _reviewController,
              enabled: !_isSubmitting,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Write your review here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),

            SizedBox(height: context.spacing.md),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Photos (${_selectedImages.length}/3)',
                    style: context.textStyles.title,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isSubmitting || _selectedImages.length >= 3
                      ? null
                      : _pickImages,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Add Photos'),
                ),
              ],
            ),

            if (_selectedImages.isNotEmpty) ...[
              SizedBox(height: context.spacing.sm),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: context.spacing.sm),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _selectedImages[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _isSubmitting
                                ? null
                                : () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],

            SizedBox(height: context.spacing.xl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
