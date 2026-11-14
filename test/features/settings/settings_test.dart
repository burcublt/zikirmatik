import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/ads/admob.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/services/push_notification_service.dart';
import 'package:zikirmatik/core/services/reminder_service.dart';
import 'package:zikirmatik/features/settings/data/settings_repository.dart';
import 'package:zikirmatik/features/settings/application/settings_notifier.dart';
import 'package:zikirmatik/features/settings/presentation/settings_page.dart';
import 'package:zikirmatik/l10n/app_localizations.dart';

class _NoAds extends AdsController {
  @override
  Future<AdsState> build() async => const AdsState();
}

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

class _PushNotifications implements PushNotificationService {
  bool allowed = false;
  bool enabled = false;

  @override
  Future<bool> enable() async {
    enabled = allowed;
    return allowed;
  }

  @override
  Future<void> restore() async {
    enabled = true;
  }

  @override
  Future<void> disable() async {
    enabled = false;
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
          pushNotificationsEnabled: true,
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
      expect(loaded.pushNotificationsEnabled, true);
      expect(loaded.reminderHour, 8);
      expect(loaded.reminderMinute, 45);
      await db.close();
    },
  );
  testWidgets(
    'iOS hatırlatma saati tekerlekli, Android Material seçici kullanır',
    (tester) async {
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DriftSettingsRepository(db);
      final reminder = _Reminder()..allowed = true;

      for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(repo),
              reminderServiceProvider.overrideWithValue(reminder),
              adsControllerProvider.overrideWith(_NoAds.new),
            ],
            child: MaterialApp(
              locale: const Locale('tr'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: SettingsPage(selectedNavIndex: 0, onNavTap: (_) {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final reminderTime = find.text('Hatırlatma Saati');
        await tester.ensureVisible(reminderTime);
        await tester.tap(reminderTime);
        await tester.pumpAndSettle();

        if (platform == TargetPlatform.iOS) {
          expect(find.byType(CupertinoDatePicker), findsOneWidget);
        } else {
          expect(find.byType(TimePickerDialog), findsOneWidget);
        }
        final picker = platform == TargetPlatform.iOS
            ? find.byType(CupertinoDatePicker)
            : find.byType(TimePickerDialog);
        Navigator.of(tester.element(picker)).pop();
        await tester.pumpAndSettle();
      }
      debugDefaultTargetPlatformOverride = null;
      await tester.pumpWidget(const SizedBox.shrink());
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

  test(
    'duyuru izni reddi kaydedilmez; onay aboneliği ve tercihi saklar',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftSettingsRepository(db);
      final push = _PushNotifications();
      final c = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          pushNotificationServiceProvider.overrideWithValue(push),
        ],
      );
      await c.read(settingsNotifierProvider.future);
      final notifier = c.read(settingsNotifierProvider.notifier);
      expect(await notifier.setPushNotifications(true), false);
      expect((await repo.read()).pushNotificationsEnabled, false);

      push.allowed = true;
      expect(await notifier.setPushNotifications(true), true);
      expect((await repo.read()).pushNotificationsEnabled, true);
      expect(push.enabled, true);

      expect(await notifier.setPushNotifications(false), true);
      expect((await repo.read()).pushNotificationsEnabled, false);
      expect(push.enabled, false);
      c.dispose();
      await db.close();
    },
  );

  test(
    'kayıtlı duyuru tercihi başlangıçta topic aboneliğini yeniler',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = DriftSettingsRepository(db);
      await repo.saveOptions(const AppSettings(pushNotificationsEnabled: true));
      final push = _PushNotifications();
      final c = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          pushNotificationServiceProvider.overrideWithValue(push),
        ],
      );

      final settings = await c.read(settingsNotifierProvider.future);
      expect(settings.pushNotificationsEnabled, true);
      expect(push.enabled, true);
      c.dispose();
      await db.close();
    },
  );
}
