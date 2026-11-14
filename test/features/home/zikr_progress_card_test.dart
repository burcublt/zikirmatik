import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/home/presentation/widgets/zikr_progress_card.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';

void main() {
  Widget appFor(ZikrProgressCard card) => MaterialApp(
    locale: const Locale('tr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: card)),
  );

  testWidgets('gösterilen zikir ilerlemesi sayaç/hedef oranından hesaplanır', (
    tester,
  ) async {
    await tester.pumpWidget(
      appFor(
        const ZikrProgressCard(
          title: 'Sübhanallah',
          currentCount: 33,
          targetCount: 100,
          onTap: _noop,
        ),
      ),
    );

    expect(find.text('Sübhanallah'), findsOneWidget);
    expect(find.text('%33'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0.33,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('sıfır hedef güvenli biçimde sıfır ilerleme gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      appFor(
        const ZikrProgressCard(
          title: 'Sübhanallah',
          currentCount: 12,
          targetCount: 0,
          onTap: _noop,
        ),
      ),
    );

    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0,
    );
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
