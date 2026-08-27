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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTimeTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  time,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Tap to edit time",
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 6),
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
          ),
        ),
      ),
    );
  }
}
