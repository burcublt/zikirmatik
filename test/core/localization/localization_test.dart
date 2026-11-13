import '../../support/test_prayer.dart';
import '../../support/test_settings.dart';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/localization/app_locales.dart';
import 'package:zikirmatik/core/localization/locale_controller.dart';
import 'package:zikirmatik/core/localization/locale_preference_repository.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/domain/home_state.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';

void main() {
  test('Türkçe, İngilizce ve Arapça kaynakları yüklenir', () async {
    final tr = await AppLocalizations.delegate.load(AppLocales.turkish);
    final en = await AppLocalizations.delegate.load(AppLocales.english);
    final ar = await AppLocalizations.delegate.load(AppLocales.arabic);

    expect(tr.home, 'Ana Sayfa');
    expect(en.home, 'Home');
    expect(ar.home, 'الرئيسية');
    expect(AppLocalizations.supportedLocales, AppLocales.supported);
  });

  test('tüm ARB dosyaları aynı kullanıcı metni anahtarlarını içerir', () {
    final keysByLocale = ['tr', 'en', 'ar']
        .map((locale) => _messageKeys('lib/l10n/app_$locale.arb'))
        .toList(growable: false);

    expect(keysByLocale[1], keysByLocale.first);
    expect(keysByLocale[2], keysByLocale.first);
  });

  test('seçilen dil kalıcı tercihten yeniden yüklenir', () async {
    final repository = _MemoryLocalePreferenceRepository('en');
    final firstContainer = ProviderContainer(
      overrides: [
        prayerNotifierProvider.overrideWith(TestPrayerNotifier.new),
        settingsNotifierProvider.overrideWith(TestSettingsNotifier.new),
        localePreferenceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(firstContainer.dispose);

    expect(
      await firstContainer.read(localeControllerProvider.future),
      AppLocales.english,
    );

    await firstContainer
        .read(localeControllerProvider.notifier)
        .select(AppLocales.arabic);

    final secondContainer = ProviderContainer(
      overrides: [
        prayerNotifierProvider.overrideWith(TestPrayerNotifier.new),
        settingsNotifierProvider.overrideWith(TestSettingsNotifier.new),
        localePreferenceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(secondContainer.dispose);

    expect(
      await secondContainer.read(localeControllerProvider.future),
      AppLocales.arabic,
    );
  });

  test('Drift dil tercihini veritabanında saklar', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = DriftLocalePreferenceRepository(database);

    await repository.writeLocaleCode('ar');

    expect(await repository.readLocaleCode(), 'ar');
    await database.close();
  });

  testWidgets('Arapça RTL, Türkçe ve İngilizce LTR düzeninde açılır', (
    WidgetTester tester,
  ) async {
    for (final expectation in [
      (locale: 'tr', appTitle: 'Zikirmatik', direction: TextDirection.ltr),
      (locale: 'en', appTitle: 'Zikirmatik', direction: TextDirection.ltr),
      (locale: 'ar', appTitle: 'السبحة', direction: TextDirection.rtl),
    ]) {
      await tester.pumpWidget(
        ProviderScope(
          key: ValueKey(expectation.locale),
          overrides: [
            prayerNotifierProvider.overrideWith(TestPrayerNotifier.new),
            settingsNotifierProvider.overrideWith(TestSettingsNotifier.new),
            localePreferenceRepositoryProvider.overrideWithValue(
              _MemoryLocalePreferenceRepository(expectation.locale),
            ),
            homeNotifierProvider.overrideWith(() => _StubHomeNotifier()),
          ],
          child: const ZikirmatikApp(),
        ),
      );
      await tester.pumpAndSettle();

      final localizedText = find.text(expectation.appTitle);
      expect(localizedText, findsOneWidget);
      expect(
        Directionality.of(tester.element(localizedText)),
        expectation.direction,
      );
    }
  });

  testWidgets('İngilizce ve Arapça metinler dar ekranda taşmadan kurulabilir', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final locale in ['en', 'ar']) {
      await tester.pumpWidget(
        ProviderScope(
          key: ValueKey(locale),
          overrides: [
            prayerNotifierProvider.overrideWith(TestPrayerNotifier.new),
            settingsNotifierProvider.overrideWith(TestSettingsNotifier.new),
            localePreferenceRepositoryProvider.overrideWithValue(
              _MemoryLocalePreferenceRepository(locale),
            ),
            homeNotifierProvider.overrideWith(() => _StubHomeNotifier()),
          ],
          child: const ZikirmatikApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }
  });
}

Set<String> _messageKeys(String path) {
  final contents =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return contents.keys.where((key) => !key.startsWith('@')).toSet();
}

class _StubHomeNotifier extends HomeNotifier {
  @override
  Future<HomeState> build() async => const HomeState(isLoading: false);
}

class _MemoryLocalePreferenceRepository implements LocalePreferenceRepository {
  _MemoryLocalePreferenceRepository(this._localeCode);

  String? _localeCode;

  @override
  Future<String?> readLocaleCode() async => _localeCode;

  @override
  Future<void> writeLocaleCode(String localeCode) async {
    _localeCode = localeCode;
  }
}
