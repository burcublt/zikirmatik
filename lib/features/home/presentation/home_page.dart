import 'package:zikirmatik/features/qibla/presentation/qibla_page.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_card.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_times_page.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/app/widgets/zikr_scaffold.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/domain/home_state.dart';
import 'package:zikirmatik/features/home/presentation/widgets/counter_display.dart';
import 'package:zikirmatik/features/home/presentation/widgets/main_bottom_nav.dart';
import 'package:zikirmatik/features/home/presentation/widgets/zikr_progress_card.dart';
import 'package:zikirmatik/features/home/presentation/widgets/tasbih_painter.dart';
import 'package:zikirmatik/features/settings/presentation/settings_page.dart';
import 'package:zikirmatik/features/statistics/presentation/statistics_page.dart';
import 'package:zikirmatik/features/zikrs/presentation/zikrs_page.dart';
import 'package:zikirmatik/features/zikrs/presentation/zikr_detail_page.dart';
import 'package:zikirmatik/features/zikrs/presentation/widgets/zikr_form_sheet.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      ref.read(homeNotifierProvider.notifier).pauseTiming();
    } else {
      unawaited(ref.read(homeNotifierProvider.notifier).refreshAfterResume());
      unawaited(ref.read(prayerNotifierProvider.notifier).refresh());
    }
  }

  int _selectedIndex = 0;
  void _onNavTap(int index) {
    ref.read(homeNotifierProvider.notifier).pauseTiming();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == 1) {
      return ZikrsPage(selectedNavIndex: 1, onNavTap: _onNavTap);
    }
    if (_selectedIndex == 3) {
      return StatisticsPage(selectedNavIndex: 3, onNavTap: _onNavTap);
    }
    if (_selectedIndex == 4) {
      return SettingsPage(selectedNavIndex: 4, onNavTap: _onNavTap);
    }
    if (_selectedIndex == 2) {
      return QiblaPage(onNavTap: _onNavTap);
    }
    final asyncState = ref.watch(homeNotifierProvider);
    final l10n = context.l10n;
    return ZikrScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.appTitle),
        actions: [
          GoldAddButton(
            label: l10n.addZikr,
            onPressed: () => showZikrFormSheet(context),
          ),
          SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
      body: asyncState.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorLoad),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(homeNotifierProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (state) => _HomeBody(
          state: state,
          onChangeZikr: () => _onNavTap(1),
          onZikrDetail: () {
            final zikr = state.activeZikr;
            if (zikr == null) {
              _onNavTap(1);
              return;
            }
            ref.read(homeNotifierProvider.notifier).pauseTiming();
            showZikrDetail(context, zikr, _onNavTap);
          },
          onPrayerTimes: () {
            ref.read(homeNotifierProvider.notifier).pauseTiming();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PrayerTimesPage(
                  onNavTap: (index) {
                    Navigator.of(context).pop();
                    _onNavTap(index);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({
    required this.state,
    required this.onChangeZikr,
    required this.onZikrDetail,
    required this.onPrayerTimes,
  });
  final HomeState state;
  final VoidCallback onChangeZikr;
  final VoidCallback onZikrDetail;
  final VoidCallback onPrayerTimes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final complete =
        state.activeZikr != null &&
        state.targetCount > 0 &&
        state.currentCount >= state.targetCount;
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Compact phones and large text can scroll instead of clipping controls.
          final minHeight =
              620.0 * math.min(MediaQuery.textScalerOf(context).scale(1), 1.5);
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: SizedBox(
                height: math.max(constraints.maxHeight, minHeight),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: PrayerCard(onTap: onPrayerTimes),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, area) {
                          final side = math.min(
                            area.maxWidth - 12,
                            area.maxHeight,
                          );
                          return Center(
                            child: Semantics(
                              button: true,
                              enabled: state.activeZikr != null,
                              label:
                                  '${state.activeZikr?.title ?? l10n.noZikrSelected}, ${l10n.currentCount}: ${state.currentCount}, ${l10n.target}: ${state.targetCount}',
                              onTap: state.activeZikr == null
                                  ? onChangeZikr
                                  : ref
                                        .read(homeNotifierProvider.notifier)
                                        .increment,
                              child: GestureDetector(
                                key: ValueKey('tasbih-counter'),
                                behavior: HitTestBehavior.opaque,
                                onTap: state.activeZikr == null
                                    ? onChangeZikr
                                    : ref
                                          .read(homeNotifierProvider.notifier)
                                          .increment,
                                child: SizedBox(
                                  width: side,
                                  height: side,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CustomPaint(
                                        size: Size.square(side),
                                        painter: TasbihPainter(
                                          totalBeads: 33,
                                          filledBeads: complete
                                              ? 33
                                              : state.currentCount % 33,
                                          progress: state.targetCount > 0
                                              ? (state.currentCount /
                                                        state.targetCount)
                                                    .clamp(0.0, 1.0)
                                              : 0,
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: Offset(0, -side * 0.09),
                                        child: Container(
                                          width: side * 0.59,
                                          height: side * 0.59,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              center: Alignment(-0.4, -0.4),
                                              colors: [
                                                context.palette.elevatedGreen,
                                                context.palette.deepGreen,
                                              ],
                                            ),
                                            border: Border.all(
                                              color: context.palette.gold
                                                  .withValues(alpha: 0.75),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.35,
                                                ),
                                                blurRadius: 18,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(18),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: CounterDisplay(
                                                currentCount:
                                                    state.currentCount,
                                                targetCount: state.targetCount,
                                                isComplete: complete,
                                                hasActiveZikr:
                                                    state.activeZikr != null,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: InkWell(
                        onTap: onZikrDetail,
                        child: Text(
                          state.activeZikr?.title ?? l10n.noZikrSelected,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.palette.softGold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    GoldAddButton(
                      size: 56,
                      label: l10n.zikrSelectChange,
                      onPressed: onChangeZikr,
                    ),
                    GestureDetector(
                      onTap: onChangeZikr,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 2, 16, 14),
                        child: Text(
                          l10n.zikrSelectChange,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.palette.cream,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    ZikrProgressCard(
                      title: state.activeZikr?.title ?? l10n.noZikrSelected,
                      currentCount: state.currentCount,
                      targetCount: state.targetCount,
                      onTap: onZikrDetail,
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
