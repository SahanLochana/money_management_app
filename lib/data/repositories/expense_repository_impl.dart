import 'package:intl/intl.dart';
import 'package:money_management_app/data/datasources/expense_local_datasource.dart';
import 'package:money_management_app/domain/models/expense.dart';
import 'package:money_management_app/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDatasource localDatasource;

  ExpenseRepositoryImpl({required this.localDatasource});

  @override
  Future<List<Expense>> getTodayExpenses() async {
    return await localDatasource.getTodayExpenses();
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    return await localDatasource.getAllActiveExpenses();
  }

  @override
  Future<List<Expense>> getExpensesForMonth(int year, int month) async {
    return await localDatasource.getExpensesForMonth(year, month);
  }

  @override
  Future<Map<String, List<Expense>>> getExpensesGroupedByDate() async {
    final expenses = await localDatasource.getAllActiveExpenses();
    final Map<String, List<Expense>> grouped = {};

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

    for (final exp in expenses) {
      String groupLabel;
      if (exp.expenseDate == todayStr) {
        groupLabel = 'Today';
      } else if (exp.expenseDate == yesterdayStr) {
        groupLabel = 'Yesterday';
      } else {
        try {
          final parsed = DateTime.parse(exp.expenseDate);
          groupLabel = DateFormat('d MMM yyyy').format(parsed);
        } catch (_) {
          groupLabel = exp.expenseDate;
        }
      }

      if (!grouped.containsKey(groupLabel)) {
        grouped[groupLabel] = [];
      }
      grouped[groupLabel]!.add(exp);
    }

    return grouped;
  }

  @override
  Future<int> addExpense(Expense expense) async {
    return await localDatasource.insertExpense(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await localDatasource.updateExpense(expense);
  }

  @override
  Future<void> softDeleteExpense(int id) async {
    await localDatasource.softDeleteExpense(id);
  }

  @override
  Future<void> restoreExpense(int id) async {
    await localDatasource.restoreExpense(id);
  }

  @override
  Future<double> getTodayTotal() async {
    final cents = await localDatasource.getTodayTotalCents();
    return cents / 100.0;
  }

  @override
  Future<double> getMonthlyTotal(int year, int month) async {
    final cents = await localDatasource.getMonthlyTotalCents(year, month);
    return cents / 100.0;
  }

  @override
  Future<Map<int, double>> getMonthlyCategoryTotals(int year, int month) async {
    final centsMap = await localDatasource.getMonthlyCategoryTotalsCents(year, month);
    return centsMap.map((key, value) => MapEntry(key, value / 100.0));
  }

  @override
  Future<Map<int, double>> getMonthlyWalletTotals(int year, int month) async {
    final centsMap = await localDatasource.getMonthlyWalletTotalsCents(year, month);
    return centsMap.map((key, value) => MapEntry(key, value / 100.0));
  }

  @override
  Future<Map<int, double>> getAllWalletExpenseTotals() async {
    final centsMap = await localDatasource.getAllWalletExpenseTotalsCents();
    return centsMap.map((key, value) => MapEntry(key, value / 100.0));
  }

  @override
  Future<void> clearAllData() async {
    await localDatasource.clearAllExpenses();
  }

  @override
  Future<List<Map<String, dynamic>>> exportAllData() async {
    return await localDatasource.exportAllExpenses();
  }
}
