import 'package:flutter/material.dart';
import 'package:money_management_app/domain/models/category.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class CategoryUIHelper {
  static Color getColor(Category? category) {
    if (category == null) return AppColors.other;
    switch (category.name.toLowerCase()) {
      case 'breakfast':
        return AppColors.breakfast;
      case 'lunch':
        return AppColors.lunch;
      case 'dinner':
        return AppColors.dinner;
      case 'lending':
        return AppColors.lending;
      case 'other':
        return AppColors.other;
      default:
        // Consistent hash color for custom categories
        final hash = category.name.hashCode.abs();
        final colors = [
          const Color(0xFFFF7675),
          const Color(0xFF74B9FF),
          const Color(0xFF55EFC4),
          const Color(0xFFFDCB6E),
          const Color(0xFFA29BFE),
          const Color(0xFFFD79A8),
          const Color(0xFF00CEC9),
        ];
        return colors[hash % colors.length];
    }
  }

  static IconData getIcon(Category? category) {
    if (category == null) return Icons.category_rounded;
    switch (category.name.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast_rounded;
      case 'lunch':
        return Icons.lunch_dining_rounded;
      case 'dinner':
        return Icons.dinner_dining_rounded;
      case 'lending':
        return Icons.handshake_rounded;
      case 'other':
        return Icons.category_rounded;
      default:
        return Icons.local_offer_rounded;
    }
  }
}
