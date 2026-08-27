import 'package:money_management_app/data/database/app_database.dart';
import 'package:money_management_app/data/database/tables.dart';
import 'package:money_management_app/domain/models/wallet.dart';
import 'package:sqflite/sqflite.dart';

class WalletLocalDatasource {
  final AppDatabase appDatabase;

  WalletLocalDatasource({required this.appDatabase});

  Future<Database> get _db => appDatabase.database;

  Future<List<Wallet>> getAllWallets() async {
    final db = await _db;
    final maps = await db.query(
      AppTables.wallets,
      orderBy: '${AppTables.colWalletId} ASC',
    );
    return maps.map((e) => Wallet.fromMap(e)).toList();
  }

  Future<Wallet?> getWalletById(int id) async {
    final db = await _db;
    final maps = await db.query(
      AppTables.wallets,
      where: '${AppTables.colWalletId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Wallet.fromMap(maps.first);
  }

  Future<int> insertWalletFund(Map<String, dynamic> fundMap) async {
    final db = await _db;
    return await db.insert(AppTables.walletFunds, fundMap);
  }

  Future<List<Map<String, dynamic>>> getFundsForWallet(int walletId) async {
    final db = await _db;
    return await db.query(
      AppTables.walletFunds,
      where: '${AppTables.colFundWalletId} = ?',
      whereArgs: [walletId],
      orderBy: '${AppTables.colFundCreatedAt} DESC',
    );
  }

  Future<Map<int, int>> getAllWalletFundTotalsCents() async {
    final db = await _db;
    final results = await db.rawQuery(
      '''
      SELECT ${AppTables.colFundWalletId}, SUM(${AppTables.colFundAmountCents}) as total
      FROM ${AppTables.walletFunds}
      GROUP BY ${AppTables.colFundWalletId}
      ''',
    );

    final Map<int, int> totals = {};
    for (final row in results) {
      final walletId = row[AppTables.colFundWalletId] as int;
      final total = (row['total'] as int?) ?? 0;
      totals[walletId] = total;
    }
    return totals;
  }

  Future<int> deleteWalletFund(int id) async {
    final db = await _db;
    return await db.delete(
      AppTables.walletFunds,
      where: '${AppTables.colFundId} = ?',
      whereArgs: [id],
    );
  }
}
