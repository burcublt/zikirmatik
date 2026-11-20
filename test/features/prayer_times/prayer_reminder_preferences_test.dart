import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/features/prayer_times/data/prayer_reminder_preferences.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_reminder_plan.dart';
import 'package:zikirmatik/features/prayer_times/domain/prayer_schedule.dart';

void main() {
  test(
    'vakit tercihleri kalıcıdır ve diğer bildirim ayarlarına dokunmaz',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await db
          .into(db.userPreferences)
          .insert(
            UserPreferencesCompanion.insert(
              id: const Value(3),
              localeCode: '{"reminder":true}',
              updatedAt: DateTime.now(),
            ),
          );
      final repo = PrayerReminderPreferencesRepository(db);
      final settings = await repo.read();
      expect(settings.length, 5);
      expect(settings.values.every((s) => !s.enabled), isTrue);
      settings[PrayerName.fajr] = const PrayerReminderPreference(
        enabled: true,
        minutesBefore: 15,
      );
      await repo.save(settings);
      final reloaded = await repo.read();
      expect(reloaded[PrayerName.fajr]!.enabled, isTrue);
      expect(reloaded[PrayerName.fajr]!.minutesBefore, 15);
      expect(reloaded.containsKey(PrayerName.sunrise), isFalse);
      final other = await (db.select(
        db.userPreferences,
      )..where((r) => r.id.equals(3))).getSingle();
      expect(other.localeCode, '{"reminder":true}');
    },
  );
  test('geçersiz ve bozuk kayıtlarda güvenli varsayılan kullanılır', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db
        .into(db.userPreferences)
        .insert(
          UserPreferencesCompanion.insert(
            id: const Value(7),
            localeCode: '{broken',
            updatedAt: DateTime.now(),
          ),
        );
    final settings = await PrayerReminderPreferencesRepository(db).read();
    expect(
      settings.values.every((s) => !s.enabled && s.minutesBefore == 0),
      isTrue,
    );
  });
}
