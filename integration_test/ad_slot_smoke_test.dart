import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zikirmatik/core/ads/admob.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'yalnız reklam bileşenleri: gerçek SDK native ve banner test reklamı',
    (tester) async {
      expect(AdUnits.native, contains('3940256099942544'));
      expect(AdUnits.banner, contains('3940256099942544'));
      for (final placement in AdPlacement.values) {
        // Keep the consent controller; replacing the placement disposes only its ad.
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SafeArea(
                  child: Center(
                    child: SizedBox(
                      width: 340,
                      child: AdMobSlot(placement: placement),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        for (
          var second = 0;
          second < 60 && find.byType(AdWidget).evaluate().isEmpty;
          second++
        ) {
          await tester.pump(const Duration(seconds: 1));
        }
        final container = ProviderScope.containerOf(
          tester.element(find.byType(AdMobSlot)),
        );
        final consent = container.read(adsControllerProvider).asData?.value;
        debugPrint(
          'AD_SLOT_SMOKE placement=$placement allowed=${consent?.canRequest} loaded=${find.byType(AdWidget).evaluate().isNotEmpty}',
        );
        expect(consent?.canRequest, isTrue);
        expect(
          find.byType(AdWidget),
          findsOneWidget,
          reason: 'Google test ad must load for $placement',
        );
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
