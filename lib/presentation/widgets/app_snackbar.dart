import 'package:flutter/material.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool isError = false,
    int durationSeconds = 3,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        duration: Duration(seconds: durationSeconds),
        backgroundColor: isError ? const Color(0xFF991B1B) : const Color(0xFF1C2230),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isError
                ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                : AppColors.surfaceBorder.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: isError ? Colors.white : AppColors.primary,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
