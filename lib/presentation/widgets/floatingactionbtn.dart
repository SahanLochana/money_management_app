import 'package:flutter/material.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class FloatingActionBtn extends StatelessWidget {
  final VoidCallback? onPressed;

  const FloatingActionBtn({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed ?? () {},
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(
              Icons.add_rounded,
              color: Color(0xFF0F0F14),
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
