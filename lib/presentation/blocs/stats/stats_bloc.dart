import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management_app/domain/repositories/category_repository.dart';
import 'package:money_management_app/domain/repositories/expense_repository.dart';
import 'package:money_management_app/domain/repositories/wallet_repository.dart';
import 'package:money_management_app/presentation/blocs/stats/stats_event.dart';
import 'package:money_management_app/presentation/blocs/stats/stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final ExpenseRepository expenseRepository;
  final CategoryRepository categoryRepository;
  final WalletRepository walletRepository;

  StatsBloc({
    required this.expenseRepository,
    required this.categoryRepository,
    required this.walletRepository,
  }) : super(const StatsInitial()) {
    on<LoadMonthlyStatsEvent>(_onLoadMonthlyStats);
  }

  Future<void> _onLoadMonthlyStats(
    LoadMonthlyStatsEvent event,
    Emitter<StatsState> emit,
  ) async {
    emit(const StatsLoading());
    try {
      final monthlyTotal = await expenseRepository.getMonthlyTotal(event.year, event.month);
      final categoryTotals = await expenseRepository.getMonthlyCategoryTotals(event.year, event.month);
      final walletTotals = await expenseRepository.getMonthlyWalletTotals(event.year, event.month);
      final allCategories = await categoryRepository.getAllCategories();
      final allWallets = await walletRepository.getAllWallets();
      final monthExpenses = await expenseRepository.getExpensesForMonth(event.year, event.month);

      // Build Category Breakdown
      final List<CategorySpending> categoryBreakdown = [];
      for (final cat in allCategories) {
        final amount = categoryTotals[cat.id] ?? 0.0;
        if (amount > 0 || cat.isSystem) {
          final percentage = monthlyTotal > 0 ? (amount / monthlyTotal) * 100 : 0.0;
          categoryBreakdown.add(CategorySpending(
            category: cat,
            amount: amount,
            percentage: percentage,
          ));
        }
      }
      categoryBreakdown.sort((a, b) => b.amount.compareTo(a.amount));

      // Build Wallet Breakdown
      final List<WalletSpending> walletBreakdown = [];
      for (final wallet in allWallets) {
        final amount = walletTotals[wallet.id] ?? 0.0;
        final percentage = monthlyTotal > 0 ? (amount / monthlyTotal) * 100 : 0.0;
        walletBreakdown.add(WalletSpending(
          wallet: wallet,
          amount: amount,
          percentage: percentage,
        ));
      }

      // Recent 5 expenses for the month
      final recentExpenses = monthExpenses.take(5).toList();

      emit(StatsLoaded(
        year: event.year,
        month: event.month,
        monthlyTotal: monthlyTotal,
        categoryBreakdown: categoryBreakdown,
        walletBreakdown: walletBreakdown,
        recentExpenses: recentExpenses,
        allCategories: allCategories,
        allWallets: allWallets,
      ));
    } catch (e) {
      emit(StatsError(e.toString()));
    }
  }
}
