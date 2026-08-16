import 'package:flutter/material.dart';
import 'package:money_management_app/models/transaction_model.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/presentation/widgets/transactioncard.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';

  final List<Transaction> _allTransactions = const [
    Transaction(
      id: '1',
      icon: Icons.free_breakfast_outlined,
      title: 'Tea & Snacks',
      category: 'Breakfast',
      wallet: 'In Hand',
      time: '8:30 AM',
      amount: -45.00,
      iconColor: AppColors.breakfast,
      dateGroup: 'Today (16 Aug)',
    ),
    Transaction(
      id: '2',
      icon: Icons.lunch_dining_outlined,
      title: 'Thali Meals',
      category: 'Lunch',
      wallet: 'In Hand',
      time: '1:15 PM',
      amount: -120.00,
      iconColor: AppColors.lunch,
      dateGroup: 'Today (16 Aug)',
    ),
    Transaction(
      id: '3',
      icon: Icons.handshake_outlined,
      title: 'Friend Repayment',
      category: 'Lending',
      wallet: 'In Bank',
      time: '5:00 PM',
      amount: 500.00,
      iconColor: AppColors.lending,
      dateGroup: 'Today (16 Aug)',
    ),
    Transaction(
      id: '4',
      icon: Icons.dinner_dining_outlined,
      title: 'Dinner with Family',
      category: 'Dinner',
      wallet: 'In Bank',
      time: '8:45 PM',
      amount: -350.00,
      iconColor: AppColors.dinner,
      dateGroup: 'Yesterday (15 Aug)',
    ),
    Transaction(
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
    Transaction(
      id: '6',
      icon: Icons.category_outlined,
      title: 'Mobile Recharge',
      category: 'Other',
      wallet: 'In Bank',
      time: '14 Aug',
      amount: -299.00,
      iconColor: AppColors.other,
      dateGroup: '14 Aug 2026',
    ),
    Transaction(
      id: '7',
      icon: Icons.lunch_dining_outlined,
      title: 'Biryani Special',
      category: 'Lunch',
      wallet: 'In Hand',
      time: '13 Aug',
      amount: -180.00,
      iconColor: AppColors.lunch,
      dateGroup: '13 Aug 2026',
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

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedTransactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "History",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Wallet Filter Chips
                    Row(
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
                  ],
                ),
              ),
            ),

            // Grouped Transactions
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
                        ...groupItems.map((item) => TransactionCard(
                              transaction: item,
                              onTap: () {},
                            )),
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
      ),
    );
  }
}
