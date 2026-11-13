import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/features/statistics/data/statistics_repository.dart';
import 'package:zikirmatik/features/statistics/domain/statistics_state.dart';

final statisticsNotifierProvider =
    AsyncNotifierProvider<StatisticsNotifier, StatisticsState>(
      StatisticsNotifier.new,
    );

class StatisticsNotifier extends AsyncNotifier<StatisticsState> {
  StatisticsPeriod _period = StatisticsPeriod.daily;
  int _generation = 0;
  @override
  Future<StatisticsState> build() =>
      ref.watch(statisticsRepositoryProvider).load(_period);
  Future<void> selectPeriod(StatisticsPeriod period) async {
    _period = period;
    await refresh();
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    final result = await AsyncValue.guard(
      () => ref.read(statisticsRepositoryProvider).load(_period),
    );
    if (ref.mounted && generation == _generation) state = result;
  }

  Future<void> setTodayGoal(int target) async {
    await ref.read(statisticsRepositoryProvider).setTodayGoal(target);
    await refresh();
  }
}
