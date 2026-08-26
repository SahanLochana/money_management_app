import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management_app/domain/repositories/category_repository.dart';
import 'package:money_management_app/domain/repositories/reminder_repository.dart';
import 'package:money_management_app/presentation/blocs/reminder/reminder_event.dart';
import 'package:money_management_app/presentation/blocs/reminder/reminder_state.dart';
import 'package:money_management_app/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository reminderRepository;
  final CategoryRepository categoryRepository;

  ReminderBloc({
    required this.reminderRepository,
    required this.categoryRepository,
  }) : super(const ReminderInitial()) {
    on<LoadRemindersEvent>(_onLoadReminders);
    on<AddReminderEvent>(_onAddReminder);
    on<UpdateReminderEvent>(_onUpdateReminder);
    on<DeleteReminderEvent>(_onDeleteReminder);
    on<ToggleReminderEvent>(_onToggleReminder);
  }

  Future<void> _onLoadReminders(
    LoadRemindersEvent event,
    Emitter<ReminderState> emit,
  ) async {
    emit(const ReminderLoading());
    try {
      final reminders = await reminderRepository.getAllReminders();
      final categories = await categoryRepository.getAllCategories();
      emit(ReminderLoaded(reminders: reminders, categories: categories));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onAddReminder(
    AddReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      var slotToSave = event.slot;
      if (slotToSave.isActive) {
        // Check notification permission
        final hasPerm = await NotificationService.instance.hasNotificationPermission();
        if (!hasPerm) {
          final granted = await NotificationService.instance.requestPermissions();
          if (!granted) {
            debugPrint('[ReminderBloc] Add: notification permission denied – saving as inactive.');
            slotToSave = slotToSave.copyWith(isActive: false);
          }
        }
        // FIX: also check exact-alarm permission independently
        if (slotToSave.isActive) {
          final exactGranted = await NotificationService.instance.canScheduleExactAlarms();
          debugPrint('[ReminderBloc] Add: exactAlarm granted=$exactGranted');
          if (!exactGranted) {
            debugPrint('[ReminderBloc] Add: requesting exact-alarm permission.');
            await NotificationService.instance.requestExactAlarmsPermission();
            // Re-check after request (user may have just granted it)
            final recheck = await Permission.scheduleExactAlarm.isGranted;
            debugPrint('[ReminderBloc] Add: exactAlarm after request=$recheck');
          }
        }
      }

      final id = await reminderRepository.addReminder(slotToSave);
      final cat = await categoryRepository.getCategoryById(slotToSave.categoryId);
      if (slotToSave.isActive) {
        await NotificationService.instance.scheduleReminder(
          slotToSave.copyWith(id: id),
          cat?.name ?? 'Expense Reminder',
        );
      }
      add(const LoadRemindersEvent());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onUpdateReminder(
    UpdateReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      var slotToUpdate = event.slot;
      if (slotToUpdate.isActive) {
        // Check notification permission
        final hasPerm = await NotificationService.instance.hasNotificationPermission();
        if (!hasPerm) {
          final granted = await NotificationService.instance.requestPermissions();
          if (!granted) {
            debugPrint('[ReminderBloc] Update: notification permission denied – saving as inactive.');
            slotToUpdate = slotToUpdate.copyWith(isActive: false);
          }
        }
        // FIX: also check exact-alarm permission independently
        if (slotToUpdate.isActive) {
          final exactGranted = await NotificationService.instance.canScheduleExactAlarms();
          debugPrint('[ReminderBloc] Update: exactAlarm granted=$exactGranted');
          if (!exactGranted) {
            await NotificationService.instance.requestExactAlarmsPermission();
            final recheck = await Permission.scheduleExactAlarm.isGranted;
            debugPrint('[ReminderBloc] Update: exactAlarm after request=$recheck');
          }
        }
      }

      await reminderRepository.updateReminder(slotToUpdate);
      if (slotToUpdate.id != null) {
        final cat = await categoryRepository.getCategoryById(slotToUpdate.categoryId);
        if (slotToUpdate.isActive) {
          await NotificationService.instance.scheduleReminder(
            slotToUpdate,
            cat?.name ?? 'Expense Reminder',
          );
        } else {
          await NotificationService.instance.cancelReminder(slotToUpdate.id!);
        }
      }
      add(const LoadRemindersEvent());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await NotificationService.instance.cancelReminder(event.id);
      await reminderRepository.deleteReminder(event.id);
      add(const LoadRemindersEvent());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> _onToggleReminder(
    ToggleReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      bool targetActive = event.isActive;
      if (targetActive) {
        // Check notification permission
        final hasPerm = await NotificationService.instance.hasNotificationPermission();
        if (!hasPerm) {
          final granted = await NotificationService.instance.requestPermissions();
          if (!granted) {
            debugPrint('[ReminderBloc] Toggle: notification permission denied – keeping inactive.');
            targetActive = false;
          }
        }
        // FIX: also check exact-alarm permission independently
        if (targetActive) {
          final exactGranted = await NotificationService.instance.canScheduleExactAlarms();
          debugPrint('[ReminderBloc] Toggle: exactAlarm granted=$exactGranted');
          if (!exactGranted) {
            await NotificationService.instance.requestExactAlarmsPermission();
            final recheck = await Permission.scheduleExactAlarm.isGranted;
            debugPrint('[ReminderBloc] Toggle: exactAlarm after request=$recheck');
          }
        }
      }

      await reminderRepository.toggleReminder(event.id, targetActive);
      if (targetActive) {
        final reminders = await reminderRepository.getAllReminders();
        final slot = reminders.firstWhere((r) => r.id == event.id);
        final cat = await categoryRepository.getCategoryById(slot.categoryId);
        await NotificationService.instance.scheduleReminder(
          slot,
          cat?.name ?? 'Expense Reminder',
        );
      } else {
        await NotificationService.instance.cancelReminder(event.id);
      }
      add(const LoadRemindersEvent());
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }
}
