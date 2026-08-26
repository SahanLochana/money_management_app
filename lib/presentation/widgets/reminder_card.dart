import 'package:flutter/material.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class ReminderCard extends StatelessWidget {
  final String title;
  final String time;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTimeTap;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.title,
    required this.time,
    required this.value,
    required this.onChanged,
    required this.onTimeTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTimeTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit_outlined,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 10),
              Switch.adaptive(
                value: value,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                inactiveThumbColor: AppColors.textMuted,
                inactiveTrackColor: AppColors.surfaceLight,
                onChanged: onChanged,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.expense,
                  size: 20,
                ),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: "Delete Reminder",
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
