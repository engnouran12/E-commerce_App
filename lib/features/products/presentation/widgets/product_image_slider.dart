import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';

class ProductImageSlider extends StatefulWidget {
  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int>? onImageChanged;

  const ProductImageSlider({
    super.key,
    required this.images,
    this.selectedIndex = 0,
    this.onImageChanged,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    final initialIndex = widget.images.isEmpty
        ? 0
        : widget.selectedIndex.clamp(0, widget.images.length - 1);

    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void didUpdateWidget(covariant ProductImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.images.isNotEmpty &&
        widget.selectedIndex != oldWidget.selectedIndex) {
      final index = widget.selectedIndex.clamp(0, widget.images.length - 1);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(index);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

    final currentIndex = widget.selectedIndex.clamp(
      0,
      widget.images.length - 1,
    );

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: widget.onImageChanged,
            itemBuilder: (context, index) {
              return Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image, size: 64, color: AppColors.border),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: context.spacing.sm),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => Container(
                margin: EdgeInsets.all(context.spacing.xs / 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == currentIndex
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
