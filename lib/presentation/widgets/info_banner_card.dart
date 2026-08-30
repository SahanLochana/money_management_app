import 'package:flutter/material.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class InfoBannerCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconBgColor;
  final double iconSize;
  final EdgeInsetsGeometry margin;

  const InfoBannerCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.gradient,
    this.backgroundColor,
    this.borderColor,
    this.iconBgColor,
    this.iconSize = 20,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ??
        (gradient != null
            ? iconColor.withValues(alpha: 0.3)
            : AppColors.surfaceBorder.withValues(alpha: 0.6));

    final effectiveIconBgColor =
        iconBgColor ?? iconColor.withValues(alpha: gradient != null ? 0.2 : 0.12);

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: effectiveBorderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveIconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
