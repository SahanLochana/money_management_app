import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management_app/domain/models/expense.dart';
import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/domain/models/wallet_transfer.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_bloc.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_event.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_state.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_event.dart';
import 'package:money_management_app/presentation/screens/add_transaction_page.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/presentation/widgets/app_snackbar.dart';
import 'package:money_management_app/presentation/widgets/transaction_details_sheet.dart';
import 'package:money_management_app/presentation/widgets/transactioncard.dart';
import 'package:money_management_app/presentation/widgets/transfer_card.dart';
import 'package:money_management_app/presentation/widgets/transfer_details_sheet.dart';

sealed class HistoryActivityItem {
  String get time;
}

class HistoryExpenseItem extends HistoryActivityItem {
  final Expense expense;
  HistoryExpenseItem(this.expense);
  @override
  String get time => expense.expenseTime;
}

class HistoryTransferItem extends HistoryActivityItem {
  final WalletTransfer transfer;
  HistoryTransferItem(this.transfer);
  @override
  String get time => transfer.transferTime;
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';

  void _deleteExpense(Expense exp) {
    if (exp.id == null) return;
    final expId = exp.id!;
    context.read<ExpenseBloc>().add(DeleteExpenseEvent(expId));

    AppSnackBar.show(
      context,
      message: "Deleted expense (${exp.formattedAmount}) • Restored to wallet",
      actionLabel: "Undo",
      durationSeconds: 3,
      onAction: () {
        context.read<ExpenseBloc>().add(RestoreExpenseEvent(expId));
      },
    );
  }

  void _deleteTransfer(WalletTransfer transfer, Wallet? fromWallet) {
    if (transfer.id == null) return;
    final transferId = transfer.id!;
    context.read<WalletBloc>().add(DeleteWalletTransferEvent(transferId));
    context.read<ExpenseBloc>().add(const LoadExpenses());

    AppSnackBar.show(
      context,
      message: "Reverted transfer (${transfer.formattedAmount}) • Returned to ${fromWallet?.name ?? 'wallet'}",
      actionLabel: "Undo",
      durationSeconds: 3,
      onAction: () {
        context.read<WalletBloc>().add(RestoreWalletTransferEvent(transferId));
        context.read<ExpenseBloc>().add(const LoadExpenses());
      },
    );
  }

  Future<bool> _confirmDeleteExpenseDialog(Expense exp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Text(
          "Delete Expense?",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this expense (${exp.formattedAmount})? This will restore ${exp.formattedAmount} back to your wallet balance.",
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<bool> _confirmDeleteTransferDialog(WalletTransfer transfer, Wallet? fromWallet, Wallet? toWallet) async {
    final fromName = fromWallet?.name ?? "source wallet";
    final toName = toWallet?.name ?? "destination wallet";

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Text(
          "Revert Transfer?",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "Are you sure you want to revert this transfer (${transfer.formattedAmount})? This will return ${transfer.formattedAmount} to $fromName and deduct it from $toName.",
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Revert",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _editExpense(Expense exp) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AddTransactionPage(expenseToEdit: exp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Text(
          "History",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ExpenseError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.expense),
              ),
            );
          }

          Map<String, List<HistoryActivityItem>> grouped = {};

          if (state is ExpenseLoaded) {
            final selectedWallet = _selectedFilter == 'All'
                ? null
                : state.wallets.where((w) => w.name == _selectedFilter).firstOrNull;

            final allDates = <String>{
              ...state.groupedExpenses.keys,
              ...state.groupedTransfers.keys,
            }.toList()
              ..sort((a, b) => b.compareTo(a));

            for (final date in allDates) {
              final expensesForDate = state.groupedExpenses[date] ?? [];
              final transfersForDate = state.groupedTransfers[date] ?? [];

              final List<HistoryActivityItem> itemsForDate = [];

              for (final exp in expensesForDate) {
                if (selectedWallet == null || exp.walletId == selectedWallet.id) {
                  itemsForDate.add(HistoryExpenseItem(exp));
                }
              }

              for (final transfer in transfersForDate) {
                if (selectedWallet == null ||
                    transfer.fromWalletId == selectedWallet.id ||
                    transfer.toWalletId == selectedWallet.id) {
                  itemsForDate.add(HistoryTransferItem(transfer));
                }
              }

              if (itemsForDate.isNotEmpty) {
                itemsForDate.sort((a, b) => b.time.compareTo(a.time));
                grouped[date] = itemsForDate;
              }
            }
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Wallet Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: ['All', 'In Hand', 'In Bank'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedFilter = filter);
                            }
                          },
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Grouped Transactions
              if (grouped.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_rounded, size: 40, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            "No transactions found",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, groupIndex) {
                        final groupKey = grouped.keys.elementAt(groupIndex);
                        final groupItems = grouped[groupKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                groupKey.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            ...groupItems.map(
                              (item) {
                                if (item is HistoryExpenseItem) {
                                  final exp = item.expense;
                                  final category = state is ExpenseLoaded
                                      ? state.getCategory(exp.categoryId)
                                      : null;
                                  final wallet = state is ExpenseLoaded
                                      ? state.getWallet(exp.walletId)
                                      : null;

                                  return Dismissible(
                                    key: Key('history_expense_${exp.id}'),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.only(right: 20),
                                      alignment: Alignment.centerRight,
                                      decoration: BoxDecoration(
                                        color: AppColors.expense.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                    ),
                                    confirmDismiss: (direction) => _confirmDeleteExpenseDialog(exp),
                                    onDismissed: (direction) => _deleteExpense(exp),
                                    child: TransactionCard(
                                      expense: exp,
                                      category: category,
                                      wallet: wallet,
                                      onTap: () {
                                        TransactionDetailsSheet.show(
                                          context,
                                          expense: exp,
                                          category: category,
                                          wallet: wallet,
                                          onDelete: () async {
                                            final confirmed = await _confirmDeleteExpenseDialog(exp);
                                            if (confirmed) {
                                              _deleteExpense(exp);
                                            }
                                          },
                                          onEdit: () => _editExpense(exp),
                                        );
                                      },
                                    ),
                                  );
                                } else if (item is HistoryTransferItem) {
                                  final transfer = item.transfer;
                                  final fromWallet = state is ExpenseLoaded
                                      ? state.getWallet(transfer.fromWalletId)
                                      : null;
                                  final toWallet = state is ExpenseLoaded
                                      ? state.getWallet(transfer.toWalletId)
                                      : null;

                                  return Dismissible(
                                    key: Key('history_transfer_${transfer.id}'),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.only(right: 20),
                                      alignment: Alignment.centerRight,
                                      decoration: BoxDecoration(
                                        color: AppColors.expense.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Revert",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                    ),
                                    confirmDismiss: (direction) =>
                                        _confirmDeleteTransferDialog(transfer, fromWallet, toWallet),
                                    onDismissed: (direction) => _deleteTransfer(transfer, fromWallet),
                                    child: TransferCard(
                                      transfer: transfer,
                                      fromWallet: fromWallet,
                                      toWallet: toWallet,
                                      onTap: () {
                                        TransferDetailsSheet.show(
                                          context,
                                          transfer: transfer,
                                          fromWallet: fromWallet,
                                          toWallet: toWallet,
                                          onDelete: () async {
                                            final confirmed = await _confirmDeleteTransferDialog(
                                              transfer,
                                              fromWallet,
                                              toWallet,
                                            );
                                            if (confirmed) {
                                              _deleteTransfer(transfer, fromWallet);
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        );
                      },
                      childCount: grouped.keys.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }
}
