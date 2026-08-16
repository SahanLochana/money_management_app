import 'package:flutter/material.dart';
import 'package:money_management_app/models/transaction_model.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/presentation/widgets/transaction_details_sheet.dart';
import 'package:money_management_app/presentation/widgets/transactioncard.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';

  final List<Transaction> _allTransactions = [
    const Transaction(
      id: '1',
      icon: Icons.free_breakfast_outlined,
      title: 'Tea & Snacks',
      category: 'Breakfast',
      wallet: 'In Hand',
      time: '8:30 AM',
      amount: -45.00,
      iconColor: AppColors.breakfast,
      dateGroup: 'Today (16 Aug)',
      note: 'Evening tea with samosa',
    ),
    const Transaction(
      id: '2',
      icon: Icons.lunch_dining_outlined,
      title: 'Thali Meals',
      category: 'Lunch',
      wallet: 'In Hand',
      time: '1:15 PM',
      amount: -120.00,
      iconColor: AppColors.lunch,
      dateGroup: 'Today (16 Aug)',
      note: 'South Indian mini thali',
    ),
    const Transaction(
      id: '3',
      icon: Icons.handshake_outlined,
      title: 'Friend Repayment',
      category: 'Lending',
      wallet: 'In Bank',
      time: '5:00 PM',
      amount: 500.00,
      iconColor: AppColors.lending,
      dateGroup: 'Today (16 Aug)',
      note: 'UPI transfer from Alex',
    ),
    const Transaction(
      id: '4',
      icon: Icons.dinner_dining_outlined,
      title: 'Dinner with Family',
      category: 'Dinner',
      wallet: 'In Bank',
      time: '8:45 PM',
      amount: -350.00,
      iconColor: AppColors.dinner,
      dateGroup: 'Yesterday (15 Aug)',
      note: 'Family restaurant bill',
    ),
    const Transaction(
      id: '5',
      icon: Icons.local_cafe_outlined,
      title: 'Coffee & Biscuits',
      category: 'Breakfast',
      wallet: 'In Hand',
      time: '8:15 AM',
      amount: -30.00,
      iconColor: AppColors.breakfast,
      dateGroup: 'Yesterday (15 Aug)',
    ),
    const Transaction(
      id: '6',
      icon: Icons.category_outlined,
      title: 'Mobile Recharge',
      category: 'Other',
      wallet: 'In Bank',
      time: '14 Aug',
      amount: -299.00,
      iconColor: AppColors.other,
      dateGroup: '14 Aug 2026',
      note: 'Prepaid 1 month pack',
    ),
    const Transaction(
      id: '7',
      icon: Icons.lunch_dining_outlined,
      title: 'Biryani Special',
      category: 'Lunch',
      wallet: 'In Hand',
      time: '13 Aug',
      amount: -180.00,
      iconColor: AppColors.lunch,
      dateGroup: '13 Aug 2026',
      note: 'Special dum biryani',
    ),
  ];

  Map<String, List<Transaction>> get _groupedTransactions {
    final Map<String, List<Transaction>> groups = {};
    for (final tx in _allTransactions) {
      if (_selectedFilter != 'All' && tx.wallet != _selectedFilter) {
        continue;
      }
      if (!groups.containsKey(tx.dateGroup)) {
        groups[tx.dateGroup] = [];
      }
      groups[tx.dateGroup]!.add(tx);
    }
    return groups;
  }

  void _deleteTransaction(Transaction tx) {
    final index = _allTransactions.indexOf(tx);
    setState(() {
      _allTransactions.remove(tx);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Deleted '${tx.title}'"),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: "Undo",
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              if (index >= 0 && index <= _allTransactions.length) {
                _allTransactions.insert(index, tx);
              } else {
                _allTransactions.add(tx);
              }
            });
          },
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteDialog(Transaction tx) async {
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
          "Are you sure you want to delete '${tx.title}' (${tx.formattedAmount})?",
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

  void _showTransactionDetails(Transaction tx) {
    TransactionDetailsSheet.show(
      context,
      transaction: tx,
      onDelete: () async {
        final confirmed = await _confirmDeleteDialog(tx);
        if (confirmed) {
          _deleteTransaction(tx);
        }
      },
      onEdit: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Edit '${tx.title}' coming soon"),
            backgroundColor: AppColors.surfaceLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedTransactions;

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
      body: CustomScrollView(
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
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    "No transactions found for this wallet",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
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
                          (item) => Dismissible(
                            key: Key(item.id),
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
                            confirmDismiss: (direction) => _confirmDeleteDialog(item),
                            onDismissed: (direction) => _deleteTransaction(item),
                            child: TransactionCard(
                              transaction: item,
                              onTap: () => _showTransactionDetails(item),
                            ),
                          ),
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
      ),
    );
  }
}
