class AppTables {
  // Table names
  static const String expenses = 'expenses';
  static const String categories = 'categories';
  static const String wallets = 'wallets';
  static const String reminderSlots = 'reminder_slots';

  // Expenses Columns
  static const String colExpenseId = 'id';
  static const String colExpenseCategoryId = 'category_id';
  static const String colExpenseAmountCents = 'amount_cents';
  static const String colExpenseWalletId = 'wallet_id';
  static const String colExpenseDate = 'expense_date'; // YYYY-MM-DD
  static const String colExpenseTime = 'expense_time'; // HH:mm
  static const String colExpenseNote = 'note';
  static const String colExpenseIsDeleted = 'is_deleted'; // 0 or 1
  static const String colExpenseCreatedAt = 'created_at';
  static const String colExpenseUpdatedAt = 'updated_at';

  // Categories Columns
  static const String colCatId = 'id';
  static const String colCatName = 'name';
  static const String colCatEmoji = 'emoji';
  static const String colCatDefaultAmountCents = 'default_amount_cents';
  static const String colCatIsSystem = 'is_system'; // 0 or 1
  static const String colCatIsDeleted = 'is_deleted'; // 0 or 1

  // Wallets Columns
  static const String colWalletId = 'id';
  static const String colWalletName = 'name';
  static const String colWalletEmoji = 'emoji';

  // Reminder Slots Columns
  static const String colReminderId = 'id';
  static const String colReminderCategoryId = 'category_id';
  static const String colReminderTime = 'time'; // HH:mm
  static const String colReminderDefaultAmountCents = 'default_amount_cents';
  static const String colReminderIsActive = 'is_active'; // 0 or 1
  static const String colReminderIsSystem = 'is_system'; // 0 or 1

  // Wallet Funds (Top-ups / Deposits) Table & Columns
  static const String walletFunds = 'wallet_funds';
  static const String colFundId = 'id';
  static const String colFundWalletId = 'wallet_id';
  static const String colFundAmountCents = 'amount_cents';
  static const String colFundNote = 'note';
  static const String colFundCreatedAt = 'created_at';

  // Wallet Transfers Table & Columns
  static const String walletTransfers = 'wallet_transfers';
  static const String colTransferId = 'id';
  static const String colTransferFromWalletId = 'from_wallet_id';
  static const String colTransferToWalletId = 'to_wallet_id';
  static const String colTransferAmountCents = 'amount_cents';
  static const String colTransferDate = 'transfer_date'; // YYYY-MM-DD
  static const String colTransferTime = 'transfer_time'; // HH:mm
  static const String colTransferNote = 'note';
  static const String colTransferIsDeleted = 'is_deleted'; // 0 or 1
  static const String colTransferCreatedAt = 'created_at';
}
