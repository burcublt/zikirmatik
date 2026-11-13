import '../support/test_prayer.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/core/ads/admob.dart';
import 'package:zikirmatik/core/localization/locale_preference_repository.dart';
import 'package:zikirmatik/core/services/reminder_service.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/domain/home_state.dart';
import 'package:zikirmatik/features/zikrs/application/zikrs_notifier.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';
import 'package:zikirmatik/features/settings/data/settings_repository.dart';
import 'package:zikirmatik/features/settings/presentation/settings_page.dart';
import 'package:zikirmatik/features/statistics/application/statistics_notifier.dart';
import 'package:zikirmatik/features/statistics/domain/statistics_state.dart';

class _NoAds extends AdsController {
  @override
  Future<AdsState> build() async => const AdsState();
}

class _Locale implements LocalePreferenceRepository {
  _Locale(this.locale);
  String locale;
  @override
  Future<String?> readLocaleCode() async => locale;
  @override
  Future<void> writeLocaleCode(String code) async {
    locale = code;
  }
}

class _Settings implements SettingsRepository {
  AppSettings value = const AppSettings();
  @override
  Future<AppSettings> read() async => value;
  @override
  Future<void> saveOptions(AppSettings next) async {
    value = next;
  }

  @override
  Future<void> saveLocale(String code) async {
    value = value.copyWith(localeCode: code);
  }

  @override
  Future<void> saveVibration(bool enabled) async {
    value = value.copyWith(vibrationEnabled: enabled);
  }
}

class _Reminder implements ReminderService {
  @override
  Future<bool> apply(
    AppSettings settings, {
    bool requestPermission = false,
  }) async => false;
}

class _Home extends HomeNotifier {
  @override
  Future<HomeState> build() async => const HomeState(isLoading: false);
}

class _Stats extends StatisticsNotifier {
  @override
  Future<StatisticsState> build() async => StatisticsState(
    weeklyData: List.generate(
      7,
      (i) => DayCount(
        date: DateTime(2026, 11, 6 + i),
        count: [32, 80, 55, 60, 120, 70, 115][i],
      ),
    ),
    zikrBreakdown: const [],
    todayTotal: 532,
    weekTotal: 532,
    monthTotal: 532,
    allTimeTotal: 532,
    streakDays: 7,
    longestStreak: 7,
    periodTotal: 532,
    activeDays: 7,
    goalTarget: 680,
    goalCompleted: 532,
    activeMilliseconds: 9000000,
    todayGoal: 100,
  );
}

class _Zikrs extends ZikrsNotifier {
  @override
  Future<List<ZikrDefinition>> build() async => [
    for (final e in [
      'Sübhanallah',
      'Elhamdülillah',
      'Allahu Ekber',
      'Lâ ilâhe illallah',
      'Estağfirullah',
      'Salavat',
    ].indexed)
      ZikrDefinition(
        id: 'preview-${e.$1}',
        title: e.$2,
        defaultTarget: e.$1 < 4 ? 33 : 100,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        sortOrder: e.$1,
        isBuiltIn: true,
      ),
  ];
}

void main() {
  final capture = GlobalKey();
  Future<void> mount(
    WidgetTester tester,
    String locale,
    double scale,
    Size size,
  ) async {
    await tester.binding.setSurfaceSize(size);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          prayerNotifierProvider.overrideWith(TestPrayerNotifier.new),
          zikrsNotifierProvider.overrideWith(_Zikrs.new),
          adsControllerProvider.overrideWith(_NoAds.new),
          homeNotifierProvider.overrideWith(_Home.new),
          settingsRepositoryProvider.overrideWithValue(_Settings()),
          reminderServiceProvider.overrideWithValue(_Reminder()),
          localePreferenceRepositoryProvider.overrideWithValue(_Locale(locale)),
          statisticsNotifierProvider.overrideWith(_Stats.new),
        ],
        child: RepaintBoundary(key: capture, child: const ZikirmatikApp()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'açık tema seçimi uygulamayı değiştirir; reddedilen bildirim kapalı kalır',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await mount(tester, 'tr', 1, const Size(390, 844));
      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tema'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Açık'));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(SettingsPage))).brightness,
        Brightness.light,
      );
      final switches = find.byType(Switch);
      await tester.tap(switches.at(2));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(switches.at(2)).value, false);
      expect(
        find.text(
          'Hatırlatma için cihaz ayarlarından bildirim izni vermelisiniz.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'istatistik ve ayarlar dar ekranda büyük TR EN AR metinleriyle taşmaz',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      for (final locale in ['tr', 'en', 'ar']) {
        await mount(tester, locale, 1.4, const Size(320, 568));
        await tester.tap(find.byIcon(Icons.bar_chart_outlined));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView).first, const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView).first, const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );
  testWidgets('istatistik ve ayarlar görsel önizlemeleri', (tester) async {
    if (!const bool.fromEnvironment('UPDATE_PREVIEWS')) return;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.runAsync(() async {
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      final titleFont = FontLoader('NotoSerif')
        ..addFont(rootBundle.load('assets/fonts/NotoSerif.ttf'));
      await titleFont.load();
      for (final (family, path) in [
        ('Roboto', '/System/Library/Fonts/Supplemental/Arial.ttf'),
        ('Georgia', '/System/Library/Fonts/Supplemental/Georgia Bold.ttf'),
      ]) {
        final file = File(path);
        if (!file.existsSync()) continue;
        await (FontLoader(family)..addFont(
              Future.value(ByteData.sublistView(file.readAsBytesSync())),
            ))
            .load();
      }
    });
    await mount(tester, 'tr', 1, const Size(390, 844));
    for (final (label, name) in [
      ('Zikirler', 'zikrs'),
      ('İstatistik', 'statistics'),
      ('Ayarlar', 'settings'),
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      final boundary =
          capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final img = await boundary.toImage(pixelRatio: 2);
        final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
        final file = File('build/design-preview/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        img.dispose();
      });
    }
    expect(tester.takeException(), isNull);
  });
}
