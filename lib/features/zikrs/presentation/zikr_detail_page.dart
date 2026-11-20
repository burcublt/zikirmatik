import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/app/widgets/zikr_scaffold.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/presentation/widgets/main_bottom_nav.dart';
import 'package:zikirmatik/features/zikrs/application/zikrs_notifier.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';
import 'package:zikirmatik/features/zikrs/presentation/widgets/zikr_form_sheet.dart';

class ZikrDetailData {
  const ZikrDetailData(this.progress, this.history);
  final CounterProgressesData? progress;
  final List<DailyActivity> history;
  int get total => history.fold(0, (total, day) => total + day.incrementCount);
  DateTime? get last => history.fold<DateTime?>(
    null,
    (last, day) =>
        last == null || day.updatedAt.isAfter(last) ? day.updatedAt : last,
  );
}

final zikrDetailDataProvider = StreamProvider.autoDispose
    .family<ZikrDetailData, String>((ref, id) {
      final db = ref.watch(appDatabaseProvider);
      final query = db.select(db.dailyActivities)
        ..where((row) => row.zikrId.equals(id))
        ..orderBy([(row) => OrderingTerm.desc(row.date)]);
      return query.watch().asyncMap((history) async {
        final progress = await (db.select(
          db.counterProgresses,
        )..where((row) => row.zikrId.equals(id))).getSingleOrNull();
        return ZikrDetailData(progress, history);
      });
    });

Future<void> showZikrDetail(
  BuildContext context,
  ZikrDefinition zikr,
  ValueChanged<int> onNavTap,
) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => ZikrDetailPage(zikr: zikr, onNavTap: onNavTap),
    ),
  );
}

enum _HistoryPeriod { all, week, month, year }

class ZikrDetailPage extends ConsumerStatefulWidget {
  const ZikrDetailPage({super.key, required this.zikr, required this.onNavTap});
  final ZikrDefinition zikr;
  final ValueChanged<int> onNavTap;
  @override
  ConsumerState<ZikrDetailPage> createState() => _ZikrDetailPageState();
}

class _ZikrDetailPageState extends ConsumerState<ZikrDetailPage> {
  final _historyController = ScrollController();
  @override
  void dispose() {
    _historyController.dispose();
    super.dispose();
  }

  bool _expanded = false;
  bool _starting = false;
  _HistoryPeriod _period = _HistoryPeriod.all;

  void _navigate(int index) {
    Navigator.of(context).pop();
    widget.onNavTap(index);
  }

