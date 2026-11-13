import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/services/reminder_service.dart';
import 'package:zikirmatik/features/settings/data/settings_repository.dart';
import 'package:zikirmatik/features/settings/application/settings_notifier.dart';

class _Reminder implements ReminderService {
  bool allowed = false;
  AppSettings? applied;
  @override
  Future<bool> apply(
    AppSettings settings, {
    bool requestPermission = false,
  }) async {
    applied = settings;
    return !settings.reminderEnabled || allowed;
  }
}

void main() {
  test(
    'ses, tema ve hatırlatma saati dil ve titreşimi ezmeden saklanır',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftSettingsRepository(db);
      await repo.saveLocale('ar');
      await repo.saveVibration(false);
      await repo.saveOptions(
        const AppSettings(
          soundEnabled: true,
          themeMode: ThemeMode.light,
          reminderEnabled: true,
          reminderHour: 8,
          reminderMinute: 45,
        ),
      );
      final loaded = await repo.read();
      expect(loaded.localeCode, 'ar');
      expect(loaded.vibrationEnabled, false);
      expect(loaded.soundEnabled, true);
      expect(loaded.themeMode, ThemeMode.light);
      expect(loaded.reminderEnabled, true);
      expect(loaded.reminderHour, 8);
      expect(loaded.reminderMinute, 45);
      await db.close();
    },
  );
  test('izin reddedilirse hatırlatma tercihi kapalı kalır', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DriftSettingsRepository(db);
    final reminder = _Reminder();
    final c = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        reminderServiceProvider.overrideWithValue(reminder),
      ],
    );
    await c.read(settingsNotifierProvider.future);
    final notifier = c.read(settingsNotifierProvider.notifier);
    expect(await notifier.setReminder(enabled: true), false);
    expect((await repo.read()).reminderEnabled, false);
    reminder.allowed = true;
    expect(
      await notifier.setReminder(enabled: true, hour: 7, minute: 15),
      true,
    );
    expect((await repo.read()).reminderEnabled, true);
    expect(reminder.applied!.reminderHour, 7);
    expect(await notifier.setReminder(enabled: false), true);
    expect((await repo.read()).reminderEnabled, false);
    c.dispose();
    await db.close();
  });
}
