import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_transaction_runner.dart';

void main() {
  test('başarısız işlemde veritabanı değişikliklerini geri alır', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final runner = DriftDatabaseTransactionRunner(database);
    final now = DateTime(2026, 10, 25, 9);

    await expectLater(
      () => runner.run<void>(() async {
        await database
            .into(database.zikrs)
            .insert(
              ZikrsCompanion.insert(
                id: 'subhanallah',
                title: 'Sübhanallah',
                createdAt: now,
                updatedAt: now,
              ),
            );
        throw StateError('işlem tamamlanamadı');
      }),
      throwsA(isA<StateError>()),
    );

    // Seed olan 3 built-in zikir dışında başka kayıt yok
    final zikrs = await database.select(database.zikrs).get();
    final nonBuiltIn = zikrs.where((z) => !z.isBuiltIn).toList();
    expect(nonBuiltIn, isEmpty);
    await database.close();
  });
}
