import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';
import 'package:zikirmatik/core/database/database_transaction_runner.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/data/home_repository.dart';
import 'package:zikirmatik/features/settings/application/settings_notifier.dart';
import 'package:zikirmatik/features/settings/data/settings_repository.dart';
import 'package:zikirmatik/features/zikrs/data/drift_zikr_repository.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        databaseTransactionRunnerProvider.overrideWithValue(
          DriftDatabaseTransactionRunner(database),
        ),
        settingsRepositoryProvider.overrideWithValue(
          DriftSettingsRepository(database),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  Future<void> seedZikr(String id, String title) async {
    final now = DateTime.now();
    await container
        .read(zikrRepositoryProvider)
        .save(
          ZikrDefinition(
            id: id,
            title: title,
            defaultTarget: 33,
            createdAt: now,
            updatedAt: now,
            sortOrder: 0,
          ),
        );
  }

  test('boş veritabanında yükleme hatasız tamamlanır', () async {
    final state = await container.read(homeNotifierProvider.future);
    expect(state.isLoading, isFalse);
    // Seed data geldiği için ilk built-in zikir aktif olarak seçilir
    expect(state.activeZikr?.id, 'builtin-subhanallah');
  });

  test('zikir eklenince sayaç başlar ve artırılabilir', () async {
    await seedZikr('subhanallah', 'Sübhanallah');

    final state = await container.read(homeNotifierProvider.future);
    // Aktif zikir seed data'dan gelen ilk zikir (builtin-subhanallah)
    expect(state.activeZikr, isNotNull);
    expect(state.currentCount, 0);

    await container.read(homeNotifierProvider.notifier).increment();

    final updated = container.read(homeNotifierProvider).asData!.value;
    expect(updated.currentCount, 1);
    expect(updated.dailyTotal, 1);
    expect(updated.totalCount, 1);
  });

  test(
    'hızlı sayımlarda yeni tur ve kalıcı toplam birbirinden ayrışmaz',
    () async {
      final initial = await container.read(homeNotifierProvider.future);
      final selected = initial.activeZikr!.copyWith(defaultTarget: 2);
      await container.read(homeNotifierProvider.notifier).selectZikr(selected);
      await Future.wait(
        List.generate(
          5,
          (_) => container.read(homeNotifierProvider.notifier).increment(),
        ),
      );
      final state = container.read(homeNotifierProvider).requireValue;
      final progress = await container
          .read(homeRepositoryProvider)
          .getCounterProgress(selected.id);
      expect(state.currentCount, 1);
      expect(progress!.currentCount, 1);
      expect(await container.read(homeRepositoryProvider).getTotalCount(), 5);
    },
  );

  test('streak hesabı doğru çalışır', () async {
    await seedZikr('elhamdulillah', 'Elhamdülillah');
    await container.read(homeNotifierProvider.future);

    await container.read(homeNotifierProvider.notifier).increment();

    final repo = container.read(homeRepositoryProvider);
    final streak = await repo.getStreakDays();
    expect(streak, 1);
  });

  test('titreşim ayarı toggle edilebilir', () async {
    // settings yüklensin
    await container.read(settingsNotifierProvider.future);
    final state = await container.read(homeNotifierProvider.future);
    expect(state.vibrationEnabled, isTrue);

    // syncVibration doğrudan homeState'i günceller (DB'ye yazmaz)
    container.read(homeNotifierProvider.notifier).syncVibration(enabled: false);

    final updated = container.read(homeNotifierProvider).asData!.value;
    expect(updated.vibrationEnabled, isFalse);
  });
}
