import 'package:money_management_app/data/database/tables.dart';

class WalletFund {
  final int? id;
  final int walletId;
  final int amountCents;
  final String? note;
  final String createdAt;

  const WalletFund({
    this.id,
    required this.walletId,
    required this.amountCents,
    this.note,
    required this.createdAt,
  });

  double get amount => amountCents / 100.0;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) AppTables.colFundId: id,
      AppTables.colFundWalletId: walletId,
      AppTables.colFundAmountCents: amountCents,
      AppTables.colFundNote: note,
      AppTables.colFundCreatedAt: createdAt,
    };
  }

  factory WalletFund.fromMap(Map<String, dynamic> map) {
    return WalletFund(
      id: map[AppTables.colFundId] as int?,
      walletId: map[AppTables.colFundWalletId] as int,
      amountCents: map[AppTables.colFundAmountCents] as int,
      note: map[AppTables.colFundNote] as String?,
      createdAt: map[AppTables.colFundCreatedAt] as String,
    );
  }
}
