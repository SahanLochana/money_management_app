import 'package:intl/intl.dart';
import 'package:money_management_app/data/database/app_database.dart';
import 'package:money_management_app/data/database/tables.dart';
import 'package:money_management_app/domain/models/expense.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseLocalDatasource {
  final AppDatabase appDatabase;

  ExpenseLocalDatasource({required this.appDatabase});

  Future<Database> get _db => appDatabase.database;

  Future<int> insertExpense(Expense expense) async {
    final db = await _db;
    return await db.insert(AppTables.expenses, expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await _db;
    return await db.update(
      AppTables.expenses,
      expense.toMap(),
      where: '${AppTables.colExpenseId} = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> softDeleteExpense(int id) async {
    final db = await _db;
    return await db.update(
      AppTables.expenses,
      {
        AppTables.colExpenseIsDeleted: 1,
        AppTables.colExpenseUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${AppTables.colExpenseId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> restoreExpense(int id) async {
    final db = await _db;
    return await db.update(
      AppTables.expenses,
      {
        AppTables.colExpenseIsDeleted: 0,
        AppTables.colExpenseUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${AppTables.colExpenseId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Expense>> getTodayExpenses() async {
    final db = await _db;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final maps = await db.query(
      AppTables.expenses,
      where: '${AppTables.colExpenseIsDeleted} = 0 AND ${AppTables.colExpenseDate} = ?',
      whereArgs: [todayStr],
      orderBy: '${AppTables.colExpenseCreatedAt} DESC',
    );

    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<List<Expense>> getAllActiveExpenses() async {
    final db = await _db;
    final maps = await db.query(
      AppTables.expenses,
      where: '${AppTables.colExpenseIsDeleted} = 0',
      orderBy: '${AppTables.colExpenseDate} DESC, ${AppTables.colExpenseCreatedAt} DESC',
    );

    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<List<Expense>> getExpensesForMonth(int year, int month) async {
    final db = await _db;
    final monthStr = month.toString().padLeft(2, '0');
    final startPrefix = '$year-$monthStr';

    final maps = await db.query(
      AppTables.expenses,
      where: '${AppTables.colExpenseIsDeleted} = 0 AND ${AppTables.colExpenseDate} LIKE ?',
      whereArgs: ['$startPrefix%'],
      orderBy: '${AppTables.colExpenseDate} DESC, ${AppTables.colExpenseCreatedAt} DESC',
    );

    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<int> getTodayTotalCents() async {
    final db = await _db;
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final result = await db.rawQuery(
      '''
      SELECT SUM(${AppTables.colExpenseAmountCents}) as total
      FROM ${AppTables.expenses}
      WHERE ${AppTables.colExpenseIsDeleted} = 0 AND ${AppTables.colExpenseDate} = ?
      ''',
      [todayStr],
    );

    final total = result.first['total'] as int?;
    return total ?? 0;
  }

  Future<int> getMonthlyTotalCents(int year, int month) async {
    final db = await _db;
    final monthStr = month.toString().padLeft(2, '0');
    final startPrefix = '$year-$monthStr';

    final result = await db.rawQuery(
      '''
      SELECT SUM(${AppTables.colExpenseAmountCents}) as total
      FROM ${AppTables.expenses}
      WHERE ${AppTables.colExpenseIsDeleted} = 0 AND ${AppTables.colExpenseDate} LIKE ?
      ''',
      ['$startPrefix%'],
    );

    final total = result.first['total'] as int?;
    return total ?? 0;
  }

  Future<Map<int, int>> getMonthlyCategoryTotalsCents(int year, int month) async {
    final db = await _db;
    final monthStr = month.toString().padLeft(2, '0');
    final startPrefix = '$year-$monthStr';

    final results = await db.rawQuery(
      '''
      SELECT ${AppTables.colExpenseCategoryId}, SUM(${AppTables.colExpenseAmountCents}) as total
      FROM ${AppTables.expenses}
      WHERE ${AppTables.colExpenseIsDeleted} = 0 AND ${AppTables.colExpenseDate} LIKE ?
      GROUP BY ${AppTables.colExpenseCategoryId}
      ''',
      ['$startPrefix%'],
    );

    final Map<int, int> totals = {};
    for (final row in results) {
      final categoryId = row[AppTables.colExpenseCategoryId] as int;
      final total = (row['total'] as int?) ?? 0;
      totals[categoryId] = total;
    }
    return totals;
  }

  Future<Map<int, int>> getMonthlyWalletTotalsCents(int year, int month) async {
    final db = await _db;
    final monthStr = month.toString().padLeft(2, '0');
    final startPrefix = '$year-$monthStr';

    final results = await db.rawQuery(
      '''
      SELECT ${AppTables.colExpenseWalletId}, SUM(${AppTables.colExpenseAmountCents}) as total
      FROM ${AppTables.expenses}
      WHERE ${AppTables.colExpenseIsDeleted} = 0 AND ${AppTables.colExpenseDate} LIKE ?
      GROUP BY ${AppTables.colExpenseWalletId}
      ''',
      ['$startPrefix%'],
    );

    final Map<int, int> totals = {};
    for (final row in results) {
      final walletId = row[AppTables.colExpenseWalletId] as int;
      final total = (row['total'] as int?) ?? 0;
      totals[walletId] = total;
    }
    return totals;
  }

  Future<Map<int, int>> getAllWalletExpenseTotalsCents() async {
    final db = await _db;
    final results = await db.rawQuery(
      '''
      SELECT ${AppTables.colExpenseWalletId}, SUM(${AppTables.colExpenseAmountCents}) as total
      FROM ${AppTables.expenses}
      WHERE ${AppTables.colExpenseIsDeleted} = 0
      GROUP BY ${AppTables.colExpenseWalletId}
      ''',
    );

    final Map<int, int> totals = {};
    for (final row in results) {
      final walletId = row[AppTables.colExpenseWalletId] as int;
      final total = (row['total'] as int?) ?? 0;
      totals[walletId] = total;
    }
    return totals;
  }

  Future<void> clearAllExpenses() async {
    final db = await _db;
    await db.delete(AppTables.expenses);
  }

  Future<List<Map<String, dynamic>>> exportAllExpenses() async {
    final db = await _db;
    return await db.query(
      AppTables.expenses,
      where: '${AppTables.colExpenseIsDeleted} = 0',
      orderBy: '${AppTables.colExpenseDate} DESC',
    );
  }
}
