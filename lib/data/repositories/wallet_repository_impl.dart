import 'package:money_management_app/data/datasources/wallet_local_datasource.dart';
import 'package:money_management_app/domain/models/wallet.dart';
import 'package:money_management_app/domain/models/wallet_fund.dart';
import 'package:money_management_app/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDatasource localDatasource;

  WalletRepositoryImpl({required this.localDatasource});

  @override
  Future<List<Wallet>> getAllWallets() async {
    return await localDatasource.getAllWallets();
  }

  @override
  Future<Wallet?> getWalletById(int id) async {
    return await localDatasource.getWalletById(id);
  }

  @override
  Future<int> addFunds(WalletFund fund) async {
    return await localDatasource.insertWalletFund(fund.toMap());
  }

  @override
  Future<List<WalletFund>> getFundsForWallet(int walletId) async {
    final list = await localDatasource.getFundsForWallet(walletId);
    return list.map((e) => WalletFund.fromMap(e)).toList();
  }

  @override
  Future<Map<int, double>> getAllWalletFundTotals() async {
    final map = await localDatasource.getAllWalletFundTotalsCents();
    return map.map((key, value) => MapEntry(key, value / 100.0));
  }

  @override
  Future<void> deleteFund(int id) async {
    await localDatasource.deleteWalletFund(id);
  }
}
