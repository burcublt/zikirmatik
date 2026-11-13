import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/core/localization/app_locales.dart';
import 'package:zikirmatik/core/localization/locale_controller.dart';
import 'package:zikirmatik/core/services/reminder_service.dart';
import 'package:zikirmatik/features/settings/data/settings_repository.dart';

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  Future<void> _pending = Future.value();
  bool _busy = false;
  @override
  Future<AppSettings> build() async {
    final settings = await ref.read(settingsRepositoryProvider).read();
    if (settings.reminderEnabled) {
      try {
        final allowed = await ref.read(reminderServiceProvider).apply(settings);
        if (!allowed) {
          final disabled = settings.copyWith(reminderEnabled: false);
          await ref.read(settingsRepositoryProvider).saveOptions(disabled);
          return disabled;
        }
      } catch (_) {}
    }
    return settings;
  }

  Future<void> _save(AppSettings next) async {
    final operation = _pending.then(
      (_) => ref.read(settingsRepositoryProvider).saveOptions(next),
    );
    _pending = operation.catchError((Object _) {});
    await operation;
    if (ref.mounted) state = AsyncData(next);
  }

  Future<void> setVibration({required bool enabled}) async {
    await ref.read(settingsRepositoryProvider).saveVibration(enabled);
    state = AsyncData(
      (state.asData?.value ?? const AppSettings()).copyWith(
        vibrationEnabled: enabled,
      ),
    );
  }

  Future<void> setSound(bool enabled) =>
      _save(state.requireValue.copyWith(soundEnabled: enabled));
  Future<void> setTheme(ThemeMode mode) =>
      _save(state.requireValue.copyWith(themeMode: mode));
  Future<bool> setReminder({bool? enabled, int? hour, int? minute}) async {
    if (_busy) return false;
    _busy = true;
    final previous = state.requireValue;
    final next = previous.copyWith(
      reminderEnabled: enabled,
      reminderHour: hour,
      reminderMinute: minute,
    );
    try {
      final allowed = await ref
          .read(reminderServiceProvider)
          .apply(next, requestPermission: next.reminderEnabled);
      if (next.reminderEnabled && !allowed) return false;
      try {
        await _save(next);
      } catch (_) {
        await ref.read(reminderServiceProvider).apply(previous);
        rethrow;
      }
      return true;
    } finally {
      _busy = false;
    }
  }

  bool get vibrationEnabled => state.asData?.value.vibrationEnabled ?? true;
  Future<void> setLocale(Locale locale) async {
    await ref.read(localeControllerProvider.notifier).select(locale);
    await ref.read(settingsRepositoryProvider).saveLocale(locale.languageCode);
    final next = state.requireValue.copyWith(localeCode: locale.languageCode);
    state = AsyncData(next);
    if (next.reminderEnabled) {
      await ref.read(reminderServiceProvider).apply(next);
    }
  }

  Locale get currentLocale =>
      AppLocales.fromLanguageCode(state.asData?.value.localeCode);
}
