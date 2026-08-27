import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management_app/domain/repositories/expense_repository.dart';
import 'package:money_management_app/domain/repositories/wallet_repository.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_event.dart';
import 'package:money_management_app/presentation/blocs/wallet/wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;
  final ExpenseRepository expenseRepository;

  WalletBloc({
    required this.walletRepository,
    required this.expenseRepository,
  }) : super(const WalletInitial()) {
    on<LoadWalletsEvent>(_onLoadWallets);
    on<AddWalletFundsEvent>(_onAddWalletFunds);
    on<DeleteWalletFundEvent>(_onDeleteWalletFund);
  }

  Future<void> _onLoadWallets(
    LoadWalletsEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final wallets = await walletRepository.getAllWallets();
      final fundTotals = await walletRepository.getAllWalletFundTotals();
      final expenseTotals = await expenseRepository.getAllWalletExpenseTotals();

      final Map<int, double> balances = {};
      for (final w in wallets) {
        final funds = fundTotals[w.id] ?? 0.0;
        final spent = expenseTotals[w.id] ?? 0.0;
        balances[w.id] = funds - spent;
      }

      emit(
        WalletLoaded(
          wallets: wallets,
          balances: balances,
          totalFunds: fundTotals,
          totalSpent: expenseTotals,
        ),
      );
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onAddWalletFunds(
    AddWalletFundsEvent event,
    Emitter<WalletState> emit,
  ) async {
    try {
      await walletRepository.addFunds(event.fund);
      add(const LoadWalletsEvent());
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> _onDeleteWalletFund(
    DeleteWalletFundEvent event,
    Emitter<WalletState> emit,
  ) async {
    try {
      await walletRepository.deleteFund(event.fundId);
      add(const LoadWalletsEvent());
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
