import 'package:money_management_app/data/datasources/wallet_local_datasource.dart';
import 'package:money_management_app/domain/models/wallet.dart';
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
}
