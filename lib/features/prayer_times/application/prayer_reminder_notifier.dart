import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/features/prayer_times/application/prayer_notifier.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_notification_service.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_reminder_preferences.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_reminder_plan.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';
import 'package:zikirmatik/features/settings/application/settings_notifier.dart';

final prayerReminderNotifierProvider =
    AsyncNotifierProvider<
      PrayerReminderNotifier,
      Map<PrayerName, PrayerReminderPreference>
    >(PrayerReminderNotifier.new);

class PrayerReminderNotifier
    extends AsyncNotifier<Map<PrayerName, PrayerReminderPreference>> {
  Future<void> _queue = Future.value();
  bool _busy = false;
  @override
  Future<Map<PrayerName, PrayerReminderPreference>> build() async {
    final timer = Timer.periodic(
      const Duration(hours: 6),
      (_) => unawaited(refresh()),
    );
    ref.onDispose(timer.cancel);
    ref.listen(prayerNotifierProvider, (previous, next) {
      if (next.asData != null) unawaited(refresh());
    });
    ref.listen(settingsNotifierProvider, (previous, next) {
      if (previous?.asData?.value.localeCode != next.asData?.value.localeCode) {
        unawaited(refresh());
      }
    });
    final value = await ref.read(prayerReminderPreferencesProvider).read();
    // Restore future reminders after a fresh launch when the schedule is ready.
    Future<void>(() {
      if (ref.mounted) unawaited(refresh());
    });
    return value;
  }

  Future<T> _serial<T>(Future<T> Function() operation) {
    final result = _queue.then((_) => operation());
    _queue = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace stack) {},
    );
    return result;
  }

  Future<void> refresh() async {
    try {
      await _serial(() async {
        if (!ref.mounted) return;
        final value = state.asData?.value;
        if (value == null || !value.values.any((p) => p.enabled)) return;
        final current = ref.read(prayerNotifierProvider).asData?.value;
        if (current == null) return;
        final service = ref.read(prayerNotificationServiceProvider);
        final schedule = current.schedule;
        if (schedule == null || !await service.permission(request: false)) {
          await service.cancel();
          return;
        }
        await service.schedule(
          schedule,
          value,
          ref
                  .read(settingsNotifierProvider)
                  .asData
                  ?.value
                  .locale
                  .languageCode ??
              'tr',
        );
      });
    } catch (_) {
      // Preferences remain saved and another schedule update can retry.
    }
  }

  Future<bool> setPreference(
    PrayerName name, {
    bool? enabled,
    int? minutesBefore,
  }) async {
    if (_busy || !reminderPrayerNames.contains(name)) return false;
    final previous = state.asData?.value;
    if (previous == null) return false;
    final old = previous[name] ?? const PrayerReminderPreference();
    final value = PrayerReminderPreference(
      enabled: enabled ?? old.enabled,
      minutesBefore: minutesBefore ?? old.minutesBefore,
    );
    if (!reminderOffsets.contains(value.minutesBefore)) return false;
    final next = {...previous, name: value};
    final schedule = ref.read(prayerNotifierProvider).asData?.value.schedule;
    if (enabled == true && !old.enabled) {
      if (schedule == null ||
          planPrayerReminders(
            schedule: schedule,
            preferences: {name: value},
            now: DateTime.now(),
            limit: 1,
          ).isEmpty) {
        return false;
      }
    }
    _busy = true;
    try {
      return await _serial(() async {
        final service = ref.read(prayerNotificationServiceProvider);
        if (next.values.any((p) => p.enabled) && schedule != null) {
          final allowed = await service.permission(
            request: enabled == true && !old.enabled,
          );
          if (!allowed && enabled == true && !old.enabled) return false;
          if (!allowed) {
            await service.cancel();
          } else {
            await service.schedule(
              schedule,
              next,
              ref
                      .read(settingsNotifierProvider)
                      .asData
                      ?.value
                      .locale
                      .languageCode ??
                  'tr',
            );
          }
        } else {
          await service.cancel();
        }
        try {
          await ref.read(prayerReminderPreferencesProvider).save(next);
        } catch (_) {
          if (schedule != null && previous.values.any((p) => p.enabled)) {
            await service.schedule(
              schedule,
              previous,
              ref
                      .read(settingsNotifierProvider)
                      .asData
                      ?.value
                      .locale
                      .languageCode ??
                  'tr',
            );
          } else {
            await service.cancel();
          }
          rethrow;
        }
        if (ref.mounted) state = AsyncData(next);
        return true;
      });
    } finally {
      _busy = false;
    }
  }
}
