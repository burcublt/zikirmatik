import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_reminder_plan.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

void main() {
  const place = PrayerLocation(latitude: 41, longitude: 29, label: 'İstanbul');
  final day = DateTime.utc(2026, 11, 16);
  final schedule = PrayerSchedule(
    location: place,
    timeZone: 'Europe/Istanbul',
    days: [
      PrayerDay(
        date: day,
        entries: [
          PrayerEntry(PrayerName.fajr, day.add(const Duration(hours: 4))),
          PrayerEntry(PrayerName.sunrise, day.add(const Duration(hours: 5))),
          PrayerEntry(PrayerName.dhuhr, day.add(const Duration(hours: 10))),
        ],
      ),
    ],
  );
  test(
    'yalnız açık namazları doğru dakika öncesine planlar; güneşi dışlar',
    () {
      final result = planPrayerReminders(
        schedule: schedule,
        now: day,
        preferences: {
          PrayerName.fajr: const PrayerReminderPreference(
            enabled: true,
            minutesBefore: 15,
          ),
          PrayerName.sunrise: const PrayerReminderPreference(enabled: true),
          PrayerName.dhuhr: const PrayerReminderPreference(enabled: false),
        },
      );
      expect(result.length, 1);
      expect(result.single.prayer, PrayerName.fajr);
      expect(
        result.single.notifyAt,
        day.add(const Duration(hours: 3, minutes: 45)),
      );
    },
  );
  test('geçmiş bildirimleri atlar ve hatalı süreyi reddeder', () {
    expect(
      planPrayerReminders(
        schedule: schedule,
        now: day.add(const Duration(hours: 5)),
        preferences: {
          PrayerName.fajr: const PrayerReminderPreference(enabled: true),
        },
      ),
      isEmpty,
    );
    expect(
      () => planPrayerReminders(
        schedule: schedule,
        now: day,
        preferences: {
          PrayerName.fajr: const PrayerReminderPreference(
            enabled: true,
            minutesBefore: 7,
          ),
        },
      ),
      throwsArgumentError,
    );
  });
}
