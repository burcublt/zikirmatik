import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/theme/app_theme.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_region.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_region_picker.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';

void main() {
  final catalog = PrayerRegionCatalog.decode(
    File('assets/prayer_times/regions.json').readAsStringSync(),
  );
  testWidgets('takvim bölgesi araması ve seçim sonucu', (tester) async {
    Object? picked;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prayerRegionCatalogProvider.overrideWith((ref) async => catalog),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  picked = await Navigator.of(context).push<Object>(
                    MaterialPageRoute(
                      builder: (_) => const PrayerRegionPicker(),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'polatlı');
    await tester.pumpAndSettle();
    expect(find.text('POLATLI'), findsOneWidget);
    await tester.tap(find.text('POLATLI'));
    await tester.pumpAndSettle();
    expect((picked as PrayerRegion).id, '9220');
    expect(tester.takeException(), isNull);
  });
  testWidgets('bölge seçimi küçük ekranda TR EN AR büyük metinle taşmaz', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final code in ['tr', 'en', 'ar']) {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      tester.platformDispatcher.textScaleFactorTestValue = 1.4;
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            prayerRegionCatalogProvider.overrideWith((ref) async => catalog),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            locale: Locale(code),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PrayerRegionPicker(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
