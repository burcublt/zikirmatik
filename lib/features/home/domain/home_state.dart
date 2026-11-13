import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';

class HomeState {
  const HomeState({
    this.activeZikr,
    this.currentCount = 0,
    this.targetCount = 100,
    this.dailyTotal = 0,
    this.streakDays = 0,
    this.totalCount = 0,
    this.vibrationEnabled = true,
    this.isLoading = true,
  });

  final ZikrDefinition? activeZikr;
  final int currentCount;
  final int targetCount;
  final int dailyTotal;
  final int streakDays;
  final int totalCount;
  final bool vibrationEnabled;
  final bool isLoading;

  HomeState copyWith({
    ZikrDefinition? activeZikr,
    int? currentCount,
    int? targetCount,
    int? dailyTotal,
    int? streakDays,
    int? totalCount,
    bool? vibrationEnabled,
    bool? isLoading,
    bool clearActiveZikr = false,
  }) {
    return HomeState(
      activeZikr: clearActiveZikr ? null : (activeZikr ?? this.activeZikr),
      currentCount: currentCount ?? this.currentCount,
      targetCount: targetCount ?? this.targetCount,
      dailyTotal: dailyTotal ?? this.dailyTotal,
      streakDays: streakDays ?? this.streakDays,
      totalCount: totalCount ?? this.totalCount,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
