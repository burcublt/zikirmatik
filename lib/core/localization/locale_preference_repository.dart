import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';

abstract interface class LocalePreferenceRepository {
  Future<String?> readLocaleCode();

  Future<void> writeLocaleCode(String localeCode);
}

final localePreferenceRepositoryProvider = Provider<LocalePreferenceRepository>(
  (ref) {
    return DriftLocalePreferenceRepository(ref.watch(appDatabaseProvider));
  },
);

class DriftLocalePreferenceRepository implements LocalePreferenceRepository {
  DriftLocalePreferenceRepository(this._database);

  static const _preferenceId = 1;

  final AppDatabase _database;

  @override
  Future<String?> readLocaleCode() async {
    final preference = await (_database.select(
      _database.userPreferences,
    )..where((row) => row.id.equals(_preferenceId))).getSingleOrNull();

    return preference?.localeCode;
  }

  @override
  Future<void> writeLocaleCode(String localeCode) {
    return _database
        .into(_database.userPreferences)
        .insertOnConflictUpdate(
          UserPreferencesCompanion.insert(
            id: const Value(_preferenceId),
            localeCode: localeCode,
            updatedAt: DateTime.now(),
          ),
        );
  }
}
