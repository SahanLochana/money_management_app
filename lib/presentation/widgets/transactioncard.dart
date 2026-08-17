import 'package:flutter/material.dart';
import 'package:money_management_app/domain/models/category.dart';
import 'package:money_management_app/domain/models/expense.dart';
import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/presentation/theme/category_ui_helper.dart';

class TransactionCard extends StatelessWidget {
  final Expense expense;
  final Category? category;
  final Wallet? wallet;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.expense,
    this.category,
    this.wallet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = CategoryUIHelper.getColor(category);
    final catIcon = CategoryUIHelper.getIcon(category);
    final categoryName = category?.name ?? 'Expense';
    final walletName = wallet?.name ?? 'Wallet';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.03),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.surfaceBorder.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Category Icon / Emoji with tinted background
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: category?.emoji != null && category!.emoji.isNotEmpty
                        ? Text(
                            category!.emoji,
                            style: const TextStyle(fontSize: 20),
                          )
                        : Icon(
                            catIcon,
                            color: catColor,
                            size: 22,
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title and Subtitle / Category / Wallet
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.note != null && expense.note!.isNotEmpty
                            ? expense.note!
                            : categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            categoryName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: AppColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Wallet badge (In Hand / In Bank)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              walletName,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: AppColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            expense.expenseTime,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  '-${expense.formattedAmount}',
                  style: const TextStyle(
                    color: AppColors.expense,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
