import 'package:flutter/material.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final double spacing;
  final TextStyle? labelStyle;

  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.spacing = 8.0,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: labelStyle ??
              const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
        ),
        SizedBox(height: spacing),
        child,
      ],
    );
  }
}
