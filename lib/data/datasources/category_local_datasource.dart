import 'package:money_management_app/data/database/app_database.dart';
import 'package:money_management_app/data/database/tables.dart';
import 'package:money_management_app/domain/models/category.dart';
import 'package:sqflite/sqflite.dart';

class CategoryLocalDatasource {
  final AppDatabase appDatabase;

  CategoryLocalDatasource({required this.appDatabase});

  Future<Database> get _db => appDatabase.database;

  Future<List<Category>> getAllCategories() async {
    final db = await _db;
    final maps = await db.query(
      AppTables.categories,
      where: '${AppTables.colCatIsDeleted} = 0',
      orderBy: '${AppTables.colCatIsSystem} DESC, ${AppTables.colCatId} ASC',
    );
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await _db;
    final maps = await db.query(
      AppTables.categories,
      where: '${AppTables.colCatId} = ? AND ${AppTables.colCatIsDeleted} = 0',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<int> insertCategory(Category category) async {
    final db = await _db;
    return await db.insert(AppTables.categories, category.toMap());
  }

  Future<int> deleteCategory(int id) async {
    final db = await _db;
    return await db.transaction((txn) async {
      final otherMaps = await txn.query(
        AppTables.categories,
        where: '${AppTables.colCatIsDeleted} = 0 AND ${AppTables.colCatId} != ?',
        whereArgs: [id],
        orderBy: "CASE WHEN ${AppTables.colCatName} = 'Other' THEN 0 ELSE 1 END, ${AppTables.colCatId} ASC",
        limit: 1,
      );

      int fallbackCategoryId;
      if (otherMaps.isNotEmpty) {
        fallbackCategoryId = otherMaps.first[AppTables.colCatId] as int;
      } else {
        fallbackCategoryId = await txn.insert(AppTables.categories, {
          AppTables.colCatName: 'Other',
          AppTables.colCatEmoji: '🍿',
          AppTables.colCatDefaultAmountCents: 0,
          AppTables.colCatIsSystem: 1,
          AppTables.colCatIsDeleted: 0,
        });
      }

      await txn.update(
        AppTables.expenses,
        {AppTables.colExpenseCategoryId: fallbackCategoryId},
        where: '${AppTables.colExpenseCategoryId} = ?',
        whereArgs: [id],
      );

      await txn.delete(
        AppTables.reminderSlots,
        where: '${AppTables.colReminderCategoryId} = ?',
        whereArgs: [id],
      );

      return await txn.update(
        AppTables.categories,
        {AppTables.colCatIsDeleted: 1},
        where: '${AppTables.colCatId} = ?',
        whereArgs: [id],
      );
    });
  }

  Future<bool> categoryHasExpenses(int id) async {
    final db = await _db;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${AppTables.expenses}
      WHERE ${AppTables.colExpenseCategoryId} = ? AND ${AppTables.colExpenseIsDeleted} = 0
      ''',
      [id],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}
