import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';

abstract interface class DatabaseTransactionRunner {
  Future<T> run<T>(Future<T> Function() action);
}

class DriftDatabaseTransactionRunner implements DatabaseTransactionRunner {
  const DriftDatabaseTransactionRunner(this._database);

  final AppDatabase _database;

  @override
  Future<T> run<T>(Future<T> Function() action) {
    return _database.transaction(action);
  }
}

final databaseTransactionRunnerProvider = Provider<DatabaseTransactionRunner>(
  (ref) => DriftDatabaseTransactionRunner(ref.watch(appDatabaseProvider)),
);
