import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zikirmatik/app/theme/app_palette.dart';
import 'package:zikirmatik/app/widgets/zikr_scaffold.dart';
import 'package:zikirmatik/core/localization/app_localizations_x.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_reminder_notifier.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_reminder_plan.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';
import 'package:zikirmatik/features/prayer_times/presentation/prayer_card.dart';

Future<void> showPrayerReminders(BuildContext context) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => const PrayerRemindersPage()));

Future<void> setPrayerReminder(
  BuildContext context,
  WidgetRef ref,
  PrayerName name, {
  bool? enabled,
  int? minutesBefore,
}) async {
  try {
    final success = await ref
        .read(prayerReminderNotifierProvider.notifier)
        .setPreference(name, enabled: enabled, minutesBefore: minutesBefore);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.prayerAlertUpdateFailed)),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.prayerAlertUpdateFailed)),
      );
    }
  }
}

class PrayerRemindersPage extends ConsumerWidget {
  const PrayerRemindersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(prayerReminderNotifierProvider);
    final schedule = ref.watch(prayerNotifierProvider).asData?.value.schedule;
    final now = ref.watch(prayerClockProvider).asData?.value ?? DateTime.now();
    final entries = schedule?.dayAt(now)?.entries ?? const <PrayerEntry>[];
    final icons = {
      PrayerName.fajr: Icons.dark_mode_outlined,
      PrayerName.dhuhr: Icons.wb_sunny_outlined,
      PrayerName.asr: Icons.wb_twilight,
      PrayerName.maghrib: Icons.wb_twilight_outlined,
      PrayerName.isha: Icons.nightlight_outlined,
    };
    return ZikrScaffold(
      appBar: AppBar(centerTitle: true, title: Text(l.prayerAlertsTitle)),
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(prayerReminderNotifierProvider),
              child: Text(l.retry),
            ),
          ),
          data: (preferences) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              Text(
                l.prayerAlertsDescription,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.palette.softGold),
              ),
              const SizedBox(height: 12),
              for (final name in reminderPrayerNames)
                Builder(
                  builder: (context) {
                    final pref =
                        preferences[name] ?? const PrayerReminderPreference();
                    final entry = entries
                        .where((e) => e.name == name)
                        .firstOrNull;
                    final option = pref.minutesBefore == 0
                        ? l.prayerAlertOnTime
                        : l.prayerAlertBefore(pref.minutesBefore);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.fromLTRB(12, 4, 8, 10),
                      decoration: BoxDecoration(
                        color: context.palette.surfaceGreen,
                        border: Border.all(
                          color: context.palette.gold.withValues(alpha: 0.7),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                icons[name],
                                color: context.palette.gold,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prayerNameLabel(l, name),
                                      style: TextStyle(
                                        color: context.palette.cream,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      entry == null
                                          ? l.prayerCalendarMissing
                                          : l.prayerAlertTime(
                                              DateFormat(
                                                'HH:mm',
                                              ).format(entry.at),
                                            ),
                                      style: TextStyle(
                                        color: context.palette.mutedText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                key: ValueKey('prayer-alert-${name.name}'),
                                value: pref.enabled,
                                onChanged: (value) => setPrayerReminder(
                                  context,
                                  ref,
                                  name,
                                  enabled: value,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final selection =
                                    await showModalBottomSheet<int>(
                                      context: context,
                                      builder: (sheet) => SafeArea(
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                            ListTile(
                                              title: Text(
                                                prayerNameLabel(l, name),
                                              ),
                                              trailing: IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(sheet),
                                                icon: const Icon(Icons.close),
                                              ),
                                            ),
                                            for (final minutes
                                                in reminderOffsets)
                                              ListTile(
                                                title: Text(
                                                  minutes == 0
                                                      ? l.prayerAlertOnTime
                                                      : l.prayerAlertBefore(
                                                          minutes,
                                                        ),
                                                ),
                                                selected:
                                                    minutes ==
                                                    pref.minutesBefore,
                                                trailing:
                                                    minutes ==
                                                        pref.minutesBefore
                                                    ? const Icon(
                                                        Icons.check_circle,
                                                      )
                                                    : null,
                                                onTap: () => Navigator.pop(
                                                  sheet,
                                                  minutes,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                if (selection != null && context.mounted) {
                                  await setPrayerReminder(
                                    context,
                                    ref,
                                    name,
                                    minutesBefore: selection,
                                  );
                                }
                              },
                              icon: const Icon(Icons.schedule),
                              label: Text(option),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              Text(
                l.prayerAlertPermissionInfo,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.palette.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
