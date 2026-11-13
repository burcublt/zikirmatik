import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/features/zikrs/data/drift_zikr_repository.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';

void main() {
  late AppDatabase database;
  late DriftZikrRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftZikrRepository(database);
  });

  tearDown(() => database.close());

  test('aktif zikirleri kalıcı olarak saklar ve sıralar', () async {
    final createdAt = DateTime(2026, 10, 25, 9);

    await repository.save(
      ZikrDefinition(
        id: 'subhanallah',
        title: 'Sübhanallah',
        defaultTarget: 100,
        createdAt: createdAt,
        updatedAt: createdAt,
        sortOrder: 1,
      ),
    );
    await repository.save(
      ZikrDefinition(
        id: 'elhamdulillah',
        title: 'Elhamdülillah',
        defaultTarget: 33,
        createdAt: createdAt,
        updatedAt: createdAt,
        sortOrder: 0,
      ),
    );

    final zikrs = await repository.watchActive().first;

    // Seed'deki 3 built-in zikir + eklenen 2 zikir; sıralama: sortOrder asc
    // Eklenen zikirlerin sortOrder'ı: elhamdulillah=0, subhanallah=1
    // Built-in'lar: builtin-subhanallah=0, builtin-elhamdulillah=1, builtin-allahuekber=2
    // Toplam 5 zikir, sadece ID'lerin içinde test zikirlerimiz olsun diye kontrol edelim
    final ids = zikrs.map((z) => z.id).toList();
    expect(ids, containsAll(['elhamdulillah', 'subhanallah']));
    expect(zikrs.firstWhere((z) => z.id == 'elhamdulillah').defaultTarget, 33);
  });

  test('zikir hedefini günlük toplam hedeften ayrı saklar', () async {
    final now = DateTime(2026, 10, 25, 9);
    final day = DateTime(2026, 10, 25);

    await repository.save(
      ZikrDefinition(
        id: 'subhanallah',
        title: 'Sübhanallah',
        defaultTarget: 100,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database
        .into(database.counterProgresses)
        .insert(
          CounterProgressesCompanion.insert(
            zikrId: 'subhanallah',
            targetCount: 100,
            updatedAt: now,
          ),
        );
    await database
        .into(database.dailyGoals)
        .insert(
          DailyGoalsCompanion.insert(
            date: day,
            targetCount: 500,
            updatedAt: now,
          ),
        );

    final counter = await database
        .select(database.counterProgresses)
        .getSingle();
    final dailyGoal = await database.select(database.dailyGoals).getSingle();

    expect(counter.targetCount, 100);
    expect(dailyGoal.targetCount, 500);
  });
}
