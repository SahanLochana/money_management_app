import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_management_app/domain/models/expense.dart';
import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/domain/models/wallet_transfer.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_bloc.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_event.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_state.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_bloc.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_event.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_state.dart';
import 'package:money_management_app/presentation/screens/add_transaction_page.dart';
import 'package:money_management_app/presentation/screens/manage_wallets_page.dart';
import 'package:money_management_app/presentation/screens/settings_page.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/presentation/widgets/app_snackbar.dart';
import 'package:money_management_app/presentation/widgets/confirm_action_dialog.dart';
import 'package:money_management_app/presentation/widgets/herocard.dart';
import 'package:money_management_app/presentation/widgets/section_header.dart';
import 'package:money_management_app/presentation/widgets/transaction_details_sheet.dart';
import 'package:money_management_app/presentation/widgets/transactioncard.dart';
import 'package:money_management_app/presentation/widgets/transfer_card.dart';
import 'package:money_management_app/presentation/widgets/transfer_details_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class TodayActivityItem {
  String get time;
}

class TodayExpenseItem extends TodayActivityItem {
  final Expense expense;
  TodayExpenseItem(this.expense);
  @override
  String get time => expense.expenseTime;
}

class TodayTransferItem extends TodayActivityItem {
  final WalletTransfer transfer;
  TodayTransferItem(this.transfer);
  @override
  String get time => transfer.transferTime;
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  double _dailyBudget = 500.0;

  @override
  void initState() {
    super.initState();
    _loadDailyBudget();
  }

  Future<void> _loadDailyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBudget = prefs.getDouble('daily_budget') ?? 500.0;
    if (mounted) {
      setState(() => _dailyBudget = savedBudget);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning 👋";
    } else if (hour < 17) {
      return "Good Afternoon 👋";
    } else {
      return "Good Evening 👋";
    }
  }

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
    return ConfirmActionDialog.show(
      context,
      title: "Delete Expense?",
      message:
          "Are you sure you want to delete this expense (${exp.formattedAmount})? This will restore ${exp.formattedAmount} back to your wallet balance.",
      confirmLabel: "Delete",
      confirmColor: AppColors.expense,
    );
  }

  Future<bool> _confirmDeleteTransferDialog(WalletTransfer transfer, Wallet? fromWallet, Wallet? toWallet) async {
    final fromName = fromWallet?.name ?? "source wallet";
    final toName = toWallet?.name ?? "destination wallet";

    return ConfirmActionDialog.show(
      context,
      title: "Revert Transfer?",
      message:
          "Are you sure you want to revert this transfer (${transfer.formattedAmount})? This will return ${transfer.formattedAmount} to $fromName and deduct it from $toName.",
      confirmLabel: "Revert",
      confirmColor: AppColors.expense,
    );
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
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMM').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formattedDate,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ).then((_) => _loadDailyBudget());
              },
            ),
          ),
        ],
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
          List<Expense> todayExpenses = [];
          List<WalletTransfer> todayTransfers = [];
          double todaySpent = 0.0;

          if (state is ExpenseLoaded) {
            todayExpenses = state.todayExpenses;
            todayTransfers = state.todayTransfers;
            todaySpent = state.todayTotal;
          }

          final List<TodayActivityItem> activityItems = [
            ...todayExpenses.map((e) => TodayExpenseItem(e)),
            ...todayTransfers.map((t) => TodayTransferItem(t)),
          ];
          activityItems.sort((a, b) => b.time.compareTo(a.time));

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              context.read<ExpenseBloc>().add(const LoadExpenses());
              context.read<WalletBloc>().add(const LoadWalletsEvent());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Hero Card: Today's Spend + Daily Budget Remaining (Transfers excluded)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: TodaySpentCard(
                      dailySpent: todaySpent,
                      dailyBudget: _dailyBudget,
                    ),
                  ),
                ),

                // Live Wallet Balance Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                    child: BlocBuilder<WalletBloc, WalletState>(
                      builder: (context, walletState) {
                        if (walletState is WalletLoaded) {
                          return Row(
                            children: walletState.wallets.map((wallet) {
                              final balance = walletState.getBalance(wallet.id);
                              final isNegative = balance < 0;

                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: wallet == walletState.wallets.last ? 0 : 10,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const ManageWalletsPage(),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isNegative
                                                ? AppColors.expense.withValues(alpha: 0.4)
                                                : AppColors.surfaceBorder.withValues(alpha: 0.7),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              wallet.emoji,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    wallet.name,
                                                    style: const TextStyle(
                                                      color: AppColors.textSecondary,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 1),
                                                  Text(
                                                    "Rs ${balance.toStringAsFixed(0)}",
                                                    style: TextStyle(
                                                      color: isNegative
                                                          ? AppColors.expense
                                                          : AppColors.textPrimary,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),

                // Section Header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 6),
                    child: SectionHeader(
                      title: "Today's Transactions",
                    ),
                  ),
                ),

                // Today's Activity List or Empty State
                if (activityItems.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                color: AppColors.textMuted,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "No transactions today",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Tap the + button to add an expense or transfer",
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
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
                        (context, index) {
                          final item = activityItems[index];

                          if (item is TodayExpenseItem) {
                            final exp = item.expense;
                            final category = state is ExpenseLoaded
                                ? state.getCategory(exp.categoryId)
                                : null;
                            final wallet = state is ExpenseLoaded
                                ? state.getWallet(exp.walletId)
                                : null;

                            return Dismissible(
                              key: Key('expense_${exp.id}'),
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
                          } else if (item is TodayTransferItem) {
                            final transfer = item.transfer;
                            final fromWallet = state is ExpenseLoaded
                                ? state.getWallet(transfer.fromWalletId)
                                : null;
                            final toWallet = state is ExpenseLoaded
                                ? state.getWallet(transfer.toWalletId)
                                : null;

                            return Dismissible(
                              key: Key('transfer_${transfer.id}'),
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
                        childCount: activityItems.length,
                      ),
                    ),
                  ),

                // Bottom Spacing for Navigation Bar & FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
