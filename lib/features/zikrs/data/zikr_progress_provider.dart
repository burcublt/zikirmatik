import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zikirmatik/core/database/app_database.dart';
import 'package:zikirmatik/core/database/database_providers.dart';

/// A single live query keeps all list rows in sync with the saved counters.
final zikrProgressProvider =
    StreamProvider.autoDispose<Map<String, CounterProgressesData>>((ref) {
      final db = ref.watch(appDatabaseProvider);
      return db
          .select(db.counterProgresses)
          .watch()
          .map((rows) => {for (final row in rows) row.zikrId: row});
    });
