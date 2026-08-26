import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_management_app/domain/repositories/category_repository.dart';
import 'package:money_management_app/domain/repositories/reminder_repository.dart';
import 'package:money_management_app/presentation/blocs/reminder/reminder_event.dart';
import 'package:money_management_app/presentation/blocs/reminder/reminder_state.dart';
import 'package:money_management_app/services/notification_service.dart';

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
        final hasPerm = await NotificationService.instance.hasNotificationPermission();
        if (!hasPerm) {
          final granted = await NotificationService.instance.requestPermissions();
          if (!granted) {
            slotToSave = slotToSave.copyWith(isActive: false);
          }
        }
        if (slotToSave.isActive) {
          final exactGranted = await NotificationService.instance.canScheduleExactAlarms();
          if (!exactGranted) {
            await NotificationService.instance.requestExactAlarmsPermission();
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
        final hasPerm = await NotificationService.instance.hasNotificationPermission();
        if (!hasPerm) {
          final granted = await NotificationService.instance.requestPermissions();
          if (!granted) {
            slotToUpdate = slotToUpdate.copyWith(isActive: false);
          }
        }
        if (slotToUpdate.isActive) {
          final exactGranted = await NotificationService.instance.canScheduleExactAlarms();
          if (!exactGranted) {
            await NotificationService.instance.requestExactAlarmsPermission();
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
        final hasPerm = await NotificationService.instance.hasNotificationPermission();
        if (!hasPerm) {
          final granted = await NotificationService.instance.requestPermissions();
          if (!granted) {
            targetActive = false;
          }
        }
        if (targetActive) {
          final exactGranted = await NotificationService.instance.canScheduleExactAlarms();
          if (!exactGranted) {
            await NotificationService.instance.requestExactAlarmsPermission();
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
