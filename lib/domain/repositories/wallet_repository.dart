import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/domain/models/wallet_fund.dart';
import 'package:money_management_app/domain/models/wallet_transfer.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getAllWallets();
  Future<Wallet?> getWalletById(int id);
  Future<int> addFunds(WalletFund fund);
  Future<List<WalletFund>> getFundsForWallet(int walletId);
  Future<Map<int, double>> getAllWalletFundTotals();
  Future<void> deleteFund(int id);

  // Transfers
  Future<int> addTransfer(WalletTransfer transfer);
  Future<void> softDeleteTransfer(int id);
  Future<void> restoreTransfer(int id);
  Future<List<WalletTransfer>> getTodayTransfers();
  Future<List<WalletTransfer>> getAllActiveTransfers();
  Future<Map<String, List<WalletTransfer>>> getTransfersGroupedByDate();
  Future<Map<int, double>> getTransferInTotals();
  Future<Map<int, double>> getTransferOutTotals();
}
