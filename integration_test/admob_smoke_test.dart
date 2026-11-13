import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zikirmatik/core/ads/admob.dart';
import 'package:zikirmatik/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android: sekmeler ve native/banner test reklamları', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();
    for (var i = 0; i < 20 && find.text('Zikirler').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.byType(AdWidget), findsNothing);
    await tester.tap(find.text('Zikirler'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 25 && find.byType(AdWidget).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(seconds: 1));
      await tester.drag(find.byType(ListView).first, const Offset(0, -100));
    }
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AdMobSlot).first),
    );
    final ads = container.read(adsControllerProvider).asData?.value;
    debugPrint(
      'SMOKE nativeLoaded=${find.byType(AdWidget).evaluate().isNotEmpty} consentCanRequest=${ads?.canRequest}',
    );
    final nativeLoaded = find.byType(AdWidget).evaluate().isNotEmpty;
    if (nativeLoaded && const bool.fromEnvironment('CAPTURE_NATIVE_PREVIEW')) {
      debugPrint('NATIVE_PREVIEW_READY');
      await Future<void>.delayed(const Duration(seconds: 20));
    }
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('İstatistik'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -450));
    for (var i = 0; i < 25 && find.byType(AdWidget).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    debugPrint(
      'SMOKE bannerLoaded=${find.byType(AdWidget).evaluate().isNotEmpty}',
    );
    final bannerLoaded = find.byType(AdWidget).evaluate().isNotEmpty;
    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();
    expect(find.byType(AdWidget), findsNothing);
    expect(tester.takeException(), isNull);
    expect(nativeLoaded, isTrue, reason: 'Native test reklamı yüklenmeli');
    expect(bannerLoaded, isTrue, reason: 'Banner test reklamı yüklenmeli');
  });
}
