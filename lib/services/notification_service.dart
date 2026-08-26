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

    // ── 1. TIMEZONE SETUP ──────────────────────────────────────────────────
    // FIX: Explicit logging at every step so timezone mismatches are visible.
    // FIX: If tz.getLocation() fails we now apply a UTC-offset fallback
    //      instead of silently leaving tz.local as UTC.
    try {
      tz.initializeTimeZones();

      String resolvedTzName;
      try {
        // flutter_timezone ≥5.0.0 returns TimezoneInfo, not a String.
        // The correct property is .identifier (an IANA string, e.g. "Asia/Colombo").
        // The old dynamic branch called .name/.id which don't exist on TimezoneInfo,
        // caused NoSuchMethodError, was silently caught, and fell back to UTC —
        // causing every scheduled reminder to fire at the wrong local time.
        final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
        resolvedTzName = tzInfo.identifier;
        debugPrint('[NotifService] FlutterTimezone reported: "$resolvedTzName"');
      } catch (e) {
        resolvedTzName = 'UTC';
        debugPrint('[NotifService] FlutterTimezone failed ($e) – defaulting to UTC');
      }

      try {
        final location = tz.getLocation(resolvedTzName);
        tz.setLocalLocation(location);
        final nowLocal = tz.TZDateTime.now(tz.local);
        debugPrint(
          '[NotifService] tz.local set to "${tz.local.name}" '
          '| Current local time: $nowLocal '
          '| UTC offset: ${nowLocal.timeZoneOffset}',
        );
      } catch (e) {
        // FIX: "Asia/Colombo" can sometimes resolve to null on certain TZ
        // databases.  Try a manual UTC-offset approach before giving up.
        debugPrint(
          '[NotifService] tz.getLocation("$resolvedTzName") failed: $e\n'
          '  → Attempting UTC-offset fallback…',
        );
        try {
          final offsetMinutes =
              DateTime.now().timeZoneOffset.inMinutes;
          // Find the first location whose current UTC offset matches.
          final matchingLocation = tz.timeZoneDatabase.locations.values
              .cast<tz.Location?>()
              .firstWhere(
                (loc) {
                  if (loc == null) return false;
                  final nowInLoc = tz.TZDateTime.now(loc);
                  return nowInLoc.timeZoneOffset.inMinutes == offsetMinutes;
                },
                orElse: () => null,
              );
          if (matchingLocation != null) {
            tz.setLocalLocation(matchingLocation);
            debugPrint(
              '[NotifService] UTC-offset fallback: tz.local set to '
              '"${tz.local.name}" (offset +${offsetMinutes}min)',
            );
          } else {
            debugPrint(
              '[NotifService] UTC-offset fallback failed – '
              'no matching location for offset ${offsetMinutes}min. '
              'Leaving tz.local as UTC. Scheduled times will be in UTC!',
            );
          }
        } catch (fallbackErr) {
          debugPrint(
            '[NotifService] UTC-offset fallback threw: $fallbackErr\n'
            'Leaving tz.local as UTC.',
          );
        }
      }
    } catch (e) {
      debugPrint('[NotifService] Timezone initialisation error: $e');
    }

    // ── 2. PLUGIN INITIALISATION ───────────────────────────────────────────
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
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

    // ── 3. EXPLICIT CHANNEL CREATION ───────────────────────────────────────
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
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
      debugPrint('[NotifService] Notification channel "meal_reminders_channel" ensured.');
    }

    // ── 4. LAUNCH-FROM-NOTIFICATION CHECK ─────────────────────────────────
    final details =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      if (details.notificationResponse?.payload != null) {
        _pendingPayload = details.notificationResponse!.payload;
      }
    }

    _isInitialized = true;
    debugPrint('[NotifService] Initialisation complete.');
  }

  // ── PERMISSION HELPERS ────────────────────────────────────────────────────

  Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('[NotifService] Error checking notification permission: $e');
      return false;
    }
  }

  Future<bool> isPermissionPermanentlyDenied() async {
    try {
      return await Permission.notification.isPermanentlyDenied;
    } catch (e) {
      debugPrint('[NotifService] Error checking permanently-denied state: $e');
      return false;
    }
  }

  /// FIX: Separate helper so callers can check exact-alarm permission
  /// independently from the general notification permission.
  Future<bool> canScheduleExactAlarms() async {
    try {
      final granted = await Permission.scheduleExactAlarm.isGranted;
      debugPrint('[NotifService] canScheduleExactAlarms: $granted');
      return granted;
    } catch (e) {
      debugPrint('[NotifService] Error checking scheduleExactAlarm: $e');
      return true; // assume granted when the API itself errors (pre-API-31)
    }
  }

  Future<void> requestExactAlarmsPermission() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestExactAlarmsPermission();
        debugPrint('[NotifService] Exact-alarm permission dialog shown.');
      }
    } catch (e) {
      debugPrint('[NotifService] Error requesting exact alarms permission: $e');
    }
  }

  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  Future<bool> requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }

      final notifStatus = await Permission.notification.request();
      debugPrint(
        '[NotifService] requestPermissions → notification: ${notifStatus.isGranted}',
      );
      return notifStatus.isGranted;
    } catch (e) {
      debugPrint('[NotifService] Error requesting permissions: $e');
      return false;
    }
  }

  // ── SCHEDULING ────────────────────────────────────────────────────────────

  Future<void> scheduleDailyReminder(
    ReminderSlot slot,
    String categoryName,
  ) async {
    if (!slot.isActive || slot.id == null) return;

    try {
      // -- notification permission check -----------------------------------
      final notifGranted = await Permission.notification.isGranted;
      if (!notifGranted) {
        final requested = await requestPermissions();
        debugPrint(
          '[NotifService] scheduleDailyReminder: notification permission '
          'requested → $requested',
        );
        if (!requested) {
          debugPrint('[NotifService] Aborting schedule: notification permission denied.');
          return;
        }
      }

      // FIX: explicit exact-alarm check before scheduling -------------------
      final exactAlarmGranted = await canScheduleExactAlarms();
      debugPrint(
        '[NotifService] scheduleDailyReminder: '
        'exactAlarm granted=$exactAlarmGranted  |  '
        'tz.local="${tz.local.name}"',
      );
      if (!exactAlarmGranted) {
        debugPrint(
          '[NotifService] WARN: SCHEDULE_EXACT_ALARM not granted. '
          'Will attempt inexact scheduling – alarm may be delayed by Android Doze.',
        );
      }

      // -- compute fire time -----------------------------------------------
      final parts = slot.time.split(':');
      if (parts.length != 2) {
        debugPrint('[NotifService] Invalid slot.time format: "${slot.time}"');
        return;
      }
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

      debugPrint(
        '[NotifService] scheduleDailyReminder #${slot.id}: '
        'slot.time="${slot.time}"  |  '
        'now=$now  |  '
        'scheduledDate=$scheduledDate  |  '
        'tz.local="${tz.local.name}"',
      );

      const androidDetails = AndroidNotificationDetails(
        'meal_reminders_channel',
        'Meal Reminders',
        channelDescription: 'Daily expense reminders for meal times',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const notificationDetails = NotificationDetails(android: androidDetails);
      final payload =
          '${slot.categoryId}|${slot.defaultAmountCents}|${slot.id}';

      // -- attempt exact, then fall back to inexact ------------------------
      bool scheduled = false;

      if (exactAlarmGranted) {
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
          debugPrint(
            '[NotifService] ✓ Exact alarm scheduled #${slot.id} '
            'at $scheduledDate (daily @ ${slot.time})',
          );
          scheduled = true;
        } catch (e, st) {
          debugPrint(
            '[NotifService] Exact alarm failed for #${slot.id}:\n'
            '  type: ${e.runtimeType}\n'
            '  msg:  $e\n'
            '  stack: $st',
          );
        }
      }

      if (!scheduled) {
        // FIX: inexact fallback now has its own try/catch with full details
        try {
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
          debugPrint(
            '[NotifService] ✓ Inexact alarm scheduled #${slot.id} '
            'at $scheduledDate (daily @ ${slot.time}) – may be delayed by Doze',
          );
        } catch (e, st) {
          // FIX: loud failure – type + message + full stack trace
          debugPrint(
            '[NotifService] ✗ INEXACT alarm also failed for #${slot.id}:\n'
            '  type: ${e.runtimeType}\n'
            '  msg:  $e\n'
            '  stack: $st',
          );
          return;
        }
      }

      // FIX: post-schedule verification ─────────────────────────────────────
      // If the pending list is empty right after scheduling, the alarm was
      // rejected by Android (e.g. battery-saver policy, wrong channel, etc.).
      // Cross-check with: adb shell dumpsys alarm | grep <package>
      final pending =
          await _notificationsPlugin.pendingNotificationRequests();
      final pendingSummary = pending
          .map((p) => '#${p.id}(${p.title})')
          .join(', ');
      debugPrint(
        '[NotifService] Post-schedule pending count=${pending.length} '
        '→ [$pendingSummary]',
      );
      if (pending.isEmpty) {
        debugPrint(
          '[NotifService] ⚠ WARNING: pendingNotificationRequests() is empty '
          'immediately after scheduling. The OS may have rejected the alarm. '
          'Run: adb shell dumpsys alarm | grep ${slot.id} to inspect.',
        );
      }
    } catch (e, st) {
      debugPrint(
        '[NotifService] Unexpected error in scheduleDailyReminder:\n'
        '  type: ${e.runtimeType}  msg: $e\n  stack: $st',
      );
    }
  }

  Future<void> scheduleReminder(ReminderSlot slot, String categoryName) =>
      scheduleDailyReminder(slot, categoryName);

  Future<void> cancelReminder(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint('[NotifService] Cancelled reminder #$id');
    } catch (e) {
      debugPrint('[NotifService] Error cancelling reminder #$id: $e');
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('[NotifService] Cancelled all reminders');
    } catch (e) {
      debugPrint('[NotifService] Error cancelling all reminders: $e');
    }
  }
}
