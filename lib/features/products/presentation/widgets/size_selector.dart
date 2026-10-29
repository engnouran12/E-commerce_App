import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';
import 'section_title.dart';

/// Circular size options. The API has no sizes, so the list is static
/// (matching the Figma design). Owns the selected index internally.
class SizeSelector extends StatefulWidget {
  const SizeSelector({super.key});

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  static const _sizes = ['6', '6.5', '7', '7.5', '8', '8.5'];

  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Select Size'),
        SizedBox(height: context.spacing.md),
        Wrap(
          spacing: context.spacing.sm,
          children: List.generate(_sizes.length, (i) {
            final selected = i == _selectedIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  _sizes[i],
                  style: context.textStyles.title.copyWith(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
