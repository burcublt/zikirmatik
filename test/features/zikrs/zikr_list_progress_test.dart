import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/theme/app_theme.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/domain/home_state.dart';
import 'package:zikirmatik/features/zikrs/application/zikrs_notifier.dart';
import 'package:zikirmatik/features/zikrs/data/zikr_progress_provider.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_search.dart';
import 'package:zikirmatik/features/zikrs/presentation/zikrs_page.dart';
import 'package:zikirmatik/features/zikrs/presentation/widgets/zikr_list_tile.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';

final now = DateTime.now();
final first = ZikrDefinition(
  id: 'one',
  title: 'Lâ ilâhe illallah',
  defaultTarget: 100,
  createdAt: now,
  updatedAt: now,
);
final second = ZikrDefinition(
  id: 'two',
  title: 'Sübhanallah',
  defaultTarget: 33,
  createdAt: now,
  updatedAt: now,
  isBuiltIn: true,
);

class FakeZikrs extends ZikrsNotifier {
  @override
  Future<List<ZikrDefinition>> build() async => [first, second];
}

class FakeHome extends HomeNotifier {
  @override
  Future<HomeState> build() async =>
      HomeState(activeZikr: second, isLoading: false);
}

void main() {
  test(
    'arama şapka, Türkçe harfler, büyük harf ve birleşik işaretleri eşleştirir',
    () {
      expect(
        normalizeZikrSearch(
          'Lâ ilâhe illallah',
        ).contains(normalizeZikrSearch('la il')),
        isTrue,
      );
      expect(normalizeZikrSearch('İSTİĞFÂR'), normalizeZikrSearch('istigfar'));
      expect(
        normalizeZikrSearch('La\u0302  ila\u0302he'),
        normalizeZikrSearch('la ilahe'),
      );
      expect(normalizeZikrSearch('سُبْحَانَ'), 'سُبْحَانَ');
    },
  );
  test('ilerleme verisi her zikir için canlı olarak güncellenir', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    final updated = Completer<void>();
    final subscription = container.listen(zikrProgressProvider, (_, next) {
      if (next.asData?.value['builtin-subhanallah']?.currentCount == 8 &&
          !updated.isCompleted) {
        updated.complete();
      }
    });
    addTearDown(() async {
      subscription.close();
      container.dispose();
      await db.close();
    });
    await container.read(zikrProgressProvider.future);
    await db
        .into(db.counterProgresses)
        .insert(
          CounterProgressesCompanion.insert(
            zikrId: 'builtin-subhanallah',
            currentCount: const Value(8),
            targetCount: 33,
            updatedAt: now,
          ),
        );
    await updated.future.timeout(const Duration(seconds: 5));
    final value = container.read(zikrProgressProvider).requireValue;
    expect(value['builtin-subhanallah']!.currentCount, 8);
    expect(value['builtin-subhanallah']!.targetCount, 33);
  });
  testWidgets(
    'liste sayaç, hedef ve yüzdeyi gösterir; la il araması zikri bulur',
    (tester) async {
      final saved = CounterProgressesData(
        zikrId: 'one',
        currentCount: 25,
        targetCount: 100,
        updatedAt: now,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            zikrsNotifierProvider.overrideWith(FakeZikrs.new),
            homeNotifierProvider.overrideWith(FakeHome.new),
            zikrProgressProvider.overrideWith(
              (ref) => Stream.value({'one': saved}),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.dark(),
            home: ZikrsPage(selectedNavIndex: 1, onNavTap: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('25 / 100'), findsOneWidget);
      expect(find.text('%25'), findsOneWidget);
      expect(find.text('0 / 33'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'la il');
      await tester.pumpAndSettle();
      expect(find.text('Lâ ilâhe illallah'), findsOneWidget);
      expect(find.text('Sübhanallah'), findsNothing);
      expect(find.text('25 / 100'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('dar ekranda büyük yazı ve büyük sayaç taşmaz', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final progress = CounterProgressesData(
      zikrId: 'one',
      currentCount: 123456,
      targetCount: 999999,
      updatedAt: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.4)),
          child: child!,
        ),
        home: Scaffold(
          body: ZikrListTile(
            zikr: first,
            isActive: false,
            progress: progress,
            onSelect: () {},
            onEdit: () {},
            onDelete: () {},
            onFavorite: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
