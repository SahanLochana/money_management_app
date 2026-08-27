import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/domain/models/wallet_fund.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getAllWallets();
  Future<Wallet?> getWalletById(int id);
  Future<int> addFunds(WalletFund fund);
  Future<List<WalletFund>> getFundsForWallet(int walletId);
  Future<Map<int, double>> getAllWalletFundTotals();
  Future<void> deleteFund(int id);
}
