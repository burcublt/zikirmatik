import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

void main() {
  late PrayerSchedule schedule;
  setUp(() {
    ensurePrayerTimeZones();
    final raw =
        jsonDecode(
              File(
                'test/fixtures/prayer_calendar_istanbul.json',
              ).readAsStringSync(),
            )
            as Map;
    final zone = tz.getLocation('Europe/Istanbul');
    schedule = PrayerSchedule(
      location: const PrayerLocation(
        latitude: 41.01,
        longitude: 28.98,
        label: 'İstanbul',
      ),
      timeZone: zone.name,
      days: [
        for (final row in raw['data'] as List)
          parsePrayerDay(Map<String, dynamic>.from(row as Map), zone),
      ],
    );
  });
  test(
    'sabah vakti Fajr alanından gelir; güneş sıradaki namaza dahil edilmez',
    () {
      final day = schedule.dayAt(DateTime.utc(2026, 11, 13, 5))!;
      expect(formatHour(day.entries.first.at), '06:14');
      expect(
        schedule.nextPrayer(DateTime.utc(2026, 11, 13, 3, 20))!.name,
        PrayerName.dhuhr,
      );
    },
  );
  test(
    'yatsıdan sonra ertesi gün imsak seçilir ve geri sayım negatif olmaz',
    () {
      final next = schedule.nextPrayer(DateTime.utc(2026, 11, 13, 18))!;
      expect(next.name, PrayerName.fajr);
      expect(next.at.day, 14);
      expect(prayerCountdown(const Duration(seconds: -5)), '00:00:00');
      expect(
        prayerCountdown(const Duration(hours: 2, minutes: 15, seconds: 26)),
        '02:15:26',
      );
    },
  );
  test('cihaz saat diliminden bağımsız konumun yerel tarihini kullanır', () {
    final instant = DateTime.utc(2026, 11, 13, 22, 30);
    expect(schedule.dayAt(instant)!.date.day, 14);
    final restored = PrayerSchedule.fromJson(schedule.toJson());
    expect(restored.nextPrayer(instant)!.at, schedule.nextPrayer(instant)!.at);
  });
  test(
    'vakit sınırında bir sonraki namaza geçer ve bozuk saat kabul edilmez',
    () {
      final noon = schedule
          .dayAt(DateTime.utc(2026, 11, 13, 5))!
          .entries
          .firstWhere((e) => e.name == PrayerName.dhuhr);
      expect(schedule.nextPrayer(noon.at)!.name, PrayerName.asr);
      final raw = {
        'date': {
          'gregorian': {
            'year': '2026',
            'month': {'number': 11},
            'day': '13',
          },
        },
        'timings': {'Fajr': '--:--'},
      };
      expect(
        () => parsePrayerDay(raw, tz.getLocation('Europe/Istanbul')),
        throwsFormatException,
      );
    },
  );
}

String formatHour(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
