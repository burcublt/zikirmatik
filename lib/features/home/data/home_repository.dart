import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';
import 'package:zikirmatik/core/database/database_transaction_runner.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(databaseTransactionRunnerProvider),
  );
});

class HomeRepository {
  HomeRepository(this._db, this._txRunner, {DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  DateTime get currentDay {
    final now = _now();
    return DateTime(now.year, now.month, now.day);
  }

  final AppDatabase _db;
  final DatabaseTransactionRunner _txRunner;

  /// Mevcut aktif zikrin counter'ını getirir. Yoksa null döner.
  Future<CounterProgressesData?> getCounterProgress(String zikrId) async {
    return (_db.select(
      _db.counterProgresses,
    )..where((r) => r.zikrId.equals(zikrId))).getSingleOrNull();
  }

  /// Sayacı 1 artırır; yoksa oluşturur. Hedef dolunca completedAt atar.
  Future<void> increment({
    required String zikrId,
    required int targetCount,
    int activeMilliseconds = 0,
  }) async {
    await _txRunner.run(() async {
      final now = _now();
      final today = DateTime(now.year, now.month, now.day);

      // CounterProgress upsert
      final existing = await getCounterProgress(zikrId);
      final previousCount = existing?.currentCount ?? 0;
      final newCount = previousCount >= targetCount ? 1 : previousCount + 1;
      final completed = newCount >= targetCount;

      await _db
          .into(_db.counterProgresses)
          .insertOnConflictUpdate(
            CounterProgressesCompanion.insert(
              zikrId: zikrId,
              currentCount: Value(newCount),
              targetCount: targetCount,
              completedAt: Value(completed ? now : null),
              updatedAt: now,
            ),
          );

      // DailyActivity upsert
      final existingActivity =
          await (_db.select(_db.dailyActivities)
                ..where((r) => r.zikrId.equals(zikrId) & r.date.equals(today)))
              .getSingleOrNull();

      await _db
          .into(_db.dailyActivities)
          .insertOnConflictUpdate(
            DailyActivitiesCompanion.insert(
              date: today,
              zikrId: zikrId,
              incrementCount: Value(
                (existingActivity?.incrementCount ?? 0) + 1,
              ),
              activeMilliseconds: Value(
                (existingActivity?.activeMilliseconds ?? 0) +
                    activeMilliseconds.clamp(0, 30000),
              ),
              updatedAt: now,
            ),
          );
    });
  }

  /// Bugünkü toplam zikir sayısı (tüm zikirler)
  Future<int> getDailyTotal() async {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final rows =
        await (_db.select(_db.dailyActivities)..where(
              (r) =>
                  r.date.isBiggerOrEqualValue(today) &
                  r.date.isSmallerThanValue(tomorrow),
            ))
            .get();

    return rows.fold<int>(0, (sum, r) => sum + r.incrementCount);
  }

  /// Toplam zikir sayısı (tüm zamanlar)
  Future<int> getTotalCount() async {
    final rows = await _db.select(_db.dailyActivities).get();
    return rows.fold<int>(0, (sum, r) => sum + r.incrementCount);
  }

  /// Ard arda zikir yapılan gün sayısı (streak)
  Future<int> getStreakDays() async {
    final rows = await (_db.select(
      _db.dailyActivities,
    )..orderBy([(r) => OrderingTerm.desc(r.date)])).get();

    if (rows.isEmpty) return 0;

    // Distinct günleri bul
    final days =
        rows
            .map((r) {
              final d = r.date;
              return DateTime(d.year, d.month, d.day);
            })
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (days.isEmpty) return 0;

    final today = _now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final yesterday = todayNorm.subtract(const Duration(days: 1));

    // Streak bugün veya dünden başlamalı
    if (days.first != todayNorm && days.first != yesterday) return 0;

    int streak = 1;
    for (int i = 1; i < days.length; i++) {
      final expected = days[i - 1].subtract(const Duration(days: 1));
      if (days[i] == expected) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Future<String?> getSelectedZikrId() async => (await (_db.select(
    _db.userPreferences,
  )..where((r) => r.id.equals(4))).getSingleOrNull())?.localeCode;

  Future<void> upsertCounterTarget({
    required String zikrId,
    required int targetCount,
  }) => _txRunner.run(() async {
    final now = _now();
    final existing = await getCounterProgress(zikrId);
    await _db
        .into(_db.counterProgresses)
        .insertOnConflictUpdate(
          CounterProgressesCompanion.insert(
            zikrId: zikrId,
            currentCount: Value(existing?.currentCount ?? 0),
            targetCount: targetCount,
            updatedAt: now,
          ),
        );
    await _db
        .into(_db.userPreferences)
        .insertOnConflictUpdate(
          UserPreferencesCompanion.insert(
            id: const Value(4),
            localeCode: zikrId,
            updatedAt: now,
          ),
        );
  });
}
