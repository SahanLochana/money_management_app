import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:money_management_app/domain/models/reminder_slot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _pendingPayload;

  NotificationService._init();

  String? get pendingPayload => _pendingPayload;

  void clearPendingPayload() {
    _pendingPayload = null;
  }

  Future<void> initialize({
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
  }) async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = tzResult is String ? tzResult : (tzResult.name ?? tzResult.id ?? tzResult.toString());
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Failed to set local timezone ($e), falling back to tz.local');
    }

    // 2. Initialize notification settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _pendingPayload = response.payload;
        }
        if (onDidReceiveNotificationResponse != null) {
          onDidReceiveNotificationResponse(response);
        }
      },
    );

    // 3. Check if app was launched via notification tap
    final details = await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      if (details.notificationResponse?.payload != null) {
        _pendingPayload = details.notificationResponse!.payload;
      }
    }

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }

      final notifStatus = await Permission.notification.request();
      return notifStatus.isGranted;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> scheduleDailyReminder(ReminderSlot slot, String categoryName) async {
    if (!slot.isActive || slot.id == null) return;

    try {
      final isGranted = await Permission.notification.isGranted;
      if (!isGranted) {
        final requested = await requestPermissions();
        if (!requested) return;
      }

      final parts = slot.time.split(':');
      if (parts.length != 2) return;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'meal_reminders_channel',
        'Meal Reminders',
        channelDescription: 'Daily expense reminders for meal times',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(android: androidDetails);
      final payload = '${slot.categoryId}|${slot.defaultAmountCents}|${slot.id}';

      try {
        await _notificationsPlugin.zonedSchedule(
          slot.id!,
          categoryName,
          'Add expense: Rs ${slot.defaultAmount.toStringAsFixed(0)}?',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
        debugPrint('Scheduled reminder #${slot.id} at $scheduledDate (daily at ${slot.time})');
      } catch (e) {
        debugPrint('Exact alarm scheduling failed, falling back to inexact: $e');
        await _notificationsPlugin.zonedSchedule(
          slot.id!,
          categoryName,
          'Add expense: Rs ${slot.defaultAmount.toStringAsFixed(0)}?',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
        debugPrint('Scheduled reminder (inexact) #${slot.id} at $scheduledDate (daily at ${slot.time})');
      }
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  Future<void> scheduleReminder(ReminderSlot slot, String categoryName) =>
      scheduleDailyReminder(slot, categoryName);

  Future<void> cancelReminder(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint('Cancelled reminder #$id');
    } catch (e) {
      debugPrint('Error cancelling reminder #$id: $e');
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('Cancelled all reminders');
    } catch (e) {
      debugPrint('Error cancelling all reminders: $e');
    }
  }
}
