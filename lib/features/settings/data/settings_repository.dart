import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';

class AppSettings {
  const AppSettings({
    this.vibrationEnabled = true,
    this.soundEnabled = false,
    this.themeMode = ThemeMode.dark,
    this.reminderEnabled = false,
    this.pushNotificationsEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.localeCode,
  });
  final bool vibrationEnabled, soundEnabled, reminderEnabled;
  final bool pushNotificationsEnabled;
  final ThemeMode themeMode;
  final int reminderHour, reminderMinute;
  final String? localeCode;
  Locale get locale => Locale(switch (localeCode) {
    'en' => 'en',
    'ar' => 'ar',
    _ => 'tr',
  });
  AppSettings copyWith({
    bool? vibrationEnabled,
    bool? soundEnabled,
    bool? reminderEnabled,
    bool? pushNotificationsEnabled,
    ThemeMode? themeMode,
    int? reminderHour,
    int? reminderMinute,
    String? localeCode,
    bool clearLocale = false,
  }) => AppSettings(
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    themeMode: themeMode ?? this.themeMode,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    pushNotificationsEnabled:
        pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    localeCode: clearLocale ? null : localeCode ?? this.localeCode,
  );
}

abstract interface class SettingsRepository {
  Future<AppSettings> read();
  Future<void> saveVibration(bool enabled);
  Future<void> saveLocale(String localeCode);
  Future<void> saveOptions(AppSettings settings);
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(appDatabaseProvider)),
);

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);
  final AppDatabase _db;
  Future<void> _save(int id, String value) async {
    await _db
        .into(_db.userPreferences)
        .insertOnConflictUpdate(
          UserPreferencesCompanion.insert(
            id: Value(id),
            localeCode: value,
            updatedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<AppSettings> read() async {
    final rows = {
      for (final row in await _db.select(_db.userPreferences).get())
        row.id: row.localeCode,
    };
    Map<String, dynamic> options = {};
    try {
      if (rows[3] != null) {
        options = jsonDecode(rows[3]!) as Map<String, dynamic>;
      }
    } catch (_) {}
    final theme =
        ThemeMode.values
            .where((mode) => mode.name == options['theme'])
            .firstOrNull ??
        ThemeMode.dark;
    int validNumber(String key, int fallback, int max) {
      final value = options[key];
      return value is int && value >= 0 && value <= max ? value : fallback;
    }

    return AppSettings(
      localeCode: rows[1],
      vibrationEnabled: rows[2] != 'false',
      soundEnabled: options['sound'] == true,
      themeMode: theme,
      reminderEnabled: options['reminder'] == true,
      pushNotificationsEnabled: options['pushNotifications'] == true,
      reminderHour: validNumber('hour', 20, 23),
      reminderMinute: validNumber('minute', 0, 59),
    );
  }

  @override
  Future<void> saveVibration(bool enabled) => _save(2, '$enabled');
  @override
  Future<void> saveLocale(String localeCode) => _save(1, localeCode);
  @override
  Future<void> saveOptions(AppSettings settings) => _save(
    3,
    jsonEncode({
      'sound': settings.soundEnabled,
      'theme': settings.themeMode.name,
      'reminder': settings.reminderEnabled,
      'pushNotifications': settings.pushNotificationsEnabled,
      'hour': settings.reminderHour,
      'minute': settings.reminderMinute,
    }),
  );
}
