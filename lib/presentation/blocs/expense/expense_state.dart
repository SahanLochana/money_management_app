import 'package:money_management_app/domain/models/category.dart';
import 'package:money_management_app/domain/models/expense.dart';
import 'package:money_management_app/domain/models/wallet.dart';

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
  final List<Category> categories;
  final List<Wallet> wallets;

  const ExpenseLoaded({
    required this.todayExpenses,
    required this.todayTotal,
    required this.groupedExpenses,
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
