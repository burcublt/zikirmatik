import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:true_compass/true_compass.dart';
import 'package:zikirmatik/app/theme/app_theme.dart';
import 'package:zikirmatik/features/home/presentation/widgets/main_bottom_nav.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_location_service.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';
import 'package:zikirmatik/features/qibla/application/qibla_providers.dart';
import 'package:zikirmatik/features/qibla/domain/qibla_direction.dart';
import 'package:zikirmatik/features/qibla/presentation/qibla_page.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';

const place = PrayerLocation(
  latitude: 41.01,
  longitude: 28.98,
  label: 'İstanbul',
);

class _Location extends QiblaLocationNotifier {
  @override
  Future<QiblaLocation> build() async => const QiblaLocation(place);
}

class _Denied extends QiblaLocationNotifier {
  @override
  Future<QiblaLocation> build() async =>
      throw const PrayerLocationException(PrayerLocationIssue.deniedForever);
}

class _Compass implements QiblaCompassService {
  _Compass(this.stream);
  final Stream<CompassHeading> stream;
  @override
  Stream<CompassHeading> headings(PrayerLocation location) => stream;
}

void main() {
  test('bilinen şehirlerin gerçek kuzeye göre kıble açıları', () {
    expect(qiblaBearing(41.01, 28.98), closeTo(151.6, 0.3));
    expect(qiblaBearing(51.5074, -0.1278), closeTo(118.99, 0.2));
    expect(qiblaBearing(40.7128, -74.006), closeTo(58.48, 0.2));
    expect(qiblaBearing(-33.8688, 151.2093), closeTo(277.5, 0.3));
  });
  test('kuzey geçişinde en kısa dönüş ve tanımsız konum', () {
    expect(qiblaTurn(1, 359), 2);
    expect(qiblaTurn(359, 1), -2);
    expect(qiblaTurn(180, 0), -180);
    expect(qiblaBearing(91, 0), isNull);
    expect(qiblaBearing(double.nan, 0), isNull);
    expect(qiblaBearing(21.422487, 39.826206), isNull);
  });
  Future<void> mount(
    WidgetTester tester, {
    Stream<CompassHeading>? stream,
    String locale = 'tr',
    bool denied = false,
    double scale = 1,
    Size size = const Size(390, 844),
    GlobalKey? capture,
    ValueChanged<int>? onNav,
  }) async {
    await tester.binding.setSurfaceSize(size);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qiblaLocationProvider.overrideWith(
            denied ? _Denied.new : _Location.new,
          ),
          qiblaCompassServiceProvider.overrideWithValue(
            _Compass(
              stream ??
                  Stream.value(
                    CompassHeading(
                      magneticHeading: 148,
                      trueHeading: 151.6,
                      accuracy: CompassAccuracy.high,
                    ),
                  ),
            ),
          ),
        ],
        child: RepaintBoundary(
          key: capture,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: QiblaPage(onNavTap: onNav ?? (_) {}),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

  testWidgets('kıble hizası ve beşli menünün yeni indisleri', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    int? selected;
    await mount(tester, onNav: (v) => selected = v);
    expect(find.text('Kıble yönündesiniz'), findsOneWidget);
    final nav = tester.widget<MainBottomNav>(find.byType(MainBottomNav));
    expect(nav.currentIndex, 2);
    for (final pair in [('Kıble', 2), ('İstatistik', 3), ('Ayarlar', 4)]) {
      await tester.tap(
        find.descendant(
          of: find.byType(MainBottomNav),
          matching: find.text(pair.$1),
        ),
      );
      expect(selected, pair.$2);
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets('kıble oku yeni pusula başlığıyla birlikte döner', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final controller = StreamController<CompassHeading>.broadcast();
    addTearDown(controller.close);
    await mount(tester, stream: controller.stream);

    double pointerAngle() {
      final dial = tester.widget<CustomPaint>(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is QiblaDialPainter,
        ),
      );
      return (dial.painter! as QiblaDialPainter).turn * math.pi / 180;
    }

    controller.add(
      CompassHeading(
        magneticHeading: 110,
        trueHeading: 110,
        accuracy: CompassAccuracy.high,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(
      pointerAngle(),
      closeTo(
        qiblaTurn(qiblaBearing(41.01, 28.98)!, 110) * math.pi / 180,
        1e-6,
      ),
    );

    controller.add(
      CompassHeading(
        magneticHeading: 120,
        trueHeading: 120,
        accuracy: CompassAccuracy.high,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(
      pointerAngle(),
      closeTo(
        qiblaTurn(qiblaBearing(41.01, 28.98)!, 120) * math.pi / 180,
        1e-6,
      ),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('düşük doğrulukta hizalandı gösterilmez', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await mount(
      tester,
      stream: Stream.value(
        CompassHeading(
          magneticHeading: 151.6,
          trueHeading: 151.6,
          accuracy: CompassAccuracy.low,
        ),
      ),
    );
    expect(find.textContaining('sekiz çizerek'), findsOneWidget);
    expect(find.text('Kıble yönündesiniz'), findsNothing);
  });
  testWidgets('sensör hatasında sahte yön gösterilmez', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await mount(tester, stream: Stream.error(StateError('no sensor')));
    expect(find.textContaining('Pusula verisi alınamıyor'), findsOneWidget);
    expect(find.text('Kıble yönündesiniz'), findsNothing);
  });
  testWidgets('kalıcı izin reddinde ayarlar ve şehir seçimi', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await mount(tester, denied: true);
    expect(find.text('Cihaz ayarlarını aç'), findsOneWidget);
    expect(find.text('Şehir seç'), findsOneWidget);
  });
  testWidgets('TR EN AR küçük ekran ve büyük metin', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final locale in ['tr', 'en', 'ar']) {
      await mount(
        tester,
        locale: locale,
        size: const Size(320, 568),
        scale: 1.4,
      );
      final dialFinder = find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.painter is QiblaDialPainter,
      );
      final dial = tester.widget<CustomPaint>(dialFinder);
      final painter = dial.painter! as QiblaDialPainter;
      expect(
        (
          painter.northLabel,
          painter.eastLabel,
          painter.southLabel,
          painter.westLabel,
        ),
        switch (locale) {
          'tr' => ('K', 'D', 'G', 'B'),
          'ar' => ('ش', 'م', 'ج', 'غ'),
          _ => ('N', 'E', 'S', 'W'),
        },
      );
      expect(tester.getSize(dialFinder).width, greaterThan(100));
      await tester.drag(find.byType(ListView).first, const Offset(0, -450));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('arka planda pusula aboneliği kapatılır', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    var cancelled = false;
    final controller = StreamController<CompassHeading>.broadcast(
      onCancel: () => cancelled = true,
    );
    addTearDown(controller.close);
    await mount(tester, stream: controller.stream);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    expect(cancelled, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
  });
  testWidgets('kıble örnek verili önizleme', (tester) async {
    if (!const bool.fromEnvironment('UPDATE_PREVIEWS')) return;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.runAsync(() async {
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      await (FontLoader('Roboto')..addFont(
            Future.value(
              ByteData.sublistView(
                File(
                  '/System/Library/Fonts/Supplemental/Arial.ttf',
                ).readAsBytesSync(),
              ),
            ),
          ))
          .load();
      await (FontLoader(
        'NotoSerif',
      )..addFont(rootBundle.load('assets/fonts/NotoSerif.ttf'))).load();
    });
    final key = GlobalKey();
    await mount(tester, capture: key);
    await tester.pumpAndSettle();
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 2);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/design-preview/qibla.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      img.dispose();
    });
  });
}
