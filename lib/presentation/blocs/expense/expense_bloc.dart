import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management_app/domain/repositories/category_repository.dart';
import 'package:money_management_app/domain/repositories/expense_repository.dart';
import 'package:money_management_app/domain/repositories/wallet_repository.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_event.dart';
import 'package:money_management_app/presentation/blocs/expense/expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository expenseRepository;
  final CategoryRepository categoryRepository;
  final WalletRepository walletRepository;

  ExpenseBloc({
    required this.expenseRepository,
    required this.categoryRepository,
    required this.walletRepository,
  }) : super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<RestoreExpenseEvent>(_onRestoreExpense);
    on<ClearAllExpensesEvent>(_onClearAllExpenses);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());
    try {
      final todayExpenses = await expenseRepository.getTodayExpenses();
      final todayTotal = await expenseRepository.getTodayTotal();
      final grouped = await expenseRepository.getExpensesGroupedByDate();
      final todayTransfers = await walletRepository.getTodayTransfers();
      final groupedTransfers = await walletRepository.getTransfersGroupedByDate();
      final categories = await categoryRepository.getAllCategories();
      final wallets = await walletRepository.getAllWallets();

      emit(ExpenseLoaded(
        todayExpenses: todayExpenses,
        todayTotal: todayTotal,
        groupedExpenses: grouped,
        todayTransfers: todayTransfers,
        groupedTransfers: groupedTransfers,
        categories: categories,
        wallets: wallets,
      ));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onAddExpense(AddExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      await expenseRepository.addExpense(event.expense);
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(UpdateExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      await expenseRepository.updateExpense(event.expense);
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      await expenseRepository.softDeleteExpense(event.id);
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onRestoreExpense(RestoreExpenseEvent event, Emitter<ExpenseState> emit) async {
    try {
      await expenseRepository.restoreExpense(event.id);
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onClearAllExpenses(ClearAllExpensesEvent event, Emitter<ExpenseState> emit) async {
    try {
      await expenseRepository.clearAllData();
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
