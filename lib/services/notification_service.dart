import 'dart:developer' as developer;
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

  void _log(String message) {
    developer.log(message, name: 'NotificationService');
  }

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
      } catch (e) {
        _log('Error getting local timezone: $e, falling back to UTC');
        resolvedTzName = 'UTC';
      }

      try {
        final location = tz.getLocation(resolvedTzName);
        tz.setLocalLocation(location);
        _log('Timezone initialized to: ${location.name}');
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
            _log('Timezone matched by offset: ${matchingLocation.name}');
          }
        } catch (_) {}
      }
    } catch (e) {
      _log('Timezone init error: $e');
    }

    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_stat_notification',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _log('Notification tapped: ${response.payload}');
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
        _log('App launched from notification: $_pendingPayload');
      }
    }

    _isInitialized = true;
    _log('NotificationService initialized successfully');
  }

  Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      _log('Error checking notification permission: $e');
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
      final status = await Permission.scheduleExactAlarm.status;
      _log('canScheduleExactAlarms status: $status');
      return status.isGranted;
    } catch (e) {
      _log('Error checking scheduleExactAlarm status: $e');
      return false;
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
    } catch (e) {
      _log('Error requesting exact alarms permission: $e');
    }
  }

  Future<bool> isBatteryOptimizationIgnored() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      _log('isBatteryOptimizationIgnored status: $status');
      return status.isGranted;
    } catch (e) {
      _log('Error checking ignoreBatteryOptimizations status: $e');
      return false;
    }
  }

  Future<bool> requestIgnoreBatteryOptimizations() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.request();
      _log('requestIgnoreBatteryOptimizations result: $status');
      return status.isGranted;
    } catch (e) {
      _log('Error requesting ignoreBatteryOptimizations: $e');
      return false;
    }
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
      }

      final notifStatus = await Permission.notification.request();
      _log('Requested notification permission: $notifStatus');
      return notifStatus.isGranted;
    } catch (e) {
      _log('Error in requestPermissions: $e');
      return false;
    }
  }

  Future<void> scheduleDailyReminder(
    ReminderSlot slot,
    String categoryName,
  ) async {
    if (!slot.isActive || slot.id == null) {
      _log('scheduleDailyReminder skipped (isActive=${slot.isActive}, id=${slot.id})');
      return;
    }

    try {
      final notifGranted = await Permission.notification.isGranted;
      _log('scheduleDailyReminder slot #${slot.id} ($categoryName @ ${slot.time}): notifGranted=$notifGranted');
      if (!notifGranted) {
        final requested = await requestPermissions();
        if (!requested) {
          _log('Cannot schedule reminder #${slot.id}: notification permission denied');
          return;
        }
      }

      final exactAlarmGranted = await canScheduleExactAlarms();
      final batteryOptIgnored = await isBatteryOptimizationIgnored();
      _log('Permissions status for #${slot.id}: exactAlarmGranted=$exactAlarmGranted, batteryOptIgnored=$batteryOptIgnored');

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
      _log('Scheduled date/time for #${slot.id}: $scheduledDate (tz: ${tz.local.name})');

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
        icon: '@drawable/ic_stat_notification',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
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
          _log('Attempting exactAllowWhileIdle zonedSchedule for slot #${slot.id}');
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
          _log('Successfully scheduled slot #${slot.id} with exactAllowWhileIdle');
        } catch (e) {
          _log('exactAllowWhileIdle failed for slot #${slot.id}: $e');
        }
      }

      if (!scheduled) {
        try {
          _log('Attempting inexactAllowWhileIdle fallback for slot #${slot.id}');
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
          _log('Successfully scheduled slot #${slot.id} with inexactAllowWhileIdle');
        } catch (e) {
          _log('inexactAllowWhileIdle failed for slot #${slot.id}: $e');
        }
      }
    } catch (e) {
      _log('Error in scheduleDailyReminder: $e');
    }
  }

  Future<void> rescheduleAllReminders(
    List<ReminderSlot> slots,
    Map<int, String> categoryNames,
  ) async {
    _log('Rescheduling all ${slots.length} reminders...');
    for (final slot in slots) {
      if (slot.isActive && slot.id != null) {
        final catName = categoryNames[slot.categoryId] ?? 'Expense Reminder';
        await scheduleDailyReminder(slot, catName);
      }
    }
  }

  Future<void> scheduleReminder(ReminderSlot slot, String categoryName) =>
      scheduleDailyReminder(slot, categoryName);

  Future<void> cancelReminder(int id) async {
    try {
      _log('Canceling notification for reminder #$id');
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      _log('Error canceling reminder #$id: $e');
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      _log('Canceling all scheduled notifications');
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      _log('Error canceling all notifications: $e');
    }
  }
}

