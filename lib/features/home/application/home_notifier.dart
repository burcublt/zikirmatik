import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/core/services/counter_feedback.dart';
import 'package:zikirmatik/features/home/data/home_repository.dart';
import 'package:zikirmatik/features/home/domain/home_state.dart';
import 'package:zikirmatik/features/settings/application/settings_notifier.dart';
import 'package:zikirmatik/features/zikrs/data/drift_zikr_repository.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';

final homeNotifierProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends AsyncNotifier<HomeState> {
  final _activity = TapActivityClock();
  Future<void> _pending = Future.value();
  DateTime? _totalsDay;
  int _revision = 0;
  @override
  Future<HomeState> build() async {
    final zikrs = await ref.watch(zikrRepositoryProvider).watchActive().first;
    final repo = ref.read(homeRepositoryProvider);
    final settings = await ref.read(settingsNotifierProvider.future);
    final selectedId = await repo.getSelectedZikrId();
    final active =
        zikrs.where((z) => z.id == selectedId).firstOrNull ?? zikrs.firstOrNull;
    _totalsDay = repo.currentDay;
    final progress = active == null
        ? null
        : await repo.getCounterProgress(active.id);
    return HomeState(
      activeZikr: active,
      currentCount: progress?.currentCount ?? 0,
      targetCount: progress?.targetCount ?? active?.defaultTarget ?? 100,
      dailyTotal: await repo.getDailyTotal(),
      totalCount: await repo.getTotalCount(),
      streakDays: await repo.getStreakDays(),
      vibrationEnabled: settings.vibrationEnabled,
      isLoading: false,
    );
  }

  void pauseTiming() => _activity.pause();

  Future<void> increment() async {
    final current = state.asData?.value;
    if (current == null || current.activeZikr == null || current.isLoading) {
      return;
    }
    final repo = ref.read(homeRepositoryProvider);
    final today = repo.currentDay;
    final dailyTotal = _totalsDay == today ? current.dailyTotal : 0;
    _totalsDay = today;
    _revision++;
    final elapsed = _activity.tap();
    final count = current.currentCount >= current.targetCount
        ? 1
        : current.currentCount + 1;
    state = AsyncData(
      current.copyWith(
        currentCount: count,
        dailyTotal: dailyTotal + 1,
        totalCount: current.totalCount + 1,
      ),
    );
    final settings = ref.read(settingsNotifierProvider).asData?.value;
    unawaited(
      ref
          .read(counterFeedbackProvider)
          .play(
            sound: settings?.soundEnabled ?? false,
            vibration: current.vibrationEnabled,
          ),
    );
    final operation = _pending.then(
      (_) => repo.increment(
        zikrId: current.activeZikr!.id,
        targetCount: current.targetCount,
        activeMilliseconds: elapsed,
      ),
    );
    _pending = operation.catchError((Object _) {});
    try {
      await operation;
      final streak = await repo.getStreakDays();
      if (ref.mounted && state.hasValue) {
        state = AsyncData(state.requireValue.copyWith(streakDays: streak));
      }
    } catch (error, stack) {
      if (ref.mounted) state = AsyncError(error, stack);
    }
  }

  /// Refreshes totals after returning to the app without changing the selection.
  Future<void> refreshAfterResume() async {
    pauseTiming();
    final revision = _revision;
    await _pending;
    if (!ref.mounted || !state.hasValue) return;
    final repo = ref.read(homeRepositoryProvider);
    final daily = await repo.getDailyTotal();
    final total = await repo.getTotalCount();
    final streak = await repo.getStreakDays();
    if (ref.mounted && revision == _revision && state.hasValue) {
      _totalsDay = repo.currentDay;
      state = AsyncData(
        state.requireValue.copyWith(
          dailyTotal: daily,
          totalCount: total,
          streakDays: streak,
        ),
      );
    }
  }

  void syncVibration({required bool enabled}) {
    final current = state.asData?.value;
    if (current != null) {
      state = AsyncData(current.copyWith(vibrationEnabled: enabled));
    }
  }

  void toggleVibration() {
    final enabled = !(state.asData?.value.vibrationEnabled ?? true);
    syncVibration(enabled: enabled);
    unawaited(
      ref
          .read(settingsNotifierProvider.notifier)
          .setVibration(enabled: enabled),
    );
  }

  Future<void> selectZikr(ZikrDefinition zikr) async {
    pauseTiming();
    _revision++;
    await _pending;
    final current = state.asData?.value ?? const HomeState();
    final repo = ref.read(homeRepositoryProvider);
    state = AsyncData(current.copyWith(isLoading: true));
    try {
      await repo.upsertCounterTarget(
        zikrId: zikr.id,
        targetCount: zikr.defaultTarget,
      );
      final progress = await repo.getCounterProgress(zikr.id);
      state = AsyncData(
        current.copyWith(
          activeZikr: zikr,
          currentCount: progress?.currentCount ?? 0,
          targetCount: progress?.targetCount ?? zikr.defaultTarget,
          isLoading: false,
        ),
      );
    } catch (_) {
      if (ref.mounted) state = AsyncData(current);
      rethrow;
    }
  }
}
