import 'package:money_management_app/domain/models/reminder_slot.dart';

abstract class ReminderRepository {
  Future<List<ReminderSlot>> getAllReminders();
  Future<int> addReminder(ReminderSlot slot);
  Future<void> updateReminder(ReminderSlot slot);
  Future<void> deleteReminder(int id);
  Future<void> toggleReminder(int id, bool isActive);
}
