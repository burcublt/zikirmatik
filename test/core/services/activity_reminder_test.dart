import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;
import 'package:zikirmatik/core/services/counter_feedback.dart';
import 'package:zikirmatik/core/services/reminder_service.dart';

void main() {
  test('ilk dokunuş, arka plan ve uzun aralar aktif süreye eklenmez', () {
    var elapsed = Duration.zero;
    var now = DateTime(2026, 11, 12, 23, 59, 58);
    final clock = TapActivityClock(elapsed: () => elapsed, now: () => now);
    expect(clock.tap(), 0);
    elapsed += const Duration(seconds: 2);
    expect(clock.tap(), 2000);
    clock.pause();
    elapsed += const Duration(minutes: 2);
    expect(clock.tap(), 0);
    elapsed += const Duration(seconds: 31);
    expect(clock.tap(), 0);
    elapsed += const Duration(milliseconds: 500);
    expect(clock.tap(), 500);
    now = DateTime(2026, 11, 13);
    elapsed += const Duration(seconds: 1);
    expect(clock.tap(), 0);
  });
  test(
    'hatırlatma geçmişse ertesi güne, yaz saati geçişinde aynı yerel saate kurulur',
    () {
      data.initializeTimeZones();
      final istanbul = tz.getLocation('Europe/Istanbul');
      final next = nextReminder(
        tz.TZDateTime(istanbul, 2026, 11, 12, 20, 1),
        20,
        0,
      );
      expect(next.day, 13);
      expect(next.hour, 20);
      final london = tz.getLocation('Europe/London');
      final dst = nextReminder(tz.TZDateTime(london, 2026, 3, 28, 21), 20, 0);
      expect(dst.day, 29);
      expect(dst.hour, 20);
      expect(dst.timeZoneOffset, const Duration(hours: 1));
    },
  );
}
