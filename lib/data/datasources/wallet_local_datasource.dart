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
}
