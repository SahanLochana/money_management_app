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
      final id = await reminderRepository.addReminder(event.slot);
      final cat = await categoryRepository.getCategoryById(event.slot.categoryId);
      if (event.slot.isActive) {
        await NotificationService.instance.scheduleReminder(
          event.slot.copyWith(id: id),
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
      await reminderRepository.updateReminder(event.slot);
      if (event.slot.id != null) {
        final cat = await categoryRepository.getCategoryById(event.slot.categoryId);
        if (event.slot.isActive) {
          await NotificationService.instance.scheduleReminder(
            event.slot,
            cat?.name ?? 'Expense Reminder',
          );
        } else {
          await NotificationService.instance.cancelReminder(event.slot.id!);
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
      await reminderRepository.toggleReminder(event.id, event.isActive);
      if (event.isActive) {
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
