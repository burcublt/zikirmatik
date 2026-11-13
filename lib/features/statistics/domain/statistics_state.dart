enum StatisticsPeriod { daily, weekly, monthly }

class DayCount {
  const DayCount({required this.date, required this.count});
  final DateTime date;
  final int count;
}

class ZikrStat {
  const ZikrStat({required this.title, required this.count});
  final String title;
  final int count;
}

class StatisticsState {
  const StatisticsState({
    required this.weeklyData,
    required this.zikrBreakdown,
    required this.todayTotal,
    required this.weekTotal,
    required this.monthTotal,
    required this.allTimeTotal,
    required this.streakDays,
    required this.longestStreak,
    this.period = StatisticsPeriod.daily,
    this.periodTotal = 0,
    this.activeDays = 0,
    this.goalTarget = 0,
    this.goalCompleted = 0,
    this.activeMilliseconds = 0,
    this.todayGoal = 0,
  });
  final List<DayCount> weeklyData;
  final List<ZikrStat> zikrBreakdown;
  final int todayTotal,
      weekTotal,
      monthTotal,
      allTimeTotal,
      streakDays,
      longestStreak;
  final StatisticsPeriod period;
  final int periodTotal,
      activeDays,
      goalTarget,
      goalCompleted,
      activeMilliseconds,
      todayGoal;
  double get goalProgress =>
      goalTarget > 0 ? (goalCompleted / goalTarget).clamp(0.0, 1.0) : 0;
  static const empty = StatisticsState(
    weeklyData: [],
    zikrBreakdown: [],
    todayTotal: 0,
    weekTotal: 0,
    monthTotal: 0,
    allTimeTotal: 0,
    streakDays: 0,
    longestStreak: 0,
  );
}
