import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../data/models/product_rating_model.dart';
import '../view_models/ratings_cubit.dart';
import '../widgets/star_rating_input.dart';

/// View to add or edit a rating with stars, text comment, and optional photo.
class AddRatingView extends StatefulWidget {
  final int productId;
  final String? reviewerName;
  final String? reviewerEmail;

  /// When provided, the view edits this rating instead of creating a new one.
  final ProductRatingModel? rating;

  const AddRatingView({
    super.key,
    required this.productId,
    this.reviewerName,
    this.reviewerEmail,
    this.rating,
  });

  bool get isEditing => rating != null;

  @override
  State<AddRatingView> createState() => _AddRatingViewState();
}

class _AddRatingViewState extends State<AddRatingView> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  int _rating = 0;
  XFile? _selectedImage;
  String? _existingPhotoPath;

  @override
  void initState() {
    super.initState();
    final rating = widget.rating;
    if (rating != null) {
      _rating = rating.rating;
      _commentController.text = rating.comment;
      _nameController.text = rating.reviewerName;
      _emailController.text = rating.reviewerEmail;
      _existingPhotoPath = rating.photoPath;
    } else {
      _nameController.text = widget.reviewerName ?? '';
      _emailController.text = widget.reviewerEmail ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    final photoPath = _selectedImage?.path ?? _existingPhotoPath;
    final rating = ProductRatingModel(
      id: widget.rating?.id,
      productId: widget.productId,
      rating: _rating,
      comment: _commentController.text.trim(),
      date: widget.rating?.date ?? DateTime.now(),
      reviewerName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'Anonymous',
      reviewerEmail: _emailController.text.trim(),
      photoPath: photoPath,
    );

    final cubit = context.read<RatingsCubit>();
    if (widget.isEditing) {
      cubit.updateRating(rating, previousPhotoPath: widget.rating?.photoPath);
    } else {
      cubit.addRating(rating);
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Rating' : 'Add Rating'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Rating',
                style: context.textStyles.heading4,
              ),
              SizedBox(height: context.spacing.sm),
              StarRatingInput(
                rating: _rating,
                onRatingChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),
              SizedBox(height: context.spacing.md),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: context.spacing.md),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Your Email (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: context.spacing.md),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a comment';
                  }
                  return null;
                },
              ),
              SizedBox(height: context.spacing.md),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo),
                    label: Text(
                      _selectedImage != null || _existingPhotoPath != null
                          ? 'Change Photo'
                          : 'Add Photo',
                    ),
                  ),
                  SizedBox(width: context.spacing.sm),
                  if (_selectedImage != null)
                    Expanded(
                      child: Text(
                        _selectedImage!.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else if (_existingPhotoPath != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => setState(() {
                          _existingPhotoPath = null;
                        }),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove'),
                      ),
                    ),
                ],
              ),
              if (_selectedImage != null || _existingPhotoPath != null) ...[
                SizedBox(height: context.spacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_selectedImage?.path ?? _existingPhotoPath!),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
              SizedBox(height: context.spacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    widget.isEditing ? 'Update Rating' : 'Submit Rating',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
