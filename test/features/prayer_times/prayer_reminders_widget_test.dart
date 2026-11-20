import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/theme/app_theme.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_reminder_notifier.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_reminder_plan.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_times_page.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';

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
        for (final name in PrayerName.values)
          PrayerEntry(name, now.add(Duration(hours: name.index + 1))),
      ],
    ),
  ],
);

class FakePrayer extends PrayerNotifier {
  @override
  Future<PrayerState> build() async =>
      PrayerState(schedule: schedule, status: PrayerStatus.ready);
}

class FakeReminders extends PrayerReminderNotifier {
  @override
  Future<Map<PrayerName, PrayerReminderPreference>> build() async => {
    for (final n in reminderPrayerNames) n: const PrayerReminderPreference(),
  };
  @override
  Future<bool> setPreference(
    PrayerName name, {
    bool? enabled,
    int? minutesBefore,
  }) async {
    final old = state.requireValue[name]!;
    state = AsyncData({
      ...state.requireValue,
      name: PrayerReminderPreference(
        enabled: enabled ?? old.enabled,
        minutesBefore: minutesBefore ?? old.minutesBefore,
      ),
    });
    return true;
  }
}

void main() {
  testWidgets(
    'vakitlerde beş anahtar ve zaman seçimi var, güneşte anahtar yok',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prayerNotifierProvider.overrideWith(FakePrayer.new),
            prayerReminderNotifierProvider.overrideWith(FakeReminders.new),
            prayerClockProvider.overrideWith((ref) => Stream.value(now)),
          ],
          child: MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.dark(),
            home: const PrayerTimesPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('prayer-row-sunrise')), findsNothing);
      for (final n in reminderPrayerNames) {
        expect(find.byKey(ValueKey('prayer-row-${n.name}')), findsOneWidget);
      }
      await tester.drag(find.byType(ListView).first, const Offset(0, -350));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alarm ve Hatırlatmalar'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('prayer-alert-sunrise')), findsNothing);
      expect(find.byKey(const ValueKey('prayer-alert-fajr')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('prayer-alert-fajr')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Switch>(find.byKey(const ValueKey('prayer-alert-fajr')))
            .value,
        isTrue,
      );
      await tester.tap(find.text('Tam vaktinde').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('15 dakika önce').last);
      await tester.pumpAndSettle();
      expect(find.text('15 dakika önce'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
