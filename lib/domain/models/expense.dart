import 'package:money_management_app/data/database/tables.dart';

class Expense {
  final int? id;
  final int categoryId;
  final int amountCents;
  final int walletId;
  final String expenseDate; // YYYY-MM-DD
  final String expenseTime; // HH:mm
  final String? note;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    this.id,
    required this.categoryId,
    required this.amountCents,
    required this.walletId,
    required this.expenseDate,
    required this.expenseTime,
    this.note,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  double get amount => amountCents / 100.0;

  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';

  Expense copyWith({
    int? id,
    int? categoryId,
    int? amountCents,
    int? walletId,
    String? expenseDate,
    String? expenseTime,
    String? note,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amountCents: amountCents ?? this.amountCents,
      walletId: walletId ?? this.walletId,
      expenseDate: expenseDate ?? this.expenseDate,
      expenseTime: expenseTime ?? this.expenseTime,
      note: note ?? this.note,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) AppTables.colExpenseId: id,
      AppTables.colExpenseCategoryId: categoryId,
      AppTables.colExpenseAmountCents: amountCents,
      AppTables.colExpenseWalletId: walletId,
      AppTables.colExpenseDate: expenseDate,
      AppTables.colExpenseTime: expenseTime,
      AppTables.colExpenseNote: note,
      AppTables.colExpenseIsDeleted: isDeleted ? 1 : 0,
      AppTables.colExpenseCreatedAt: createdAt.toIso8601String(),
      AppTables.colExpenseUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map[AppTables.colExpenseId] as int?,
      categoryId: map[AppTables.colExpenseCategoryId] as int,
      amountCents: map[AppTables.colExpenseAmountCents] as int,
      walletId: map[AppTables.colExpenseWalletId] as int,
      expenseDate: map[AppTables.colExpenseDate] as String,
      expenseTime: map[AppTables.colExpenseTime] as String,
      note: map[AppTables.colExpenseNote] as String?,
      isDeleted: (map[AppTables.colExpenseIsDeleted] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map[AppTables.colExpenseCreatedAt] as String),
      updatedAt: DateTime.parse(map[AppTables.colExpenseUpdatedAt] as String),
    );
  }
}
