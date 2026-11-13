import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';
import 'package:zikirmatik/core/database/database_transaction_runner.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/data/home_repository.dart';
import 'package:zikirmatik/features/zikrs/data/drift_zikr_repository.dart';

ProviderContainer session(AppDatabase db, {DateTime Function()? now}) =>
    ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        homeRepositoryProvider.overrideWithValue(
          HomeRepository(db, DriftDatabaseTransactionRunner(db), now: now),
        ),
      ],
    );
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'çevrim dışı yeniden açılışta son zikir, sayısı ve hedefi korunur',
    () async {
      final dir = Directory.systemTemp.createTempSync('zikr-reopen-');
      final file = File('${dir.path}/app.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      var c = session(db);
      await c.read(homeNotifierProvider.future);
      final zikr = (await c.read(zikrRepositoryProvider).watchActive().first)[1]
          .copyWith(defaultTarget: 77);
      await c.read(homeNotifierProvider.notifier).selectZikr(zikr);
      await c.read(homeNotifierProvider.notifier).increment();
      await c.read(homeNotifierProvider.notifier).increment();
      c.dispose();
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      c = session(db);
      final restored = await c.read(homeNotifierProvider.future);
      expect(restored.activeZikr!.id, zikr.id);
      expect(restored.currentCount, 2);
      expect(restored.targetCount, 77);
      expect(restored.totalCount, 2);
      c.dispose();
      await db.close();
      dir.deleteSync(recursive: true);
    },
  );
  test(
    'gün değişiminden dönüşte günlük toplam sıfırlanır, genel toplam korunur',
    () async {
      var now = DateTime(2026, 11, 12, 23, 59);
      final db = AppDatabase(NativeDatabase.memory());
      final c = session(db, now: () => now);
      await c.read(homeNotifierProvider.future);
      final notifier = c.read(homeNotifierProvider.notifier);
      await notifier.increment();
      await notifier.increment();
      final id = c.read(homeNotifierProvider).requireValue.activeZikr!.id;
      now = DateTime(2026, 11, 13, 0, 1);
      await notifier.refreshAfterResume();
      var restored = c.read(homeNotifierProvider).requireValue;
      expect(restored.dailyTotal, 0);
      expect(restored.totalCount, 2);
      expect(restored.activeZikr!.id, id);
      await notifier.increment();
      restored = c.read(homeNotifierProvider).requireValue;
      expect(restored.dailyTotal, 1);
      expect(restored.totalCount, 3);
      expect(await c.read(homeRepositoryProvider).getDailyTotal(), 1);
      c.dispose();
      await db.close();
    },
  );
  test(
    'gün değişiminde ekrana dönmeden sayılırsa eski gün toplamı taşınmaz',
    () async {
      var now = DateTime(2026, 11, 12, 23, 59);
      final db = AppDatabase(NativeDatabase.memory());
      final c = session(db, now: () => now);
      await c.read(homeNotifierProvider.future);
      final notifier = c.read(homeNotifierProvider.notifier);
      await notifier.increment();
      now = DateTime(2026, 11, 13, 0, 1);
      await notifier.increment();
      expect(c.read(homeNotifierProvider).requireValue.dailyTotal, 1);
      expect(c.read(homeNotifierProvider).requireValue.totalCount, 2);
      c.dispose();
      await db.close();
    },
  );
}
