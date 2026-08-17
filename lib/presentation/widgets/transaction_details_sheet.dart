import 'package:flutter/material.dart';
import 'package:money_management_app/domain/models/category.dart';
import 'package:money_management_app/domain/models/expense.dart';
import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/presentation/theme/category_ui_helper.dart';

class TransactionDetailsSheet extends StatelessWidget {
  final Expense expense;
  final Category? category;
  final Wallet? wallet;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TransactionDetailsSheet({
    super.key,
    required this.expense,
    this.category,
    this.wallet,
    this.onDelete,
    this.onEdit,
  });

  static Future<void> show(
    BuildContext context, {
    required Expense expense,
    Category? category,
    Wallet? wallet,
    VoidCallback? onDelete,
    VoidCallback? onEdit,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TransactionDetailsSheet(
        expense: expense,
        category: category,
        wallet: wallet,
        onDelete: onDelete,
        onEdit: onEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catColor = CategoryUIHelper.getColor(category);
    final catIcon = CategoryUIHelper.getIcon(category);
    final categoryName = category?.name ?? 'Expense';
    final walletName = wallet?.name ?? 'Wallet';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1.2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon / Emoji Bubble
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: catColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: category?.emoji != null && category!.emoji.isNotEmpty
                  ? Text(
                      category!.emoji,
                      style: const TextStyle(fontSize: 28),
                    )
                  : Icon(
                      catIcon,
                      color: catColor,
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            expense.note != null && expense.note!.isNotEmpty
                ? expense.note!
                : categoryName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),

          // Large Amount
          Text(
            '-${expense.formattedAmount}',
            style: const TextStyle(
              color: AppColors.expense,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Details List Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.surfaceBorder.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  label: "Category",
                  value: categoryName,
                  icon: catIcon,
                  iconColor: catColor,
                ),
                _buildDivider(),
                _buildDetailRow(
                  label: "Wallet",
                  value: walletName,
                  icon: walletName == 'In Bank'
                      ? Icons.account_balance_rounded
                      : Icons.wallet_rounded,
                  iconColor: AppColors.primary,
                ),
                _buildDivider(),
                _buildDetailRow(
                  label: "Date & Time",
                  value: "${expense.expenseDate} • ${expense.expenseTime}",
                  icon: Icons.access_time_rounded,
                  iconColor: AppColors.textSecondary,
                ),
                if (expense.note != null && expense.note!.isNotEmpty) ...[
                  _buildDivider(),
                  _buildDetailRow(
                    label: "Note",
                    value: expense.note!,
                    icon: Icons.notes_rounded,
                    iconColor: AppColors.warning,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons: Edit & Delete
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    if (onDelete != null) onDelete!();
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 20),
                  label: const Text(
                    "Delete",
                    style: TextStyle(
                      color: AppColors.expense,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.expense.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    if (onEdit != null) onEdit!();
                  },
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF0F0F14), size: 20),
                  label: const Text(
                    "Edit",
                    style: TextStyle(
                      color: Color(0xFF0F0F14),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.surfaceBorder.withValues(alpha: 0.4),
      indent: 16,
      endIndent: 16,
    );
  }
}
