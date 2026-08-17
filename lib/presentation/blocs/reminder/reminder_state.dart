import 'package:money_management_app/domain/models/category.dart';
import 'package:money_management_app/domain/models/reminder_slot.dart';

abstract class ReminderState {
  const ReminderState();
}

class ReminderInitial extends ReminderState {
  const ReminderInitial();
}

class ReminderLoading extends ReminderState {
  const ReminderLoading();
}

class ReminderLoaded extends ReminderState {
  final List<ReminderSlot> reminders;
  final List<Category> categories;

  const ReminderLoaded({
    required this.reminders,
    required this.categories,
  });

  Category? getCategory(int categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }
}

class ReminderError extends ReminderState {
  final String message;
  const ReminderError(this.message);
}
