import 'package:flutter/material.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? contentWidget;
  final String confirmLabel;
  final Color confirmColor;
  final Color confirmTextColor;
  final String cancelLabel;
  final IconData? titleIcon;
  final Color? titleIconColor;
  final Widget? infoBox;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    this.message,
    this.contentWidget,
    this.confirmLabel = "Delete",
    this.confirmColor = AppColors.expense,
    this.confirmTextColor = Colors.white,
    this.cancelLabel = "Cancel",
    this.titleIcon,
    this.titleIconColor,
    this.infoBox,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    String? message,
    Widget? contentWidget,
    String confirmLabel = "Delete",
    Color confirmColor = AppColors.expense,
    Color confirmTextColor = Colors.white,
    String cancelLabel = "Cancel",
    IconData? titleIcon,
    Color? titleIconColor,
    Widget? infoBox,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmActionDialog(
        title: title,
        message: message,
        contentWidget: contentWidget,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        confirmTextColor: confirmTextColor,
        cancelLabel: cancelLabel,
        titleIcon: titleIcon,
        titleIconColor: titleIconColor,
        infoBox: infoBox,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Widget titleWidget;
    if (titleIcon != null) {
      titleWidget = Row(
        children: [
          Icon(
            titleIcon,
            color: titleIconColor ?? confirmColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ],
      );
    } else {
      titleWidget = Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    Widget? bodyWidget;
    if (contentWidget != null) {
      bodyWidget = contentWidget;
    } else if (infoBox != null || message != null) {
      bodyWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message != null)
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          if (infoBox != null) ...[
            if (message != null) const SizedBox(height: 10),
            infoBox!,
          ],
        ],
      );
    }

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      title: titleWidget,
      content: bodyWidget,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelLabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: confirmTextColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            confirmLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
