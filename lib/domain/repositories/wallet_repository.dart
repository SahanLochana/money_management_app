import 'package:money_management_app/domain/models/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getAllWallets();
  Future<Wallet?> getWalletById(int id);
}
