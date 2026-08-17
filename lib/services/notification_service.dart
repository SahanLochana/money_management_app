import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:money_management_app/domain/models/reminder_slot.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize({
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
  }) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<bool> requestPermissions() async {
    final notifStatus = await Permission.notification.request();
    return notifStatus.isGranted;
  }

  Future<void> scheduleReminder(ReminderSlot slot, String categoryName) async {
    if (!slot.isActive || slot.id == null) return;

    try {
      final isGranted = await Permission.notification.isGranted;
      if (!isGranted) return;

      const androidDetails = AndroidNotificationDetails(
        'meal_reminders_channel',
        'Meal Reminders',
        channelDescription: 'Daily expense reminders for meal times',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      // Simple notification dispatch / schedule stub
      await _notificationsPlugin.show(
        slot.id!,
        categoryName,
        'Add expense: ₹${slot.defaultAmount.toStringAsFixed(0)}?',
        notificationDetails,
        payload: '${slot.categoryId}|${slot.defaultAmountCents}|${slot.id}',
      );
    } catch (_) {
      // Gracefully handle any platform exception
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (_) {}
  }

  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }
}
