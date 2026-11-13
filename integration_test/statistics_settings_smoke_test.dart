import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zikirmatik/app/app.dart';
import 'package:zikirmatik/core/ads/admob.dart';
import 'package:zikirmatik/core/services/reminder_service.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/presentation/home_page.dart';
import 'package:zikirmatik/features/settings/application/settings_notifier.dart';
import 'package:zikirmatik/features/settings/data/settings_repository.dart';
import 'package:zikirmatik/features/statistics/application/statistics_notifier.dart';
import 'package:zikirmatik/features/statistics/domain/statistics_state.dart';

class _NoAds extends AdsController {
  @override
  Future<AdsState> build() async => const AdsState();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android: gerçek sayaç, dönemler, tema ve bildirim planlama', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adsControllerProvider.overrideWith(_NoAds.new)],
        child: const ZikirmatikApp(),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomePage)),
    );
    final notifier = container.read(settingsNotifierProvider.notifier);
    final original = await container.read(settingsRepositoryProvider).read();
    await notifier.setLocale(const Locale('tr'));
    await notifier.setTheme(ThemeMode.dark);
    await notifier.setSound(true);
    await tester.pumpAndSettle();
    final before = container.read(homeNotifierProvider).requireValue.totalCount;
    await tester.tap(find.byKey(const ValueKey('tasbih-counter')));
    await tester.pumpAndSettle();
    expect(
      container.read(homeNotifierProvider).requireValue.totalCount,
      before + 1,
    );
    await tester.tap(find.text('İstatistik'));
    await tester.pumpAndSettle();
    final day = await container.read(statisticsNotifierProvider.future);
    expect(day.periodTotal, greaterThan(0));
    await tester.tap(find.text('Haftalık'));
    await tester.pumpAndSettle();
    expect(
      container.read(statisticsNotifierProvider).requireValue.period,
      StatisticsPeriod.weekly,
    );
    await tester.tap(find.text('Aylık'));
    await tester.pumpAndSettle();
    expect(
      container.read(statisticsNotifierProvider).requireValue.period,
      StatisticsPeriod.monthly,
    );
    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tema'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Açık'));
    await tester.pumpAndSettle();
    expect(
      container.read(settingsNotifierProvider).requireValue.themeMode,
      ThemeMode.light,
    );
    // API 32 smoke target grants normal notification permission without a system prompt.
    expect(
      await notifier.setReminder(enabled: true, hour: 20, minute: 0),
      isTrue,
    );
    final pending = await FlutterLocalNotificationsPlugin()
        .pendingNotificationRequests();
    expect(
      pending.where((p) => p.id == LocalReminderService.notificationId),
      hasLength(1),
    );
    expect(await notifier.setReminder(enabled: false), isTrue);
    final canceled = await FlutterLocalNotificationsPlugin()
        .pendingNotificationRequests();
    expect(
      canceled.where((p) => p.id == LocalReminderService.notificationId),
      isEmpty,
    );
    await notifier.setSound(original.soundEnabled);
    await notifier.setTheme(original.themeMode);
    if (original.reminderEnabled) {
      await notifier.setReminder(
        enabled: true,
        hour: original.reminderHour,
        minute: original.reminderMinute,
      );
    }
    if (original.localeCode != null) await notifier.setLocale(original.locale);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    debugPrint(
      'SMOKE: count persisted; daily/weekly/monthly selected; light theme applied; daily reminder scheduled and canceled.',
    );
  });
}
