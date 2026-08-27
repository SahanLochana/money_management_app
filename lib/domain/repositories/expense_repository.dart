import 'package:money_management_app/domain/models/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getTodayExpenses();
  Future<List<Expense>> getAllExpenses();
  Future<List<Expense>> getExpensesForMonth(int year, int month);
  Future<Map<String, List<Expense>>> getExpensesGroupedByDate();
  Future<int> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> softDeleteExpense(int id);
  Future<void> restoreExpense(int id);
  Future<double> getTodayTotal();
  Future<double> getMonthlyTotal(int year, int month);
  Future<Map<int, double>> getMonthlyCategoryTotals(int year, int month);
  Future<Map<int, double>> getMonthlyWalletTotals(int year, int month);
  Future<Map<int, double>> getAllWalletExpenseTotals();
  Future<void> clearAllData();
  Future<List<Map<String, dynamic>>> exportAllData();
}
