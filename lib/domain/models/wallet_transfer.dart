import 'package:money_management_app/data/database/tables.dart';

class WalletTransfer {
  final int? id;
  final int fromWalletId;
  final int toWalletId;
  final int amountCents;
  final String transferDate; // YYYY-MM-DD
  final String transferTime; // HH:mm
  final String? note;
  final bool isDeleted;
  final String createdAt;

  const WalletTransfer({
    this.id,
    required this.fromWalletId,
    required this.toWalletId,
    required this.amountCents,
    required this.transferDate,
    required this.transferTime,
    this.note,
    this.isDeleted = false,
    required this.createdAt,
  });

  double get amount => amountCents / 100.0;

  String get formattedAmount => 'Rs ${amount.toStringAsFixed(0)}';

  WalletTransfer copyWith({
    int? id,
    int? fromWalletId,
    int? toWalletId,
    int? amountCents,
    String? transferDate,
    String? transferTime,
    String? note,
    bool? isDeleted,
    String? createdAt,
  }) {
    return WalletTransfer(
      id: id ?? this.id,
      fromWalletId: fromWalletId ?? this.fromWalletId,
      toWalletId: toWalletId ?? this.toWalletId,
      amountCents: amountCents ?? this.amountCents,
      transferDate: transferDate ?? this.transferDate,
      transferTime: transferTime ?? this.transferTime,
      note: note ?? this.note,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) AppTables.colTransferId: id,
      AppTables.colTransferFromWalletId: fromWalletId,
      AppTables.colTransferToWalletId: toWalletId,
      AppTables.colTransferAmountCents: amountCents,
      AppTables.colTransferDate: transferDate,
      AppTables.colTransferTime: transferTime,
      AppTables.colTransferNote: note,
      AppTables.colTransferIsDeleted: isDeleted ? 1 : 0,
      AppTables.colTransferCreatedAt: createdAt,
    };
  }

  factory WalletTransfer.fromMap(Map<String, dynamic> map) {
    return WalletTransfer(
      id: map[AppTables.colTransferId] as int?,
      fromWalletId: map[AppTables.colTransferFromWalletId] as int,
      toWalletId: map[AppTables.colTransferToWalletId] as int,
      amountCents: map[AppTables.colTransferAmountCents] as int,
      transferDate: map[AppTables.colTransferDate] as String,
      transferTime: map[AppTables.colTransferTime] as String,
      note: map[AppTables.colTransferNote] as String?,
      isDeleted: (map[AppTables.colTransferIsDeleted] as int? ?? 0) == 1,
      createdAt: map[AppTables.colTransferCreatedAt] as String,
    );
  }
}
