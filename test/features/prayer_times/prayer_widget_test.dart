import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/core/ads/admob.dart';
import 'package:zikirmatik/core/localization/locale_preference_repository.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/domain/home_state.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_card.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_times_page.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';
import '../../support/test_settings.dart';

final _now = DateTime.utc(2026, 11, 13, 7, 37, 34);

class _Prayer extends PrayerNotifier {
  @override
  Future<PrayerState> build() async {
    ensurePrayerTimeZones();
    final zone = tz.getLocation('Europe/Istanbul');
    final raw =
        jsonDecode(
              File(
                'test/fixtures/prayer_calendar_istanbul.json',
              ).readAsStringSync(),
            )
            as Map;
    return PrayerState(
      status: PrayerStatus.ready,
      schedule: PrayerSchedule(
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
      ),
    );
  }
}

class _NoAds extends AdsController {
  @override
  Future<AdsState> build() async => const AdsState();
}

class _Locale implements LocalePreferenceRepository {
  _Locale(this.code);
  final String code;
  @override
  Future<String?> readLocaleCode() async => code;
  @override
  Future<void> writeLocaleCode(String code) async {}
}

class _Home extends HomeNotifier {
  @override
  Future<HomeState> build() async => HomeState(
    isLoading: false,
    currentCount: 33,
    targetCount: 100,
    dailyTotal: 532,
    streakDays: 7,
    totalCount: 12532,
    activeZikr: ZikrDefinition(
      id: 'preview',
      title: 'Sübhanallah',
      defaultTarget: 100,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );
}

void main() {
  final capture = GlobalKey();
  Future<void> mount(
    WidgetTester tester, {
    String locale = 'tr',
    Size size = const Size(390, 844),
    double scale = 1,
  }) async {
    await tester.binding.setSurfaceSize(size);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          homeNotifierProvider.overrideWith(_Home.new),
          adsControllerProvider.overrideWith(_NoAds.new),
          settingsNotifierProvider.overrideWith(TestSettingsNotifier.new),
          localePreferenceRepositoryProvider.overrideWithValue(_Locale(locale)),
          prayerNotifierProvider.overrideWith(_Prayer.new),
          prayerClockProvider.overrideWith((ref) => Stream.value(_now)),
        ],
        child: RepaintBoundary(key: capture, child: const ZikirmatikApp()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'ana kart doğru geri sayımı gösterir ve kaldı yanında ok bulunmaz',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await mount(tester);
      expect(find.text('Öğle'), findsOneWidget);
      expect(find.text('02:15:26'), findsOneWidget);
      expect(find.text('kaldı'), findsOneWidget);
      for (final icon in [
        Icons.keyboard_arrow_down,
        Icons.expand_more,
        Icons.chevron_right,
        Icons.arrow_forward_ios,
      ]) {
        expect(
          find.descendant(
            of: find.byType(PrayerCard),
            matching: find.byIcon(icon),
          ),
          findsNothing,
        );
      }
      await tester.tap(find.byType(PrayerCard));
      await tester.pumpAndSettle();
      expect(find.byType(PrayerTimesPage), findsOneWidget);
      expect(find.text('İmsak'), findsOneWidget);
      expect(find.text('Güneş'), findsOneWidget);
      expect(find.text('Yatsı'), findsOneWidget);
      expect(find.text('06:14'), findsOneWidget);
      expect(find.text('13 Kasım Cuma'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'yeni kart ve liste küçük ekranda büyük TR EN AR metinleriyle taşmaz',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      for (final locale in ['tr', 'en', 'ar']) {
        await mount(
          tester,
          locale: locale,
          size: const Size(320, 568),
          scale: 1.4,
        );
        await tester.tap(find.byType(PrayerCard));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );
  testWidgets('namaz kartı ve detay ekranı önizlemesi', (tester) async {
    if (!const bool.fromEnvironment('UPDATE_PREVIEWS')) return;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.runAsync(() async {
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      await (FontLoader(
        'NotoSerif',
      )..addFont(rootBundle.load('assets/fonts/NotoSerif.ttf'))).load();
      final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
      if (font.existsSync()) {
        await (FontLoader('Roboto')..addFont(
              Future.value(ByteData.sublistView(font.readAsBytesSync())),
            ))
            .load();
      }
    });
    await mount(tester);
    for (final name in ['home-prayer', 'prayer-times']) {
      if (name == 'prayer-times') {
        await tester.tap(find.byType(PrayerCard));
        await tester.pumpAndSettle();
      }
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
  });
}
