import 'package:flutter/material.dart';
import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/domain/models/wallet_transfer.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class TransferCard extends StatelessWidget {
  final WalletTransfer transfer;
  final Wallet? fromWallet;
  final Wallet? toWallet;
  final VoidCallback? onTap;

  const TransferCard({
    super.key,
    required this.transfer,
    this.fromWallet,
    this.toWallet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fromName = fromWallet != null
        ? '${fromWallet!.emoji} ${fromWallet!.name}'
        : 'Wallet';
    final toName = toWallet != null
        ? '${toWallet!.emoji} ${toWallet!.name}'
        : 'Wallet';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.secondary.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.03),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Transfer Icon (Swap arrows) with secondary tint
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title and Subtitle (From -> To)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transfer.note != null && transfer.note!.isNotEmpty
                            ? transfer.note!
                            : "Transfer",
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
                          Flexible(
                            child: Text(
                              "$fromName → $toName",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
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
                            transfer.transferTime,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      transfer.formattedAmount,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Transfer",
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
