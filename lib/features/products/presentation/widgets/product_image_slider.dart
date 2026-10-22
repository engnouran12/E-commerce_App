import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-width image slider with page indicators.
///
/// Owns the current page index internally — the parent only supplies images.
class ProductImageSlider extends StatefulWidget {
  final List<String> images;

  const ProductImageSlider({super.key, required this.images});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: Icon(Icons.image, size: 64, color: AppColors.border),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, i) => Image.network(
              widget.images[i],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.image, size: 64, color: AppColors.border),
              ),
            ),
          ),
        ),
        SizedBox(height: context.spacing.sm),
        //replace with listview.vuilder
        SizedBox(
          height: 40,
          child: ListView.builder(
            itemCount: widget.images.length,

            scrollDirection: Axis.horizontal,
            itemBuilder: (context, lenght) => Container(
              margin: EdgeInsets.all(context.spacing.xs / 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lenght == _currentIndex
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
          ),
        ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children:
        //    List.generate(
        //     widget.images.length,
        //     (i) => Container(
        //       margin: EdgeInsets.all(context.spacing.xs / 2),
        //       width: 6,
        //       height: 6,
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         color: i == _currentIndex
        //             ? AppColors.primary
        //             : AppColors.border,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
