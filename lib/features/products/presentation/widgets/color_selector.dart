import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';
import 'section_title.dart';

/// Circular color options. The API has no colors, so the palette is static
/// (matching the Figma design). Owns the selected index internally.
class ColorSelector extends StatefulWidget {
  const ColorSelector({super.key});

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  static const _colors = [
    Color(0xFFFFC833),
    Color(0xFF40BFFF),
    Color(0xFFFB7181),
    Color(0xFF53D1B6),
    Color(0xFF5C61F4),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Select Color'),
        SizedBox(height: context.spacing.md),
        Wrap(
          spacing: context.spacing.sm,
          children: List.generate(_colors.length, (i) {
            final selected = i == _selectedIndex;
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: Container(
                width: 40,
                height: 40,
                padding: EdgeInsets.all(context.spacing.xs),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colors[i],
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
