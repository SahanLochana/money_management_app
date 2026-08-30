import 'package:flutter/material.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class EmojiPickerGrid extends StatelessWidget {
  final List<String> emojis;
  final String selectedEmoji;
  final ValueChanged<String> onSelected;
  final Color accentColor;

  const EmojiPickerGrid({
    super.key,
    required this.emojis,
    required this.selectedEmoji,
    required this.onSelected,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: emojis.map((e) {
        final isSelected = selectedEmoji == e;
        return GestureDetector(
          onTap: () => onSelected(e),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.2)
                  : AppColors.surfaceLight,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: accentColor, width: 2)
                  : null,
            ),
            child: Text(e, style: const TextStyle(fontSize: 20)),
          ),
        );
      }).toList(),
    );
  }
}
