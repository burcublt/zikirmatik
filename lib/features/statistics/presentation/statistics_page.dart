import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/app/widgets/zikr_scaffold.dart';
import 'package:zikirmatik/core/ads/admob.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/home/presentation/widgets/main_bottom_nav.dart';
import 'package:zikirmatik/features/statistics/application/statistics_notifier.dart';
import 'package:zikirmatik/features/statistics/domain/statistics_state.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({
    super.key,
    required this.selectedNavIndex,
    required this.onNavTap,
  });
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(statisticsNotifierProvider);
    final notifier = ref.read(statisticsNotifierProvider.notifier);
    return ZikrScaffold(
      appBar: AppBar(centerTitle: true, title: Text(l10n.statistics)),
      bottomNavigationBar: MainBottomNav(
        currentIndex: selectedNavIndex,
        onTap: onNavTap,
      ),
      body: state.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: TextButton(
            onPressed: notifier.refresh,
            child: Text(l10n.retry),
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: notifier.refresh,
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              Row(
                children: StatisticsPeriod.values
                    .map(
                      (period) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: ChoiceChip(
                            showCheckmark: false,
                            selected: period == data.period,
                            labelPadding: EdgeInsets.symmetric(horizontal: 7),
                            selectedColor: context.palette.gold,
                            backgroundColor: context.palette.deepGreen,
                            side: BorderSide(color: context.palette.outline),
                            label: Center(
                              child: Text(
                                switch (period) {
                                  StatisticsPeriod.daily => l10n.daily,
                                  StatisticsPeriod.weekly => l10n.weekly,
                                  StatisticsPeriod.monthly => l10n.monthly,
                                },
                                style: TextStyle(
                                  color: period == data.period
                                      ? context.palette.deepGreen
                                      : context.palette.cream,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            onSelected: (_) => notifier.selectPeriod(period),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 226,
                  height: 226,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: data.goalProgress,
                          strokeWidth: 13,
                          strokeCap: StrokeCap.round,
                          color: Color(0xFFA4D49C),
                          backgroundColor: context.palette.outline.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(28),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                color: context.palette.gold,
                                size: 28,
                              ),
                              SizedBox(height: 8),
                              Text(
                                NumberFormat.decimalPattern(
                                  l10n.localeName,
                                ).format(data.periodTotal),
                                style: TextStyle(
                                  color: context.palette.cream,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                l10n.totalDhikr,
                                style: TextStyle(
                                  color: context.palette.cream,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Metric(
                      icon: Icons.calendar_month_outlined,
                      value: '${data.activeDays}',
                      label: l10n.days,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _Metric(
                      icon: Icons.track_changes_outlined,
                      value: data.goalTarget > 0
                          ? NumberFormat.percentPattern(
                              l10n.localeName,
                            ).format(data.goalProgress)
                          : l10n.setGoal,
                      label: l10n.target,
                      onTap: () => _setGoal(context, ref, data.todayGoal),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _Metric(
                      icon: Icons.access_time_rounded,
                      value: _duration(data.activeMilliseconds),
                      label: l10n.duration,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _setGoal(context, ref, data.todayGoal),
                icon: Icon(Icons.edit_outlined, size: 15),
                label: Text(
                  data.todayGoal > 0
                      ? '${l10n.dailyGoal}: ${data.todayGoal}'
                      : l10n.setDailyGoal,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(height: 10),
              Text(
                l10n.dhikrHistory,
                style: TextStyle(
                  color: context.palette.softGold,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              _HistoryChart(
                data: data.weeklyData,
                monthly: data.period == StatisticsPeriod.monthly,
              ),
              SizedBox(height: 8),
              AdMobSlot(placement: AdPlacement.statistics),
            ],
          ),
        ),
      ),
    );
  }

  String _duration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    return '${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  Future<void> _setGoal(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final l10n = context.l10n;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => _DailyGoalDialog(initial: current),
    );
    // Dispose after route exit animations have released the editing widget.
    if (context.mounted && result != null) {
      try {
        await ref
            .read(statisticsNotifierProvider.notifier)
            .setTodayGoal(result);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.errorSave)));
        }
      }
    }
  }
}

class _DailyGoalDialog extends StatefulWidget {
  const _DailyGoalDialog({required this.initial});
  final int initial;
  @override
  State<_DailyGoalDialog> createState() => _DailyGoalDialogState();
}

class _DailyGoalDialogState extends State<_DailyGoalDialog> {
  late final TextEditingController _controller;
  final _form = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initial > 0 ? '${widget.initial}' : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.setDailyGoal),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.dailyGoal),
          validator: (value) =>
              (int.tryParse(value ?? '') ?? 0) > 0 ? null : l10n.invalidTarget,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.pop(context, int.parse(_controller.text));
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });
  final IconData icon;
  final String value, label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.palette.surfaceGreen.withValues(alpha: 0.6),
      border: Border.all(color: context.palette.outline, width: 0.7),
      borderRadius: BorderRadius.circular(14),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: context.palette.gold, size: 25),
            SizedBox(height: 9),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: context.palette.cream,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.palette.cream, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HistoryChart extends StatelessWidget {
  const _HistoryChart({required this.data, required this.monthly});
  final List<DayCount> data;
  final bool monthly;
  @override
  Widget build(BuildContext context) {
    final max = data.fold(1, (max, day) => math.max(max, day.count));
    final labels = [
      context.l10n.monAbbr,
      context.l10n.tueAbbr,
      context.l10n.wedAbbr,
      context.l10n.thuAbbr,
      context.l10n.friAbbr,
      context.l10n.satAbbr,
      context.l10n.sunAbbr,
    ];
    return SizedBox(
      height: 112,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((day) {
          final label = monthly
              ? (day.date.day == 1 || day.date.day % 5 == 0
                    ? '${day.date.day}'
                    : '')
              : labels[day.date.weekday - 1];
          return Expanded(
            child: Semantics(
              label:
                  '${DateFormat.yMd(context.l10n.localeName).format(day.date)}: ${day.count}',
              child: Tooltip(
                message: '${day.count}',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: monthly ? 6 : 16,
                      height: day.count == 0 ? 2 : 6 + day.count / max * 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            context.palette.gold,
                            Color(0xFF6EAD76).withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                        border: Border.all(
                          color: context.palette.gold.withValues(alpha: 0.6),
                          width: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 7),
                    SizedBox(
                      height: 23,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: context.palette.cream,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
