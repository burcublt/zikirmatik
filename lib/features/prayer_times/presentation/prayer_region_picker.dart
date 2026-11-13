import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/app/widgets/zikr_scaffold.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_region.dart';

class PrayerRegionPicker extends ConsumerStatefulWidget {
  const PrayerRegionPicker({super.key});
  @override
  ConsumerState<PrayerRegionPicker> createState() => _PrayerRegionPickerState();
}

class _PrayerRegionPickerState extends ConsumerState<PrayerRegionPicker> {
  String query = '';
  String? province;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final catalog = ref.watch(prayerRegionCatalogProvider);
    return ZikrScaffold(
      appBar: AppBar(title: Text(l.prayerRegionTitle)),
      body: SafeArea(
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(prayerRegionCatalogProvider),
              child: Text(l.retry),
            ),
          ),
          data: (catalog) {
            final provinces =
                catalog.regions.map((r) => r.province).toSet().toList()..sort();
            final visible =
                catalog.regions
                    .where(
                      (r) =>
                          (province == null || province == r.province) &&
                          normalizeRegionName(
                            '${r.province} ${r.name}',
                          ).contains(normalizeRegionName(query)),
                    )
                    .toList()
                  ..sort((a, b) {
                    final term = normalizeRegionName(query);
                    final aExact =
                        term.isNotEmpty && normalizeRegionName(a.name) == term;
                    final bExact =
                        term.isNotEmpty && normalizeRegionName(b.name) == term;
                    if (aExact != bExact) {
                      return aExact ? -1 : 1;
                    }
                    return a.label.compareTo(b.label);
                  });
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(l.prayerRegionPrompt),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => query = v),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l.prayerRegionSearch,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: province,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l.prayerAllProvinces,
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(l.prayerAllProvinces),
                      ),
                      for (final p in provinces)
                        DropdownMenuItem(
                          value: p,
                          child: Text(p, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) => setState(() => province = v),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, 'international'),
                  icon: const Icon(Icons.public),
                  label: Text(l.prayerInternationalCity),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? Center(child: Text(l.prayerRegionNoResults))
                      : ListView.builder(
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final r = visible[index];
                            return ListTile(
                              title: Text(r.name),
                              subtitle: Text(
                                '${r.province} · ${r.countryCode}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.pop(context, r),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
