import 'package:money_management_app/data/database/tables.dart';

class Wallet {
  final int id;
  final String name;
  final String emoji;

  const Wallet({
    required this.id,
    required this.name,
    required this.emoji,
  });

  Map<String, dynamic> toMap() {
    return {
      AppTables.colWalletId: id,
      AppTables.colWalletName: name,
      AppTables.colWalletEmoji: emoji,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map[AppTables.colWalletId] as int,
      name: map[AppTables.colWalletName] as String,
      emoji: map[AppTables.colWalletEmoji] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallet &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
