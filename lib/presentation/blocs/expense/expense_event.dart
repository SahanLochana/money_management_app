import 'package:money_management_app/domain/models/expense.dart';

abstract class ExpenseEvent {
  const ExpenseEvent();
}

class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();
}

class AddExpenseEvent extends ExpenseEvent {
  final Expense expense;
  const AddExpenseEvent(this.expense);
}

class UpdateExpenseEvent extends ExpenseEvent {
  final Expense expense;
  const UpdateExpenseEvent(this.expense);
}

class DeleteExpenseEvent extends ExpenseEvent {
  final int id;
  const DeleteExpenseEvent(this.id);
}

class RestoreExpenseEvent extends ExpenseEvent {
  final int id;
  const RestoreExpenseEvent(this.id);
}

class ClearAllExpensesEvent extends ExpenseEvent {
  const ClearAllExpensesEvent();
}
