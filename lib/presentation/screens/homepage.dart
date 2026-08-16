import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_management_app/models/transaction_model.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
import 'package:money_management_app/presentation/widgets/herocard.dart';
import 'package:money_management_app/presentation/widgets/section_header.dart';
import 'package:money_management_app/presentation/widgets/transactioncard.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  static const double _dailyBudget = 2000.0;

  // Transactions containing ONLY current day (Today) and Yesterday
  final List<Transaction> _transactions = const [
    Transaction(
      id: '1',
      icon: Icons.free_breakfast_outlined,
      title: 'Tea & Breakfast',
      category: 'Breakfast',
      wallet: 'In Hand',
      time: '8:30 AM',
      amount: -45.00,
      iconColor: AppColors.breakfast,
      dateGroup: 'Today',
    ),
    Transaction(
      id: '2',
      icon: Icons.lunch_dining_outlined,
      title: 'South Indian Meals',
      category: 'Lunch',
      wallet: 'In Hand',
      time: '1:15 PM',
      amount: -120.00,
      iconColor: AppColors.lunch,
      dateGroup: 'Today',
    ),
    Transaction(
      id: '3',
      icon: Icons.handshake_outlined,
      title: 'Repayment from Rahul',
      category: 'Lending',
      wallet: 'In Bank',
      time: '5:00 PM',
      amount: 500.00,
      iconColor: AppColors.lending,
      dateGroup: 'Today',
    ),
    Transaction(
      id: '4',
      icon: Icons.dinner_dining_outlined,
      title: 'Dinner & Sweets',
      category: 'Dinner',
      wallet: 'In Bank',
      time: '8:45 PM',
      amount: -350.00,
      iconColor: AppColors.dinner,
      dateGroup: 'Yesterday',
    ),
    Transaction(
      id: '5',
      icon: Icons.category_outlined,
      title: 'Stationery & Notebook',
      category: 'Other',
      wallet: 'In Hand',
      time: '4:20 PM',
      amount: -80.00,
      iconColor: AppColors.other,
      dateGroup: 'Yesterday',
    ),
    Transaction(
      id: '6',
      icon: Icons.free_breakfast_outlined,
      title: 'Morning Filter Coffee',
      category: 'Breakfast',
      wallet: 'In Hand',
      time: '8:15 AM',
      amount: -30.00,
      iconColor: AppColors.breakfast,
      dateGroup: 'Yesterday',
    ),
  ];

  // Group transactions by dateGroup (Today, Yesterday)
  Map<String, List<Transaction>> get _groupedTransactions {
    final Map<String, List<Transaction>> groups = {};
    for (final tx in _transactions) {
      if (!groups.containsKey(tx.dateGroup)) {
        groups[tx.dateGroup] = [];
      }
      groups[tx.dateGroup]!.add(tx);
    }
    return groups;
  }

  // Calculate today's total spending
  double get _todaySpent {
    return _transactions
        .where((t) => t.dateGroup == 'Today' && t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
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

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedTransactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom App Header: Greeting & Today's Date
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _buildHeader(),
              ),
            ),

            // Hero Card: Today's Spend + Daily Budget Remaining
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TodaySpentCard(
                  dailySpent: _todaySpent,
                  dailyBudget: _dailyBudget,
                ),
              ),
            ),

            // Section Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 6),
                child: SectionHeader(
                  title: "Recent Transactions",
                ),
              ),
            ),

            // Grouped Transaction List (Today & Yesterday only)
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
                        ...groupItems.asMap().entries.map((entry) {
                          final item = entry.value;
                          final globalIndex = groupIndex * 3 + entry.key;

                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 250 + (globalIndex * 40)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 14 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: TransactionCard(
                              transaction: item,
                              onTap: () {},
                            ),
                          );
                        }),
                      ],
                    );
                  },
                  childCount: grouped.keys.length,
                ),
              ),
            ),

            // Bottom Spacing for Navigation Bar & FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMM').format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
        // Notification action button
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.surfaceBorder,
                width: 1,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
