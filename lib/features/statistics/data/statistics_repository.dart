import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';
import 'package:zikirmatik/features/statistics/domain/statistics_state.dart';

final statisticsRepositoryProvider = Provider<StatisticsRepository>(
  (ref) => StatisticsRepository(ref.watch(appDatabaseProvider)),
);

class StatisticsRepository {
  StatisticsRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final AppDatabase _db;
  final DateTime Function() _now;
  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<StatisticsState> load(
    StatisticsPeriod period,
  ) => _db.transaction(() async {
    final today = _day(_now());
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final weekStart = DateTime(today.year, today.month, today.day - 6);
    final monthStart = DateTime(today.year, today.month);
    final start = switch (period) {
      StatisticsPeriod.daily => today,
      StatisticsPeriod.weekly => weekStart,
      StatisticsPeriod.monthly => monthStart,
    };
    final activities = await (_db.select(
      _db.dailyActivities,
    )..where((r) => r.date.isSmallerThanValue(tomorrow))).get();
    final goals =
        await (_db.select(_db.dailyGoals)..where(
              (r) =>
                  r.date.isBiggerOrEqualValue(start) &
                  r.date.isSmallerThanValue(tomorrow),
            ))
            .get();
    final byDay = <DateTime, int>{};
    final byZikr = <String, int>{};
    var total = 0, week = 0, month = 0, selected = 0, elapsed = 0;
    for (final row in activities) {
      final day = _day(row.date);
      byDay.update(
        day,
        (value) => value + row.incrementCount,
        ifAbsent: () => row.incrementCount,
      );
      total += row.incrementCount;
      if (!day.isBefore(weekStart)) week += row.incrementCount;
      if (!day.isBefore(monthStart)) month += row.incrementCount;
      if (!day.isBefore(start)) {
        selected += row.incrementCount;
        elapsed += row.activeMilliseconds;
        byZikr.update(
          row.zikrId,
          (value) => value + row.incrementCount,
          ifAbsent: () => row.incrementCount,
        );
      }
    }
    final active = byDay.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toSet();
    var cursor = active.contains(today)
        ? today
        : DateTime(today.year, today.month, today.day - 1);
    var streak = 0;
    while (active.contains(cursor)) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    final orderedDays = active.toList()..sort();
    var longest = 0, run = 0;
    DateTime? previous;
    for (final day in orderedDays) {
      final next = previous == null
          ? null
          : DateTime(previous.year, previous.month, previous.day + 1);
      run = day == next ? run + 1 : 1;
      if (run > longest) longest = run;
      previous = day;
    }
    var target = 0, completed = 0, todayGoal = 0;
    for (final goal in goals) {
      if (goal.targetCount <= 0) continue;
      target += goal.targetCount;
      // Days without an explicitly configured goal do not inflate the percentage.
      completed += (byDay[_day(goal.date)] ?? 0).clamp(0, goal.targetCount);
      if (_day(goal.date) == today) todayGoal = goal.targetCount;
    }
    final names = {
      for (final z in await _db.select(_db.zikrs).get()) z.id: z.title,
    };
    final breakdown = byZikr.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final chartStart = period == StatisticsPeriod.monthly
        ? monthStart
        : weekStart;
    final chart = <DayCount>[];
    for (
      var day = chartStart;
      day.isBefore(tomorrow);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      chart.add(DayCount(date: day, count: byDay[day] ?? 0));
    }
    return StatisticsState(
      period: period,
      weeklyData: chart,
      zikrBreakdown: breakdown
          .map((e) => ZikrStat(title: names[e.key] ?? e.key, count: e.value))
          .toList(),
      todayTotal: byDay[today] ?? 0,
      weekTotal: week,
      monthTotal: month,
      allTimeTotal: total,
      streakDays: streak,
      longestStreak: longest,
      periodTotal: selected,
      activeDays: active.where((d) => !d.isBefore(start)).length,
      goalTarget: target,
      goalCompleted: completed,
      todayGoal: todayGoal,
      activeMilliseconds: elapsed,
    );
  });

  Future<void> setTodayGoal(int target) async {
    if (target <= 0) throw ArgumentError.value(target, 'target');
    final now = _now();
    final day = _day(now);
    await _db
        .into(_db.dailyGoals)
        .insertOnConflictUpdate(
          DailyGoalsCompanion.insert(
            date: day,
            targetCount: target,
            updatedAt: now,
          ),
        );
  }
}
