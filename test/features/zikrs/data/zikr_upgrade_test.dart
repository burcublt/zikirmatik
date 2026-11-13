import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/features/zikrs/data/drift_zikr_repository.dart';

void main() {
  test(
    'hazır zikrin düzenlemesi ve favorisi yeniden açılışta korunur',
    () async {
      final temp = Directory.systemTemp.createTempSync('zikr-favorite-');
      final file = File('${temp.path}/test.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      var repo = DriftZikrRepository(db);
      final initial = await repo.watchActive().first;
      expect(initial.length, 6);
      final zikr = initial.first.copyWith(
        title: 'Kişisel başlık',
        defaultTarget: 77,
        isFavorite: true,
      );
      await repo.save(zikr);
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      repo = DriftZikrRepository(db);
      final loaded = (await repo.watchActive().first).firstWhere(
        (z) => z.id == zikr.id,
      );
      expect(loaded.title, 'Kişisel başlık');
      expect(loaded.defaultTarget, 77);
      expect(loaded.isFavorite, isTrue);
      await db.close();
      temp.deleteSync(recursive: true);
    },
  );

  test('v2 veritabanındaki zikir v4 geçişinde veri kaybetmez', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (sqlite) {
          sqlite.execute('''CREATE TABLE zikrs (
        id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, arabic_text TEXT,
        description TEXT, default_target INTEGER NOT NULL DEFAULT 100,
        created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
        is_built_in INTEGER NOT NULL DEFAULT 0, is_archived INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0)''');
          sqlite.execute(
            "INSERT INTO zikrs (id,title,default_target,created_at,updated_at) VALUES ('old','Eski zikir',55,1,1)",
          );
          sqlite.execute(
            '''CREATE TABLE daily_activities (date INTEGER NOT NULL, zikr_id TEXT NOT NULL,
          increment_count INTEGER NOT NULL DEFAULT 0, updated_at INTEGER NOT NULL,
          PRIMARY KEY(date, zikr_id))''',
          );
          sqlite.execute(
            "INSERT INTO daily_activities (date,zikr_id,increment_count,updated_at) VALUES (1,'old',9,1)",
          );
          sqlite.execute('PRAGMA user_version = 2');
        },
      ),
    );
    final loaded = (await DriftZikrRepository(
      db,
    ).watchActive().first).firstWhere((z) => z.id == 'old');
    expect(loaded.title, 'Eski zikir');
    expect(loaded.defaultTarget, 55);
    expect(loaded.isFavorite, isFalse);
    final activity = await db.select(db.dailyActivities).getSingle();
    expect(activity.incrementCount, 9);
    expect(activity.activeMilliseconds, 0);
    await db.close();
  });
}
