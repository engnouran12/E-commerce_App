import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_context.dart';

/// Bold section heading used across the product detail screen.
class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: context.textStyles.heading4);
  }
}
