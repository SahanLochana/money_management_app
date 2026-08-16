import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final IconData icon;
  final String title;
  final String category;
  final String wallet; // "In Hand", "In Bank"
  final String time;
  final double amount; // negative for expense, positive for income
  final Color iconColor;
  final String dateGroup; // "Today", "Yesterday"

  const Transaction({
    required this.id,
    required this.icon,
    required this.title,
    required this.category,
    this.wallet = 'In Hand',
    required this.time,
    required this.amount,
    required this.iconColor,
    required this.dateGroup,
  });

  bool get isIncome => amount > 0;
  bool get isExpense => amount < 0;

  String get formattedAmount {
    final prefix = isIncome ? '+Rs ' : '-Rs ';
    final absAmount = amount.abs().toStringAsFixed(0);
    return '$prefix$absAmount';
  }
}