  Future<void> _start(ZikrDefinition zikr) async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      await ref.read(homeNotifierProvider.notifier).selectZikr(zikr);
      if (mounted) _navigate(0);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.errorSave)));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _edit(ZikrDefinition zikr) async {
    await showZikrFormSheet(context, editZikr: zikr);
    if (!mounted) return;
    final list = await ref.read(zikrsNotifierProvider.future);
    if (!mounted) return;
    final updated = list.where((item) => item.id == zikr.id).firstOrNull;
    if (updated != null &&
        ref.read(homeNotifierProvider).asData?.value.activeZikr?.id ==
            zikr.id) {
      await ref.read(homeNotifierProvider.notifier).selectZikr(updated);
    }
    if (mounted) ref.invalidate(zikrDetailDataProvider(zikr.id));
  }

  Future<void> _delete(ZikrDefinition zikr) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.deleteZikrConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(zikrsNotifierProvider.notifier).delete(zikr);
    if (!mounted) return;
    if (ref.read(homeNotifierProvider).asData?.value.activeZikr?.id ==
        zikr.id) {
      final remaining = await ref.read(zikrsNotifierProvider.future);
      if (!mounted) return;
      if (remaining.isNotEmpty) {
        await ref
            .read(homeNotifierProvider.notifier)
            .selectZikr(remaining.first);
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  List<DailyActivity> _filter(List<DailyActivity> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = switch (_period) {
      _HistoryPeriod.all => null,
      _HistoryPeriod.week => DateTime(
        today.year,
        today.month,
        today.day - (today.weekday - 1),
      ),
      _HistoryPeriod.month => DateTime(today.year, today.month),
      _HistoryPeriod.year => DateTime(today.year),
    };
    return history
        .where(
          (row) =>
              (start == null || !row.date.isBefore(start)) &&
              row.date.isBefore(
                DateTime(today.year, today.month, today.day + 1),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = ref.watch(zikrsNotifierProvider).asData?.value;
    final zikr =
        items?.where((z) => z.id == widget.zikr.id).firstOrNull ?? widget.zikr;
    final async = ref.watch(zikrDetailDataProvider(zikr.id));
    return ZikrScaffold(
      appBar: AppBar(centerTitle: true, title: Text(l.zikrDetailTitle)),
      bottomNavigationBar: MainBottomNav(currentIndex: 1, onTap: _navigate),
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(zikrDetailDataProvider(zikr.id)),
              child: Text(l.retry),
            ),
          ),
          data: (data) {
            final count = data.progress?.currentCount ?? 0;
            final target = data.progress?.targetCount ?? zikr.defaultTarget;
            final ratio = target > 0 ? (count / target).clamp(0.0, 1.0) : 0.0;
            final locale = Localizations.localeOf(context).toString();
            final filtered = _filter(data.history);
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.5),
                      radius: 1.1,
                      colors: [
                        context.palette.elevatedGreen,
                        context.palette.deepGreen,
                      ],
                    ),
                    border: Border.all(
                      color: context.palette.gold.withValues(alpha: 0.75),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(90),
                      topRight: Radius.circular(90),
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        zikr.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'NotoSerif',
                          color: context.palette.cream,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (zikr.description != null &&
                          zikr.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          zikr.description!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'NotoSerif',
                            fontStyle: FontStyle.italic,
                            color: context.palette.cream,
                            fontSize: 15,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Center(
                        child: SizedBox(
                          width: 190,
                          height: 190,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox.expand(
                                child: CircularProgressIndicator(
                                  value: 1,
                                  strokeWidth: 12,
                                  color: context.palette.gold.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox.expand(
                                child: CircularProgressIndicator(
                                  value: ratio,
                                  strokeWidth: 12,
                                  strokeCap: StrokeCap.round,
                                  color: const Color(0xFF80DE9A),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_outline_rounded,
                                    color: context.palette.gold,
                                  ),
                                  Text(
                                    l.formattedCount(count),
                                    style: TextStyle(
                                      color: context.palette.cream,
                                      fontSize: 52,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    '/ ${l.formattedCount(target)}',
                                    style: TextStyle(
                                      color: context.palette.mutedText,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _metric(
                        context,
                        Icons.track_changes,
                        l.target,
                        l.formattedCount(target),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _metric(
                        context,
                        Icons.bar_chart_rounded,
                        l.detailTotal,
                        l.formattedCount(data.total),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _card(
                  context,
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.detailProgress,
                                style: TextStyle(
                                  color: context.palette.cream,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              NumberFormat.percentPattern(locale).format(ratio),
                              style: const TextStyle(
                                color: Color(0xFF80DE9A),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 10,
                            color: context.palette.gold,
                            backgroundColor: context.palette.elevatedGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _card(
                  context,
                  ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: context.palette.gold,
                    ),
                    title: Text(
                      l.detailLast,
                      style: TextStyle(color: context.palette.cream),
                    ),
                    subtitle: Text(
                      data.last == null
                          ? l.detailNoLast
                          : DateFormat.yMMMd(
                              locale,
                            ).add_Hm().format(data.last!.toLocal()),
                      style: TextStyle(color: context.palette.mutedText),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _starting ? null : () => _start(zikr),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l.detailStart),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.palette.gold,
                    foregroundColor: context.palette.deepGreen,
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _card(
                  context,
                  Column(
                    children: [
                      ListTile(
                        key: const ValueKey('detail-history-toggle'),
                        leading: Icon(
                          Icons.history,
                          color: context.palette.gold,
                        ),
                        title: Text(
                          l.detailHistory,
                          style: TextStyle(
                            color: context.palette.softGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more,
                          color: context.palette.gold,
                        ),
                        onTap: () => setState(() => _expanded = !_expanded),
                      ),
                      if (_expanded) ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              for (final entry in [
                                (_HistoryPeriod.all, l.detailAllTime),
                                (_HistoryPeriod.week, l.detailWeek),
                                (_HistoryPeriod.month, l.detailMonth),
                                (_HistoryPeriod.year, l.detailYear),
                              ])
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: 6,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(entry.$2),
                                    selected: _period == entry.$1,
                                    onSelected: (_) =>
                                        setState(() => _period = entry.$1),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Text(
                              l.detailNoHistory,
                              style: TextStyle(
                                color: context.palette.mutedText,
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 240,
                            child: Scrollbar(
                              controller: _historyController,
                              thumbVisibility: true,
                              child: ListView.builder(
                                controller: _historyController,
                                key: const ValueKey('detail-history-list'),
                                primary: false,
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  8,
                                  10,
                                  8,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final day = filtered[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                      color: context.palette.elevatedGreen
                                          .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        dense: true,
                                        leading: Icon(
                                          Icons.calendar_month_outlined,
                                          color: context.palette.gold,
                                        ),
                                        title: Text(
                                          DateFormat.yMMMd(
                                            locale,
                                          ).format(day.date),
                                          style: TextStyle(
                                            color: context.palette.cream,
                                          ),
                                        ),
                                        trailing: Text(
                                          l.repeatCount(day.incrementCount),
                                          style: TextStyle(
                                            color: context.palette.cream,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _edit(zikr),
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l.edit),
                      ),
                    ),
                    if (!zikr.isBuiltIn) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _delete(zikr),
                          icon: const Icon(Icons.delete_outline),
                          label: Text(l.delete),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _card(BuildContext context, Widget child) => Container(
    decoration: BoxDecoration(
      color: context.palette.surfaceGreen.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.palette.gold.withValues(alpha: 0.65)),
    ),
    child: Material(color: Colors.transparent, child: child),
  );
  Widget _metric(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) => _card(
    context,
    Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: context.palette.gold, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  style: TextStyle(color: context.palette.cream, fontSize: 12),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: context.palette.cream,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
