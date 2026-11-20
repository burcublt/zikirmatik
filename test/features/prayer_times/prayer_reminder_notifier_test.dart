import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_reminder_notifier.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_notification_service.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_reminder_preferences.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_reminder_plan.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';
import 'package:zikirmatik/features/settings/application/settings_notifier.dart';
import 'package:zikirmatik/features/settings/data/settings_repository.dart';

final now = DateTime.now();
final schedule = PrayerSchedule(
  location: const PrayerLocation(
    latitude: 41,
    longitude: 29,
    label: 'İstanbul',
  ),
  timeZone: 'Europe/Istanbul',
  days: [
    PrayerDay(
      date: now,
      entries: [
        PrayerEntry(PrayerName.fajr, now.add(const Duration(hours: 3))),
      ],
    ),
  ],
);

class TestPrayer extends PrayerNotifier {
  @override
  Future<PrayerState> build() async =>
      PrayerState(schedule: schedule, status: PrayerStatus.ready);
}

class TestSettings extends SettingsNotifier {
  @override
  Future<AppSettings> build() async => const AppSettings();
}

class FakeNotifications implements PrayerNotificationService {
  bool allowed = false;
  final requests = <bool>[];
  final scheduled = <Map<PrayerName, PrayerReminderPreference>>[];
  int cancelled = 0;
  @override
  Future<bool> permission({required bool request}) async {
    requests.add(request);
    return allowed;
  }

  @override
  Future<void> schedule(
    PrayerSchedule schedule,
    Map<PrayerName, PrayerReminderPreference> prefs,
    String language,
  ) async {
    scheduled.add(Map.of(prefs));
  }

  @override
  Future<void> cancel() async {
    cancelled++;
  }
}

void main() {
  test(
    'izin reddedilirse anahtar açılmaz; izin verilince tercih ve plan kaydedilir',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final service = FakeNotifications();
      final c = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          prayerNotifierProvider.overrideWith(TestPrayer.new),
          settingsNotifierProvider.overrideWith(TestSettings.new),
          prayerNotificationServiceProvider.overrideWithValue(service),
        ],
      );
      final sub = c.listen(prayerReminderNotifierProvider, (_, _) {});
      addTearDown(() async {
        sub.close();
        c.dispose();
        await db.close();
      });
      await c.read(prayerNotifierProvider.future);
      await c.read(settingsNotifierProvider.future);
      await c.read(prayerReminderNotifierProvider.future);
      final n = c.read(prayerReminderNotifierProvider.notifier);
      expect(await n.setPreference(PrayerName.fajr, enabled: true), isFalse);
      expect(
        c
            .read(prayerReminderNotifierProvider)
            .requireValue[PrayerName.fajr]!
            .enabled,
        isFalse,
      );
      service.allowed = true;
      expect(await n.setPreference(PrayerName.fajr, enabled: true), isTrue);
      expect(await n.setPreference(PrayerName.fajr, minutesBefore: 15), isTrue);
      expect(service.scheduled.last[PrayerName.fajr]!.minutesBefore, 15);
      expect(
        (await c
                .read(prayerReminderPreferencesProvider)
                .read())[PrayerName.fajr]!
            .minutesBefore,
        15,
      );
      expect(await n.setPreference(PrayerName.sunrise, enabled: true), isFalse);
      expect(await n.setPreference(PrayerName.fajr, enabled: false), isTrue);
      expect(service.cancelled, greaterThan(0));
    },
  );
}
