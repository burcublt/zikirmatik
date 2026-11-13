import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/features/statistics/data/statistics_repository.dart';
import 'package:zikirmatik/features/statistics/domain/statistics_state.dart';

void main() {
  late AppDatabase db;
  late StatisticsRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = StatisticsRepository(db, now: () => DateTime(2026, 11, 12, 12));
  });
  tearDown(() => db.close());
  Future<void> activity(DateTime day, int count, int elapsed) => db
      .into(db.dailyActivities)
      .insert(
        DailyActivitiesCompanion.insert(
          date: day,
          zikrId: 'builtin-subhanallah',
          incrementCount: Value(count),
          activeMilliseconds: Value(elapsed),
          updatedAt: day,
        ),
      );

  test('gün, son yedi gün ve ay farklı toplamları ve süreleri verir', () async {
    await activity(DateTime(2026, 10, 31), 400, 9000);
    await activity(DateTime(2026, 11, 1), 100, 8000);
    await activity(DateTime(2026, 11, 6), 30, 2000);
    await activity(DateTime(2026, 11, 12), 20, 1000);
    await activity(DateTime(2026, 11, 13), 900, 9000); // future data excluded
    final day = await repo.load(StatisticsPeriod.daily);
    final week = await repo.load(StatisticsPeriod.weekly);
    final month = await repo.load(StatisticsPeriod.monthly);
    expect(day.periodTotal, 20);
    expect(day.activeMilliseconds, 1000);
    expect(week.periodTotal, 50);
    expect(week.activeMilliseconds, 3000);
    expect(week.activeDays, 2);
    expect(month.periodTotal, 150);
    expect(month.activeMilliseconds, 11000);
    expect(month.allTimeTotal, 550);
    expect(month.weeklyData.length, 12);
    expect(week.weeklyData.length, 7);
  });
  test('hedefsiz günler yüzdeyi şişirmez, sıfır hedef güvenlidir', () async {
    await activity(DateTime(2026, 11, 11), 500, 0);
    await activity(DateTime(2026, 11, 12), 20, 0);
    expect((await repo.load(StatisticsPeriod.daily)).goalProgress, 0);
    await repo.setTodayGoal(100);
    final week = await repo.load(StatisticsPeriod.weekly);
    expect(week.goalProgress, 0.2);
    expect(week.goalCompleted, 20);
    await repo.setTodayGoal(10);
    expect((await repo.load(StatisticsPeriod.daily)).goalProgress, 1);
    expect(() => repo.setTodayGoal(0), throwsArgumentError);
  });
}
