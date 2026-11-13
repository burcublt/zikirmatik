import '../support/test_prayer.dart';
import '../support/test_settings.dart';
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
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/domain/home_state.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';

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
    totalCount: 12532,
    streakDays: 7,
    activeZikr: ZikrDefinition(
      id: 'sample',
      title: 'Sübhanallah',
      defaultTarget: 100,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  );
  @override
  Future<void> increment() async {
    state = AsyncData(
      state.requireValue.copyWith(
        currentCount: state.requireValue.currentCount + 1,
      ),
    );
  }
}

void main() {
  final capture = GlobalKey();
  Future<void> mount(
    WidgetTester tester,
    String locale,
    Size size,
    double textScale,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(
      ProviderScope(
        key: ValueKey('$locale-$size-$textScale'),
        overrides: [
          prayerNotifierProvider.overrideWith(TestPrayerNotifier.new),
          settingsNotifierProvider.overrideWith(TestSettingsNotifier.new),
          adsControllerProvider.overrideWith(_NoAds.new),
          homeNotifierProvider.overrideWith(_Home.new),
          localePreferenceRepositoryProvider.overrideWithValue(_Locale(locale)),
        ],
        child: RepaintBoundary(
          key: capture,
          child: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
            ),
            child: const ZikirmatikApp(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('referans düzeninde sayaç dokununca artar, dört sekme vardır', (
    tester,
  ) async {
    await mount(tester, 'tr', const Size(390, 844), 1);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    expect(find.text("Kur'an"), findsNothing);
    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Zikirler'), findsOneWidget);
    expect(find.text('İstatistik'), findsOneWidget);
    expect(find.text('Ayarlar'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('tasbih-counter')));
    await tester.pumpAndSettle();
    expect(find.text('34'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('küçük ekran ve büyük yazıda TR EN AR görünümü taşmaz', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final locale in ['tr', 'en', 'ar']) {
      await mount(tester, locale, const Size(320, 568), 1.4);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -250),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('ana sayfa görsel önizlemesi', (tester) async {
    if (!const bool.fromEnvironment('UPDATE_PREVIEWS')) return;
    await tester.runAsync(() async {
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      final titleFont = FontLoader('NotoSerif')
        ..addFont(rootBundle.load('assets/fonts/NotoSerif.ttf'));
      await titleFont.load();
      final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
      if (font.existsSync()) {
        final loader = FontLoader('Roboto')
          ..addFont(Future.value(ByteData.sublistView(font.readAsBytesSync())));
        await loader.load();
      }
      final serif = File('/System/Library/Fonts/Supplemental/Georgia Bold.ttf');
      if (serif.existsSync()) {
        final loader = FontLoader(
          'Georgia',
        )..addFont(Future.value(ByteData.sublistView(serif.readAsBytesSync())));
        await loader.load();
      }
    });
    await mount(tester, 'tr', const Size(390, 844), 1);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final boundary =
        capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 2);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final out = File('build/design-preview/home.png');
      await out.parent.create(recursive: true);
      await out.writeAsBytes(bytes!.buffer.asUint8List());
      img.dispose();
    });
    expect(tester.takeException(), isNull);
  });
}
