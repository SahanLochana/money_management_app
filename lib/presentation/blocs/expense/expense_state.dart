import 'package:money_management_app/domain/models/category.dart';
import 'package:money_management_app/domain/models/expense.dart';
import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/domain/models/wallet_transfer.dart';

abstract class ExpenseState {
  const ExpenseState();
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> todayExpenses;
  final double todayTotal;
  final Map<String, List<Expense>> groupedExpenses;
  final List<WalletTransfer> todayTransfers;
  final Map<String, List<WalletTransfer>> groupedTransfers;
  final List<Category> categories;
  final List<Wallet> wallets;

  const ExpenseLoaded({
    required this.todayExpenses,
    required this.todayTotal,
    required this.groupedExpenses,
    this.todayTransfers = const [],
    this.groupedTransfers = const {},
    required this.categories,
    required this.wallets,
  });

  Category? getCategory(int id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Wallet? getWallet(int id) {
    try {
      return wallets.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}

class ExpenseError extends ExpenseState {
  final String message;
  const ExpenseError(this.message);
}
