import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

/// Sunrise is a solar event, not a configurable prayer notification.
const reminderPrayerNames = <PrayerName>[
  PrayerName.fajr,
  PrayerName.dhuhr,
  PrayerName.asr,
  PrayerName.maghrib,
  PrayerName.isha,
];
const reminderOffsets = <int>[0, 5, 10, 15, 20, 30, 45, 60];

class PrayerReminderPreference {
  const PrayerReminderPreference({this.enabled = false, this.minutesBefore = 0})
    : assert(minutesBefore >= 0);
  final bool enabled;
  final int minutesBefore;
}

class PlannedPrayerReminder {
  const PlannedPrayerReminder({
    required this.prayer,
    required this.prayerAt,
    required this.notifyAt,
  });
  final PrayerName prayer;
  final DateTime prayerAt;
  final DateTime notifyAt;
}

/// Uses the actual instant in the selected location, including daylight-saving
/// transitions. Never fabricates a missing day's prayer time.
List<PlannedPrayerReminder> planPrayerReminders({
  required PrayerSchedule schedule,
  required Map<PrayerName, PrayerReminderPreference> preferences,
  required DateTime now,
  int limit = 50,
}) {
  if (limit < 0) throw ArgumentError.value(limit, 'limit');
  final result = <PlannedPrayerReminder>[];
  for (final day in schedule.days) {
    for (final entry in day.entries) {
      final preference = preferences[entry.name];
      if (!reminderPrayerNames.contains(entry.name) ||
          preference == null ||
          !preference.enabled) {
        continue;
      }
      if (!reminderOffsets.contains(preference.minutesBefore)) {
        throw ArgumentError.value(preference.minutesBefore, 'minutesBefore');
      }
      final at = entry.at.subtract(Duration(minutes: preference.minutesBefore));
      if (at.isAfter(now)) {
        result.add(
          PlannedPrayerReminder(
            prayer: entry.name,
            prayerAt: entry.at,
            notifyAt: at,
          ),
        );
      }
    }
  }
  result.sort((a, b) => a.notifyAt.compareTo(b.notifyAt));
  return result.take(limit).toList(growable: false);
}
