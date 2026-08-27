import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:money_management_app/data/database/tables.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vault_money.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Categories table
    await db.execute('''
      CREATE TABLE ${AppTables.categories} (
        ${AppTables.colCatId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppTables.colCatName} TEXT NOT NULL,
        ${AppTables.colCatEmoji} TEXT NOT NULL,
        ${AppTables.colCatDefaultAmountCents} INTEGER NOT NULL DEFAULT 0,
        ${AppTables.colCatIsSystem} INTEGER NOT NULL DEFAULT 0,
        ${AppTables.colCatIsDeleted} INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 2. Wallets table
    await db.execute('''
      CREATE TABLE ${AppTables.wallets} (
        ${AppTables.colWalletId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppTables.colWalletName} TEXT NOT NULL,
        ${AppTables.colWalletEmoji} TEXT NOT NULL
      )
    ''');

    // 3. Expenses table
    await db.execute('''
      CREATE TABLE ${AppTables.expenses} (
        ${AppTables.colExpenseId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppTables.colExpenseCategoryId} INTEGER NOT NULL,
        ${AppTables.colExpenseAmountCents} INTEGER NOT NULL,
        ${AppTables.colExpenseWalletId} INTEGER NOT NULL,
        ${AppTables.colExpenseDate} TEXT NOT NULL,
        ${AppTables.colExpenseTime} TEXT NOT NULL,
        ${AppTables.colExpenseNote} TEXT,
        ${AppTables.colExpenseIsDeleted} INTEGER NOT NULL DEFAULT 0,
        ${AppTables.colExpenseCreatedAt} TEXT NOT NULL,
        ${AppTables.colExpenseUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (${AppTables.colExpenseCategoryId}) REFERENCES ${AppTables.categories} (${AppTables.colCatId}),
        FOREIGN KEY (${AppTables.colExpenseWalletId}) REFERENCES ${AppTables.wallets} (${AppTables.colWalletId})
      )
    ''');

    // 4. Reminder Slots table
    await db.execute('''
      CREATE TABLE ${AppTables.reminderSlots} (
        ${AppTables.colReminderId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppTables.colReminderCategoryId} INTEGER NOT NULL,
        ${AppTables.colReminderTime} TEXT NOT NULL,
        ${AppTables.colReminderDefaultAmountCents} INTEGER NOT NULL DEFAULT 0,
        ${AppTables.colReminderIsActive} INTEGER NOT NULL DEFAULT 1,
        ${AppTables.colReminderIsSystem} INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (${AppTables.colReminderCategoryId}) REFERENCES ${AppTables.categories} (${AppTables.colCatId})
      )
    ''');

    // 5. Wallet Funds table
    await db.execute('''
      CREATE TABLE ${AppTables.walletFunds} (
        ${AppTables.colFundId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppTables.colFundWalletId} INTEGER NOT NULL,
        ${AppTables.colFundAmountCents} INTEGER NOT NULL,
        ${AppTables.colFundNote} TEXT,
        ${AppTables.colFundCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${AppTables.colFundWalletId}) REFERENCES ${AppTables.wallets} (${AppTables.colWalletId})
      )
    ''');

    // 6. Wallet Transfers table
    await db.execute('''
      CREATE TABLE ${AppTables.walletTransfers} (
        ${AppTables.colTransferId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppTables.colTransferFromWalletId} INTEGER NOT NULL,
        ${AppTables.colTransferToWalletId} INTEGER NOT NULL,
        ${AppTables.colTransferAmountCents} INTEGER NOT NULL,
        ${AppTables.colTransferDate} TEXT NOT NULL,
        ${AppTables.colTransferTime} TEXT NOT NULL,
        ${AppTables.colTransferNote} TEXT,
        ${AppTables.colTransferIsDeleted} INTEGER NOT NULL DEFAULT 0,
        ${AppTables.colTransferCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${AppTables.colTransferFromWalletId}) REFERENCES ${AppTables.wallets} (${AppTables.colWalletId}),
        FOREIGN KEY (${AppTables.colTransferToWalletId}) REFERENCES ${AppTables.wallets} (${AppTables.colWalletId})
      )
    ''');

    // Seed default initial data
    await _seedDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppTables.walletFunds} (
          ${AppTables.colFundId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${AppTables.colFundWalletId} INTEGER NOT NULL,
          ${AppTables.colFundAmountCents} INTEGER NOT NULL,
          ${AppTables.colFundNote} TEXT,
          ${AppTables.colFundCreatedAt} TEXT NOT NULL,
          FOREIGN KEY (${AppTables.colFundWalletId}) REFERENCES ${AppTables.wallets} (${AppTables.colWalletId})
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppTables.walletTransfers} (
          ${AppTables.colTransferId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${AppTables.colTransferFromWalletId} INTEGER NOT NULL,
          ${AppTables.colTransferToWalletId} INTEGER NOT NULL,
          ${AppTables.colTransferAmountCents} INTEGER NOT NULL,
          ${AppTables.colTransferDate} TEXT NOT NULL,
          ${AppTables.colTransferTime} TEXT NOT NULL,
          ${AppTables.colTransferNote} TEXT,
          ${AppTables.colTransferIsDeleted} INTEGER NOT NULL DEFAULT 0,
          ${AppTables.colTransferCreatedAt} TEXT NOT NULL,
          FOREIGN KEY (${AppTables.colTransferFromWalletId}) REFERENCES ${AppTables.wallets} (${AppTables.colWalletId}),
          FOREIGN KEY (${AppTables.colTransferToWalletId}) REFERENCES ${AppTables.wallets} (${AppTables.colWalletId})
        )
      ''');
    }
  }

  Future<void> _seedDefaultData(Database db) async {
    // Seed system categories
    final categories = [
      {'name': 'Breakfast', 'emoji': '🍳', 'default_amount_cents': 8000, 'is_system': 1, 'is_deleted': 0},
      {'name': 'Lunch', 'emoji': '🍔', 'default_amount_cents': 15000, 'is_system': 1, 'is_deleted': 0},
      {'name': 'Dinner', 'emoji': '🌙', 'default_amount_cents': 18000, 'is_system': 1, 'is_deleted': 0},
      {'name': 'Lending', 'emoji': '🤝', 'default_amount_cents': 0, 'is_system': 1, 'is_deleted': 0},
      {'name': 'Other', 'emoji': '🍿', 'default_amount_cents': 0, 'is_system': 1, 'is_deleted': 0},
    ];

    for (final cat in categories) {
      await db.insert(AppTables.categories, cat);
    }

    // Seed default wallets
    final wallets = [
      {'name': 'In Hand', 'emoji': '👛'},
      {'name': 'In Bank', 'emoji': '🏦'},
    ];

    for (final wallet in wallets) {
      await db.insert(AppTables.wallets, wallet);
    }

    // Seed default reminder slots
    final reminderSlots = [
      {'category_id': 1, 'time': '08:00', 'default_amount_cents': 8000, 'is_active': 1, 'is_system': 1},
      {'category_id': 2, 'time': '13:00', 'default_amount_cents': 15000, 'is_active': 1, 'is_system': 1},
      {'category_id': 3, 'time': '20:00', 'default_amount_cents': 18000, 'is_active': 1, 'is_system': 1},
    ];

    for (final slot in reminderSlots) {
      await db.insert(AppTables.reminderSlots, slot);
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
