import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_definition.dart';
import 'package:zikirmatik/features/zikrs/domain/zikr_repository.dart';

final zikrRepositoryProvider = Provider<ZikrRepository>((ref) {
  return DriftZikrRepository(ref.watch(appDatabaseProvider));
});

class DriftZikrRepository implements ZikrRepository {
  DriftZikrRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> save(ZikrDefinition zikr) {
    return _database
        .into(_database.zikrs)
        .insertOnConflictUpdate(
          ZikrsCompanion.insert(
            id: zikr.id,
            title: zikr.title,
            arabicText: Value(zikr.arabicText),
            description: Value(zikr.description),
            defaultTarget: Value(zikr.defaultTarget),
            createdAt: zikr.createdAt,
            updatedAt: zikr.updatedAt,
            isBuiltIn: Value(zikr.isBuiltIn),
            isArchived: Value(zikr.isArchived),
            isFavorite: Value(zikr.isFavorite),
            sortOrder: Value(zikr.sortOrder),
          ),
        );
  }

  @override
  Future<void> archive(String id) {
    return (_database.update(
      _database.zikrs,
    )..where((row) => row.id.equals(id))).write(
      ZikrsCompanion(
        isArchived: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Stream<List<ZikrDefinition>> watchActive() {
    final query = _database.select(_database.zikrs)
      ..where((row) => row.isArchived.equals(false))
      ..orderBy([
        (row) => OrderingTerm.asc(row.sortOrder),
        (row) => OrderingTerm.asc(row.createdAt),
      ]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => ZikrDefinition(
              id: row.id,
              title: row.title,
              arabicText: row.arabicText,
              description: row.description,
              defaultTarget: row.defaultTarget,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
              isBuiltIn: row.isBuiltIn,
              isArchived: row.isArchived,
              isFavorite: row.isFavorite,
              sortOrder: row.sortOrder,
            ),
          )
          .toList(growable: false),
    );
  }
}
