import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/app/theme/app_theme.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';
import 'package:zikirmatik/features/zikrs/application/zikrs_notifier.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/domain/home_state.dart';
import 'package:zikirmatik/features/home/presentation/home_page.dart';
import 'package:zikirmatik/features/home/presentation/widgets/zikr_progress_card.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/zikrs/presentation/zikrs_page.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';
import 'package:zikirmatik/features/zikrs/presentation/zikr_detail_page.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';

final now = DateTime.now();
final zikr = ZikrDefinition(
  id: 'z',
  title: 'Sübhanallah',
  defaultTarget: 33,
  createdAt: now,
  updatedAt: now,
  isBuiltIn: true,
);

class FakeZikrs extends ZikrsNotifier {
  @override
  Future<List<ZikrDefinition>> build() async => [zikr];
}

class FakePrayer extends PrayerNotifier {
  @override
  Future<PrayerState> build() async => const PrayerState();
  @override
  Future<void> refresh({
    bool requestPermission = false,
    bool force = false,
  }) async {}
}

class FakeHome extends HomeNotifier {
  static int selections = 0;
  @override
  Future<HomeState> build() async =>
      HomeState(activeZikr: zikr, isLoading: false);
  @override
  Future<void> selectZikr(ZikrDefinition selected) async {
    selections++;
  }
}

void main() {
  test(
    'geçmiş ve toplam yalnız seçilen zikrin kayıtlarından hesaplanır',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      final today = DateTime(now.year, now.month, now.day);
      await db
          .into(db.dailyActivities)
          .insert(
            DailyActivitiesCompanion.insert(
              date: today,
              zikrId: 'builtin-subhanallah',
              incrementCount: const Value(7),
              updatedAt: now,
            ),
          );
      await db
          .into(db.dailyActivities)
          .insert(
            DailyActivitiesCompanion.insert(
              date: today,
              zikrId: 'builtin-elhamdulillah',
              incrementCount: const Value(500),
              updatedAt: now,
            ),
          );
      final subscription = container.listen(
        zikrDetailDataProvider('builtin-subhanallah'),
        (_, _) {},
      );
      addTearDown(subscription.close);
      final data = await container.read(
        zikrDetailDataProvider('builtin-subhanallah').future,
      );
      expect(data.total, 7);
      expect(data.history.length, 1);
    },
  );
  testWidgets('geçmiş açılır, kaydırılır ve yeniden kapanır', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final history = List.generate(9, (i) {
      final day = DateTime(now.year, now.month, now.day - i);
      return DailyActivity(
        date: day,
        zikrId: 'z',
        incrementCount: i + 1,
        activeMilliseconds: 0,
        updatedAt: day,
      );
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          zikrsNotifierProvider.overrideWith(FakeZikrs.new),
          zikrDetailDataProvider(
            'z',
          ).overrideWith((ref) => Stream.value(ZikrDetailData(null, history))),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark(),
          home: ZikrDetailPage(zikr: zikr, onNavTap: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Zikir Detayı'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
    expect(find.byKey(const ValueKey('detail-history-list')), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('detail-history-toggle')),
      250,
    );
    await tester.tap(find.byKey(const ValueKey('detail-history-toggle')));
    await tester.pumpAndSettle();
    final list = find.byKey(const ValueKey('detail-history-list'));
    expect(list, findsOneWidget);
    await tester.ensureVisible(list);
    await tester.drag(list, const Offset(0, -180));
    await tester.pumpAndSettle();
    final scroll = tester.state<ScrollableState>(
      find.descendant(of: list, matching: find.byType(Scrollable)).first,
    );
    expect(scroll.position.pixels, greaterThan(0));
    await tester.ensureVisible(
      find.byKey(const ValueKey('detail-history-toggle')),
    );
    await tester.tap(find.byKey(const ValueKey('detail-history-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('detail-history-list')), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('liste detayı açar, Başla zikri seçip ana sayfaya döner', (
    tester,
  ) async {
    FakeHome.selections = 0;
    int? selectedTab;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          zikrsNotifierProvider.overrideWith(FakeZikrs.new),
          homeNotifierProvider.overrideWith(FakeHome.new),
          zikrDetailDataProvider(
            'z',
          ).overrideWith((ref) => Stream.value(const ZikrDetailData(null, []))),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark(),
          home: ZikrsPage(
            selectedNavIndex: 1,
            onNavTap: (index) => selectedTab = index,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sübhanallah').first);
    await tester.pumpAndSettle();
    expect(find.text('Zikir Detayı'), findsOneWidget);
    expect(FakeHome.selections, 0);
    await tester.scrollUntilVisible(
      find.text('Başla'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Başla'));
    await tester.pumpAndSettle();
    expect(FakeHome.selections, 1);
    expect(selectedTab, 0);
  });

  testWidgets('ana sayfadaki zikir kartı aynı detayı açar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeNotifierProvider.overrideWith(FakeHome.new),
          prayerNotifierProvider.overrideWith(FakePrayer.new),
          zikrsNotifierProvider.overrideWith(FakeZikrs.new),
          zikrDetailDataProvider(
            'z',
          ).overrideWith((ref) => Stream.value(const ZikrDetailData(null, []))),
        ],
        child: MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark(),
          home: const HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(ZikrProgressCard));
    await tester.tap(find.byType(ZikrProgressCard));
    await tester.pumpAndSettle();
    expect(find.text('Zikir Detayı'), findsOneWidget);
    expect(find.text('Sübhanallah'), findsOneWidget);
  });
}
