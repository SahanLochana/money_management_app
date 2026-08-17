import 'package:money_management_app/data/datasources/reminder_local_datasource.dart';
import 'package:money_management_app/domain/models/reminder_slot.dart';
import 'package:money_management_app/domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDatasource localDatasource;

  ReminderRepositoryImpl({required this.localDatasource});

  @override
  Future<List<ReminderSlot>> getAllReminders() async {
    return await localDatasource.getAllReminders();
  }

  @override
  Future<int> addReminder(ReminderSlot slot) async {
    return await localDatasource.insertReminder(slot);
  }

  @override
  Future<void> updateReminder(ReminderSlot slot) async {
    await localDatasource.updateReminder(slot);
  }

  @override
  Future<void> deleteReminder(int id) async {
    await localDatasource.deleteReminder(id);
  }

  @override
  Future<void> toggleReminder(int id, bool isActive) async {
    await localDatasource.toggleReminder(id, isActive);
  }
}
