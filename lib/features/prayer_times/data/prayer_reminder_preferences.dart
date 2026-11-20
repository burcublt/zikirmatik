import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_reminder_plan.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

final prayerReminderPreferencesProvider =
    Provider<PrayerReminderPreferencesRepository>(
      (ref) =>
          PrayerReminderPreferencesRepository(ref.watch(appDatabaseProvider)),
    );

/// Stored separately from the daily dhikr reminder and Firebase preferences.
class PrayerReminderPreferencesRepository {
  PrayerReminderPreferencesRepository(this._db);
  final AppDatabase _db;
  static const preferenceId = 7;
  Future<Map<PrayerName, PrayerReminderPreference>> read() async {
    final row = await (_db.select(
      _db.userPreferences,
    )..where((r) => r.id.equals(preferenceId))).getSingleOrNull();
    Map<dynamic, dynamic> raw = {};
    try {
      final parsed = jsonDecode(row?.localeCode ?? '{}');
      if (parsed is Map) raw = parsed;
    } catch (_) {}
    return {
      for (final name in reminderPrayerNames) name: _parse(raw[name.name]),
    };
  }

  PrayerReminderPreference _parse(Object? value) {
    if (value is! Map) return const PrayerReminderPreference();
    final minutes = value['minutesBefore'];
    return PrayerReminderPreference(
      enabled: value['enabled'] == true,
      minutesBefore: minutes is int && reminderOffsets.contains(minutes)
          ? minutes
          : 0,
    );
  }

  Future<void> save(
    Map<PrayerName, PrayerReminderPreference> preferences,
  ) async {
    final raw = <String, Object>{};
    for (final name in reminderPrayerNames) {
      final value = preferences[name] ?? const PrayerReminderPreference();
      if (!reminderOffsets.contains(value.minutesBefore)) {
        throw ArgumentError('Invalid offset');
      }
      raw[name.name] = {
        'enabled': value.enabled,
        'minutesBefore': value.minutesBefore,
      };
    }
    await _db
        .into(_db.userPreferences)
        .insertOnConflictUpdate(
          UserPreferencesCompanion.insert(
            id: const Value(preferenceId),
            localeCode: jsonEncode(raw),
            updatedAt: DateTime.now(),
          ),
        );
  }
}
