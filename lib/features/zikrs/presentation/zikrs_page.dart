import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/app/widgets/zikr_scaffold.dart';
import 'package:zikirmatik/core/ads/admob.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/home/application/home_notifier.dart';
import 'package:zikirmatik/features/home/presentation/widgets/main_bottom_nav.dart';
import 'package:zikirmatik/features/zikrs/application/zikrs_notifier.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_search.dart';
import 'package:zikirmatik/features/zikrs/data/zikr_progress_provider.dart';
import 'package:zikirmatik/features/zikrs/presentation/widgets/zikr_form_sheet.dart';
import 'package:zikirmatik/features/zikrs/presentation/zikr_detail_page.dart';
import 'package:zikirmatik/features/zikrs/presentation/widgets/zikr_list_tile.dart';

class ZikrsPage extends ConsumerStatefulWidget {
  const ZikrsPage({
    super.key,
    required this.selectedNavIndex,
    required this.onNavTap,
  });
  final int selectedNavIndex;
  final ValueChanged<int> onNavTap;
  @override
  ConsumerState<ZikrsPage> createState() => _ZikrsPageState();
}

class _ZikrsPageState extends ConsumerState<ZikrsPage> {
  final _search = TextEditingController();
  String _query = '';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
    if (confirmed == true && mounted) {
      await ref.read(zikrsNotifierProvider.notifier).delete(zikr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final zikrs = ref.watch(zikrsNotifierProvider);
    final active = ref.watch(homeNotifierProvider).asData?.value.activeZikr?.id;
    final progress = ref.watch(zikrProgressProvider);
    return ZikrScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.zikrs),
        leading: BackButton(
          onPressed: () => widget.onNavTap(0),
          color: context.palette.softGold,
        ),
        actions: [
          GoldAddButton(
            label: l10n.addZikr,
            onPressed: () => showZikrFormSheet(context),
          ),
          SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: widget.selectedNavIndex,
        onTap: widget.onNavTap,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: TextField(
                controller: _search,
                onChanged: (value) =>
                    setState(() => _query = normalizeZikrSearch(value)),
                style: TextStyle(color: context.palette.cream, fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.palette.softGold,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: context.palette.deepGreen.withValues(alpha: 0.55),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.palette.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.palette.gold),
                  ),
                ),
              ),
            ),
            Expanded(
              child: zikrs.when(
                loading: () => Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(zikrsNotifierProvider),
                    child: Text(l10n.retry),
                  ),
                ),
                data: (all) {
                  final filtered = all
                      .where(
                        (z) => normalizeZikrSearch(z.title).contains(_query),
                      )
                      .toList();
                  if (filtered.isEmpty) {
                    return Center(child: Text(l10n.noSearchResult));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: 16),
                    itemCount: filtered.length + (filtered.length >= 6 ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (filtered.length >= 6 && index == 6) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: AdMobSlot(placement: AdPlacement.zikrList),
                        );
                      }
                      final zikr = filtered[index > 6 ? index - 1 : index];
                      return ZikrListTile(
                        key: ValueKey(zikr.id),
                        zikr: zikr,
                        isActive: active == zikr.id,
                        progress: progress.asData?.value[zikr.id],
                        progressReady: progress.hasValue,
                        onFavorite: () => ref
                            .read(zikrsNotifierProvider.notifier)
                            .toggleFavorite(zikr),
                        onSelect: () {
                          ref.read(homeNotifierProvider.notifier).pauseTiming();
                          showZikrDetail(context, zikr, widget.onNavTap);
                        },
                        onEdit: () =>
                            showZikrFormSheet(context, editZikr: zikr),
                        onDelete: zikr.isBuiltIn ? null : () => _delete(zikr),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
