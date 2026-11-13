import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:zikirmatik/app/theme/app_theme.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/data/annual_prayer_repository.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_location_service.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_times_page.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';

class _NoLocation implements PrayerLocationService {
  @override
  Future<PrayerLocation> current({required bool requestPermission}) async =>
      throw const PrayerLocationException(PrayerLocationIssue.denied);
  @override
  Future<PrayerLocation> findCity(String city) async =>
      throw StateError('Annual selection must not use geocoding');
}

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 80; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets);
}

void main() {
  testWidgets(
    'internet ve konum olmadan bölge seçilip gerçek yıllık vakitler açılır',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final client = MockClient(
        (r) async => throw StateError('Network forbidden'),
      );
      addTearDown(client.close);
      final now = DateTime.utc(2026, 11, 13, 10);
      final repo = AnnualPrayerRepository(
        db,
        client,
        (path) async => File(path).readAsString(),
        now: () => now,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prayerRepositoryProvider.overrideWithValue(repo),
            prayerLocationServiceProvider.overrideWithValue(_NoLocation()),
            prayerClockProvider.overrideWith((ref) => Stream.value(now)),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PrayerTimesPage(),
          ),
        ),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PrayerTimesPage)),
      );
      await waitFor(tester, find.text('Şehir seç'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Şehir seç'));
      await tester.pump();
      await waitFor(tester, find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'İSTANBUL');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'İSTANBUL'));
      await tester.pump();
      await waitFor(tester, find.text('15:30'));
      await tester.pumpAndSettle();
      expect(find.text('15:30'), findsOneWidget);
      expect(find.text('17:55'), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.textContaining('İmsakiyem veri seti'), findsOneWidget);
      final cache = container
          .read(prayerNotifierProvider)
          .requireValue
          .schedule!;
      expect(cache.location.annualRegionId, '9541');
      expect(cache.location.coordinatesKnown, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
