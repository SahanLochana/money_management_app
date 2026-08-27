import 'package:flutter/material.dart';
import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/domain/models/wallet_transfer.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';

class TransferDetailsSheet extends StatelessWidget {
  final WalletTransfer transfer;
  final Wallet? fromWallet;
  final Wallet? toWallet;
  final VoidCallback? onDelete;

  const TransferDetailsSheet({
    super.key,
    required this.transfer,
    this.fromWallet,
    this.toWallet,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required WalletTransfer transfer,
    Wallet? fromWallet,
    Wallet? toWallet,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TransferDetailsSheet(
        transfer: transfer,
        fromWallet: fromWallet,
        toWallet: toWallet,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fromName = fromWallet != null
        ? '${fromWallet!.emoji} ${fromWallet!.name}'
        : 'Wallet';
    final toName = toWallet != null
        ? '${toWallet!.emoji} ${toWallet!.name}'
        : 'Wallet';

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

          // Icon Bubble
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.secondary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            transfer.note != null && transfer.note!.isNotEmpty
                ? transfer.note!
                : "Wallet Transfer",
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
            transfer.formattedAmount,
            style: const TextStyle(
              color: AppColors.secondary,
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
                  label: "From Wallet",
                  value: fromName,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: AppColors.expense,
                ),
                _buildDivider(),
                _buildDetailRow(
                  label: "To Wallet",
                  value: toName,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: AppColors.primary,
                ),
                _buildDivider(),
                _buildDetailRow(
                  label: "Date & Time",
                  value: "${transfer.transferDate} • ${transfer.transferTime}",
                  icon: Icons.access_time_rounded,
                  iconColor: AppColors.textSecondary,
                ),
                if (transfer.note != null && transfer.note!.isNotEmpty) ...[
                  _buildDivider(),
                  _buildDetailRow(
                    label: "Note",
                    value: transfer.note!,
                    icon: Icons.notes_rounded,
                    iconColor: AppColors.warning,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Button: Delete & Revert
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                if (onDelete != null) onDelete!();
              },
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 20),
              label: const Text(
                "Delete & Revert Transfer",
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
