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

  // --- Wallet Transfers ---

  Future<int> insertWalletTransfer(Map<String, dynamic> transferMap) async {
    final db = await _db;
    return await db.insert(AppTables.walletTransfers, transferMap);
  }

  Future<int> softDeleteTransfer(int id) async {
    final db = await _db;
    return await db.update(
      AppTables.walletTransfers,
      {AppTables.colTransferIsDeleted: 1},
      where: '${AppTables.colTransferId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> restoreTransfer(int id) async {
    final db = await _db;
    return await db.update(
      AppTables.walletTransfers,
      {AppTables.colTransferIsDeleted: 0},
      where: '${AppTables.colTransferId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getTodayTransfers(String todayStr) async {
    final db = await _db;
    return await db.query(
      AppTables.walletTransfers,
      where: '${AppTables.colTransferIsDeleted} = 0 AND ${AppTables.colTransferDate} = ?',
      whereArgs: [todayStr],
      orderBy: '${AppTables.colTransferCreatedAt} DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllActiveTransfers() async {
    final db = await _db;
    return await db.query(
      AppTables.walletTransfers,
      where: '${AppTables.colTransferIsDeleted} = 0',
      orderBy: '${AppTables.colTransferDate} DESC, ${AppTables.colTransferCreatedAt} DESC',
    );
  }

  Future<Map<int, int>> getTransferInTotalsCents() async {
    final db = await _db;
    final results = await db.rawQuery(
      '''
      SELECT ${AppTables.colTransferToWalletId}, SUM(${AppTables.colTransferAmountCents}) as total
      FROM ${AppTables.walletTransfers}
      WHERE ${AppTables.colTransferIsDeleted} = 0
      GROUP BY ${AppTables.colTransferToWalletId}
      ''',
    );

    final Map<int, int> totals = {};
    for (final row in results) {
      final walletId = row[AppTables.colTransferToWalletId] as int;
      final total = (row['total'] as int?) ?? 0;
      totals[walletId] = total;
    }
    return totals;
  }

  Future<Map<int, int>> getTransferOutTotalsCents() async {
    final db = await _db;
    final results = await db.rawQuery(
      '''
      SELECT ${AppTables.colTransferFromWalletId}, SUM(${AppTables.colTransferAmountCents}) as total
      FROM ${AppTables.walletTransfers}
      WHERE ${AppTables.colTransferIsDeleted} = 0
      GROUP BY ${AppTables.colTransferFromWalletId}
      ''',
    );

    final Map<int, int> totals = {};
    for (final row in results) {
      final walletId = row[AppTables.colTransferFromWalletId] as int;
      final total = (row['total'] as int?) ?? 0;
      totals[walletId] = total;
    }
    return totals;
  }
}
