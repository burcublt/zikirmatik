import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:zikirmatik/features/prayer_times/domain/prayer_reminder_plan.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

final prayerNotificationServiceProvider = Provider<PrayerNotificationService>(
  (ref) => DevicePrayerNotificationService(),
);

abstract interface class PrayerNotificationService {
  Future<bool> permission({required bool request});
  Future<void> schedule(
    PrayerSchedule schedule,
    Map<PrayerName, PrayerReminderPreference> preferences,
    String language,
  );
  Future<void> cancel();
}

class DevicePrayerNotificationService implements PrayerNotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _init;
  static const firstId = 20000;
  static const count = 50; // Leave room for other iOS pending notifications.
  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  Future<void> _initialize() async {
    ensurePrayerTimeZones();
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

  Future<void> _ready() async {
    try {
      await (_init ??= _initialize());
    } catch (_) {
      _init = null;
      rethrow;
    }
  }

  @override
  Future<bool> permission({required bool request}) async {
    if (!_supported) return false;
    await _ready();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return (request
              ? await android?.requestNotificationsPermission()
              : await android?.areNotificationsEnabled()) ??
          false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return request
        ? (await ios?.requestPermissions(
                alert: true,
                badge: false,
                sound: true,
              ) ??
              false)
        : (await ios?.checkPermissions())?.isEnabled ?? false;
  }

  @override
  Future<void> cancel() async {
    if (!_supported) return;
    await _ready();
    for (var i = 0; i < count; i++) {
      await _plugin.cancel(id: firstId + i);
    }
  }

  @override
  Future<void> schedule(
    PrayerSchedule schedule,
    Map<PrayerName, PrayerReminderPreference> preferences,
    String language,
  ) async {
    if (!_supported) {
      throw UnsupportedError(
        'Prayer notifications are unavailable on this platform',
      );
    }
    await _ready();
    final entries = planPrayerReminders(
      schedule: schedule,
      preferences: preferences,
      now: DateTime.now(),
      limit: count,
    );
    await cancel();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final offset = preferences[entry.prayer]!.minutesBefore;
      final name = _name(entry.prayer, language);
      final title = switch (language) {
        'en' => 'Prayer reminder',
        'ar' => 'تذكير الصلاة',
        _ => 'Namaz vakti hatırlatması',
      };
      final body = switch (language) {
        'en' =>
          offset == 0 ? '$name prayer time' : '$offset minutes until $name',
        'ar' => offset == 0 ? 'حان وقت $name' : 'بقي $offset دقيقة على $name',
        _ => offset == 0 ? '$name vakti' : '$name vaktine $offset dakika kaldı',
      };
      await _plugin.zonedSchedule(
        id: firstId + i,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(entry.notifyAt, schedule.zone),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_reminders',
            'Namaz vakti bildirimleri',
            channelDescription: 'Prayer time reminders',
            importance: Importance.defaultImportance,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  String _name(PrayerName name, String lang) => switch (lang) {
    'en' => switch (name) {
      PrayerName.fajr => 'Fajr',
      PrayerName.dhuhr => 'Dhuhr',
      PrayerName.asr => 'Asr',
      PrayerName.maghrib => 'Maghrib',
      PrayerName.isha => 'Isha',
      PrayerName.sunrise => 'Sunrise',
    },
    'ar' => switch (name) {
      PrayerName.fajr => 'الفجر',
      PrayerName.dhuhr => 'الظهر',
      PrayerName.asr => 'العصر',
      PrayerName.maghrib => 'المغرب',
      PrayerName.isha => 'العشاء',
      PrayerName.sunrise => 'الشروق',
    },
    _ => switch (name) {
      PrayerName.fajr => 'İmsak',
      PrayerName.dhuhr => 'Öğle',
      PrayerName.asr => 'İkindi',
      PrayerName.maghrib => 'Akşam',
      PrayerName.isha => 'Yatsı',
      PrayerName.sunrise => 'Güneş',
    },
  };
}
