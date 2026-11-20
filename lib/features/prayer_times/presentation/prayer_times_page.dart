import 'package:zikirmatik/features/prayer_times/domain/prayer_region.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_region_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/app/widgets/zikr_scaffold.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/home/presentation/widgets/main_bottom_nav.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_reminder_notifier.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_reminders_page.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_card.dart';

class PrayerTimesPage extends ConsumerWidget {
  const PrayerTimesPage({super.key, this.onNavTap});
  final ValueChanged<int>? onNavTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(prayerNotifierProvider);
    final reminders = ref.watch(prayerReminderNotifierProvider).asData?.value;
    final state = async.asData?.value;
    final schedule = state?.schedule;
    final now = ref.watch(prayerClockProvider).asData?.value ?? DateTime.now();
    final next = schedule?.nextPrayer(now);
    final day = schedule?.dayAt(now);
    return ZikrScaffold(
      appBar: AppBar(centerTitle: true, title: Text(l10n.prayerTimes)),
      bottomNavigationBar: onNavTap == null
          ? null
          : MainBottomNav(currentIndex: 0, onTap: onNavTap!),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(prayerNotifierProvider.notifier).refresh(force: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        alignment: AlignmentDirectional.centerStart,
                      ),
                      onPressed: () => _chooseCity(context, ref),
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: context.palette.gold,
                      ),
                      label: Text(
                        schedule?.location.label.isNotEmpty == true
                            ? schedule!.location.label
                            : l10n.prayerCurrentLocation,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.palette.cream,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.prayerUseLocation,
                    onPressed: () => ref
                        .read(prayerNotifierProvider.notifier)
                        .refresh(requestPermission: true),
                    icon: const Icon(Icons.my_location_outlined),
                  ),
                ],
              ),
              PrayerCard(large: true, onTap: () => _chooseCity(context, ref)),
              if (state?.savedLocation == true)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Text(
                    l10n.prayerSavedLocation,
                    style: TextStyle(
                      color: context.palette.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (!async.isLoading && (schedule == null || day == null)) ...[
                const SizedBox(height: 16),
                Text(
                  switch (state?.status) {
                    PrayerStatus.denied ||
                    PrayerStatus.deniedForever => l10n.prayerPermissionDenied,
                    PrayerStatus.servicesDisabled =>
                      l10n.prayerLocationDisabled,
                    PrayerStatus.unavailable => l10n.prayerUnavailable,
                    PrayerStatus.needsRegion => l10n.prayerRegionPrompt,
                    PrayerStatus.calendarUnavailable =>
                      l10n.prayerCalendarMissing,
                    _ => l10n.prayerLocationExplanation,
                  },
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.palette.cream,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ref
                      .read(prayerNotifierProvider.notifier)
                      .refresh(requestPermission: true),
                  icon: const Icon(Icons.my_location),
                  label: Text(l10n.prayerUseLocation),
                ),
                TextButton(
                  onPressed: () => _chooseCity(context, ref),
                  child: Text(l10n.prayerChooseCity),
                ),
                if (state?.status == PrayerStatus.deniedForever ||
                    state?.status == PrayerStatus.servicesDisabled)
                  TextButton(
                    onPressed: state?.status == PrayerStatus.servicesDisabled
                        ? Geolocator.openLocationSettings
                        : Geolocator.openAppSettings,
                    child: Text(l10n.prayerOpenSettings),
                  ),
              ],
              if (day != null) ...[
                const SizedBox(height: 14),
                for (final entry in day.entries)
                  _PrayerRow(
                    entry: entry,
                    selected: entry.name == next?.name && entry.at == next?.at,
                    alarmEnabled: reminders?[entry.name]?.enabled,
                    onAlarm:
                        entry.name == PrayerName.sunrise || reminders == null
                        ? null
                        : (value) => setPrayerReminder(
                            context,
                            ref,
                            entry.name,
                            enabled: value,
                          ),
                  ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => showPrayerReminders(context),
                  icon: const Icon(Icons.notifications),
                  label: Text(l10n.prayerAlertsTitle),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.palette.surfaceGreen,
                    border: Border.all(
                      color: context.palette.gold.withValues(alpha: 0.6),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: context.palette.gold,
                        size: 29,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.prayerTodayDate,
                              style: TextStyle(
                                color: context.palette.softGold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat(
                                'd MMMM EEEE',
                                l10n.localeName,
                              ).format(schedule!.localNow(now)),
                              style: TextStyle(
                                color: context.palette.cream,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  schedule.source == 'diyanet-annual'
                      ? l10n.prayerAnnualSource
                      : l10n.prayerSource,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.palette.mutedText,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseCity(BuildContext context, WidgetRef ref) async {
    final selection = await Navigator.of(context).push<Object>(
      MaterialPageRoute(builder: (_) => const PrayerRegionPicker()),
    );
    if (selection == null || !context.mounted) return;
    if (selection is PrayerRegion) {
      final changed = await ref
          .read(prayerNotifierProvider.notifier)
          .setRegion(selection);
      if (!changed && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.prayerCalendarMissing)),
        );
      }
      return;
    }
    final city = await showDialog<String>(
      context: context,
      builder: (_) => const _CityDialog(),
    );
    if (city == null || !context.mounted) return;
    final changed = await ref
        .read(prayerNotifierProvider.notifier)
        .setCity(city);
    if (!changed && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.prayerCityNotFound)));
    }
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.entry,
    required this.selected,
    this.alarmEnabled,
    this.onAlarm,
  });
  final PrayerEntry entry;
  final bool selected;
  final bool? alarmEnabled;
  final ValueChanged<bool>? onAlarm;
  @override
  Widget build(BuildContext context) {
    final icons = {
      PrayerName.fajr: Icons.dark_mode_outlined,
      PrayerName.sunrise: Icons.wb_sunny_outlined,
      PrayerName.dhuhr: Icons.wb_sunny,
      PrayerName.asr: Icons.wb_twilight,
      PrayerName.maghrib: Icons.wb_twilight_outlined,
      PrayerName.isha: Icons.nightlight_outlined,
    };
    final ink = selected ? context.palette.deepGreen : context.palette.cream;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected
            ? context.palette.gold
            : context.palette.surfaceGreen.withValues(alpha: 0.6),
        border: Border.all(color: context.palette.outline, width: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icons[entry.name],
            color: selected ? ink : context.palette.gold,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              prayerNameLabel(context.l10n, entry.name),
              style: TextStyle(
                color: ink,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            DateFormat('HH:mm').format(entry.at),
            style: TextStyle(
              color: ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (entry.name != PrayerName.sunrise) ...[
            const SizedBox(width: 6),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                key: ValueKey('prayer-row-${entry.name.name}'),
                value: alarmEnabled ?? false,
                onChanged: onAlarm,
              ),
            ),
          ] else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _CityDialog extends StatefulWidget {
  const _CityDialog();
  @override
  State<_CityDialog> createState() => _CityDialogState();
}

class _CityDialogState extends State<_CityDialog> {
  final _controller = TextEditingController();
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.prayerChooseCity),
    content: Form(
      key: _form,
      child: TextFormField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(hintText: context.l10n.prayerCityHint),
        validator: (value) => value == null || value.trim().isEmpty
            ? context.l10n.fieldRequired
            : null,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, _controller.text.trim());
          }
        },
        child: Text(context.l10n.confirm),
      ),
    ],
  );
}
