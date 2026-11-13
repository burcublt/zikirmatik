import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:zikirmatik/features/settings/data/settings_repository.dart';

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => LocalReminderService(),
);

abstract interface class ReminderService {
  Future<bool> apply(AppSettings settings, {bool requestPermission = false});
}

class LocalReminderService implements ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;
  static const notificationId = 1001;
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  Future<void> _initialize() async {
    tzdata.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_reminder'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> apply(
    AppSettings settings, {
    bool requestPermission = false,
  }) async {
    if (!supported) return false;
    try {
      await (_initializing ??= _initialize());
    } catch (_) {
      _initializing = null;
      rethrow;
    }
    if (!settings.reminderEnabled) {
      await _plugin.cancel(id: notificationId);
      return true;
    }
    var allowed = true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!;
      allowed =
          (requestPermission
              ? await android.requestNotificationsPermission()
              : await android.areNotificationsEnabled()) ??
          false;
    } else {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()!;
      allowed = requestPermission
          ? (await ios.requestPermissions(
                  alert: true,
                  badge: false,
                  sound: true,
                ) ??
                false)
          : (await ios.checkPermissions())?.isEnabled ?? false;
    }
    if (!allowed) {
      await _plugin.cancel(id: notificationId);
      return false;
    }
    // Refresh the local IANA zone when the user changes settings after travelling.
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    final now = tz.TZDateTime.now(tz.local);
    final next = nextReminder(
      now,
      settings.reminderHour,
      settings.reminderMinute,
    );
    final (title, body) = switch (settings.locale.languageCode) {
      'en' => (
        'Time for dhikr',
        'Take a peaceful moment for your daily dhikr.',
      ),
      'ar' => ('حان وقت الذكر', 'خذ لحظة هادئة لأذكارك اليومية.'),
      _ => ('Zikir vakti', 'Günlük zikriniz için huzurlu bir mola verin.'),
    };
    await _plugin.zonedSchedule(
      id: notificationId,
      scheduledDate: next,
      title: title,
      body: body,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_dhikr',
          'Zikirmatik',
          channelDescription: 'Daily dhikr reminder',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
    return true;
  }
}

/// Uses calendar arithmetic so a daily reminder stays at local wall-clock time.
tz.TZDateTime nextReminder(tz.TZDateTime now, int hour, int minute) {
  var next = tz.TZDateTime(
    now.location,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  if (!next.isAfter(now)) {
    next = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day + 1,
      hour,
      minute,
    );
  }
  return next;
}
