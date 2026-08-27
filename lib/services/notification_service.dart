import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:money_management_app/domain/models/reminder_slot.dart';
import 'package:money_management_app/presentation/theme/app_colors.dart';
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

      String resolvedTzName;
      try {
        final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
        resolvedTzName = tzInfo.identifier;
      } catch (_) {
        resolvedTzName = 'UTC';
      }

      try {
        final location = tz.getLocation(resolvedTzName);
        tz.setLocalLocation(location);
      } catch (_) {
        try {
          final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
          final matchingLocation = tz.timeZoneDatabase.locations.values
              .cast<tz.Location?>()
              .firstWhere((loc) {
                if (loc == null) return false;
                final nowInLoc = tz.TZDateTime.now(loc);
                return nowInLoc.timeZoneOffset.inMinutes == offsetMinutes;
              }, orElse: () => null);
          if (matchingLocation != null) {
            tz.setLocalLocation(matchingLocation);
          }
        } catch (_) {}
      }
    } catch (_) {}

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
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

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'meal_reminders_channel',
          'Meal Reminders',
          description: 'Daily expense reminders for meal times',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    final details = await _notificationsPlugin
        .getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      if (details.notificationResponse?.payload != null) {
        _pendingPayload = details.notificationResponse!.payload;
      }
    }

    _isInitialized = true;
  }

  Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isPermissionPermanentlyDenied() async {
    try {
      return await Permission.notification.isPermanentlyDenied;
    } catch (_) {
      return false;
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    try {
      return await Permission.scheduleExactAlarm.isGranted;
    } catch (_) {
      return true;
    }
  }

  Future<void> requestExactAlarmsPermission() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (_) {}
  }

  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  Future<bool> requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }

      final notifStatus = await Permission.notification.request();
      return notifStatus.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<void> scheduleDailyReminder(
    ReminderSlot slot,
    String categoryName,
  ) async {
    if (!slot.isActive || slot.id == null) return;

    try {
      final notifGranted = await Permission.notification.isGranted;
      if (!notifGranted) {
        final requested = await requestPermissions();
        if (!requested) return;
      }

      final exactAlarmGranted = await canScheduleExactAlarms();

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

      final String amountStr = slot.defaultAmount > 0
          ? 'Rs ${slot.defaultAmount.toStringAsFixed(0)}'
          : '';
      final String notificationTitle = '$categoryName Reminder';
      final String notificationBody = amountStr.isNotEmpty
          ? 'Add expense: $amountStr?'
          : 'Ready to track your expense?';

      final bigTextStyleInformation = BigTextStyleInformation(
        amountStr.isNotEmpty
            ? '⚡ Time to log your expense!\nSuggested amount: $amountStr\nTap to record in 1 tap.'
            : 'Keep your budget on track by logging your expense.',
        contentTitle: notificationTitle,
        summaryText: 'Daily Reminder',
      );

      final androidDetails = AndroidNotificationDetails(
        'meal_reminders_channel',
        'Meal Reminders',
        channelDescription: 'Daily expense reminders for meal times',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        color: AppColors.primary,
        category: AndroidNotificationCategory.reminder,
        subText: 'Daily Reminder',
        ticker: 'Time to track your expense!',
        styleInformation: bigTextStyleInformation,
        vibrationPattern: Int64List.fromList([0, 50, 0, 50]),
      );
      final notificationDetails = NotificationDetails(android: androidDetails);
      final payload =
          '${slot.categoryId}|${slot.defaultAmountCents}|${slot.id}';

      bool scheduled = false;

      if (exactAlarmGranted) {
        try {
          await _notificationsPlugin.zonedSchedule(
            slot.id!,
            notificationTitle,
            notificationBody,
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: payload,
          );
          scheduled = true;
        } catch (_) {}
      }

      if (!scheduled) {
        try {
          await _notificationsPlugin.zonedSchedule(
            slot.id!,
            notificationTitle,
            notificationBody,
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: payload,
          );
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> scheduleReminder(ReminderSlot slot, String categoryName) =>
      scheduleDailyReminder(slot, categoryName);

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
