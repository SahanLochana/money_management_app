import 'package:flutter/material.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class EmojiAvatar extends StatelessWidget {
  final String emoji;
  final double size;
  final Color containerColor;
  final double fontSize;

  const EmojiAvatar({
    super.key,
    required this.emoji,
    this.size = 44,
    this.containerColor = AppColors.surfaceLight,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: containerColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}
