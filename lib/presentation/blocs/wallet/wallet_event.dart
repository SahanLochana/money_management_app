import 'package:money_management_app/domain/models/wallet_fund.dart';

abstract class WalletEvent {
  const WalletEvent();
}

class LoadWalletsEvent extends WalletEvent {
  const LoadWalletsEvent();
}

class AddWalletFundsEvent extends WalletEvent {
  final WalletFund fund;
  const AddWalletFundsEvent(this.fund);
}

class DeleteWalletFundEvent extends WalletEvent {
  final int fundId;
  const DeleteWalletFundEvent(this.fundId);
}
