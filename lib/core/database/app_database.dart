import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Zikrs extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get arabicText => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get defaultTarget => integer().withDefault(const Constant(100))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CounterProgresses extends Table {
  TextColumn get zikrId => text().references(Zikrs, #id)();
  IntColumn get currentCount => integer().withDefault(const Constant(0))();
  IntColumn get targetCount => integer()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get completionHandledAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {zikrId};
}

class DailyGoals extends Table {
  DateTimeColumn get date => dateTime()();
  IntColumn get targetCount => integer()();
  IntColumn get completedCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get completionHandledAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {date};
}

class DailyActivities extends Table {
  IntColumn get activeMilliseconds =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get date => dateTime()();
  TextColumn get zikrId => text().references(Zikrs, #id)();
  IntColumn get incrementCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {date, zikrId};
}

class CompletionEvents extends Table {
  TextColumn get eventKey => text()();
  TextColumn get goalType => text()();
  TextColumn get referenceId => text()();
  IntColumn get targetCount => integer()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {eventKey};
}

class UserPreferences extends Table {
  IntColumn get id => integer()();
  TextColumn get localeCode => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Zikrs,
    CounterProgresses,
    DailyGoals,
    DailyActivities,
    CompletionEvents,
    UserPreferences,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'zikirmatik'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedBuiltInZikrs();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(userPreferences);
      }
      if (from < 3) {
        await m.addColumn(zikrs, zikrs.isFavorite);
      }
      if (from < 4) {
        await m.addColumn(dailyActivities, dailyActivities.activeMilliseconds);
      }
    },
    beforeOpen: (details) async {
      // Yeni kurulum değilse de seed kontrol et (güncelleme sonrası vb.)
      if (!details.wasCreated) {
        await _seedBuiltInZikrs();
      }
    },
  );

  Future<void> _seedBuiltInZikrs() async {
    final now = DateTime.now();
    final builtIns = [
      ZikrsCompanion.insert(
        id: 'builtin-subhanallah',
        title: 'Sübhanallah',
        arabicText: const Value('سُبْحَانَ اللَّهِ'),
        description: const Value(
          'Allah\'ı tüm noksan sıfatlardan tenzih ederim.',
        ),
        defaultTarget: const Value(33),
        createdAt: now,
        updatedAt: now,
        isBuiltIn: const Value(true),
        isArchived: const Value(false),
        sortOrder: const Value(0),
      ),
      ZikrsCompanion.insert(
        id: 'builtin-elhamdulillah',
        title: 'Elhamdülillah',
        arabicText: const Value('الْحَمْدُ لِلَّهِ'),
        description: const Value('Hamd ve övgü Allah\'a mahsustur.'),
        defaultTarget: const Value(33),
        createdAt: now,
        updatedAt: now,
        isBuiltIn: const Value(true),
        isArchived: const Value(false),
        sortOrder: const Value(1),
      ),
      ZikrsCompanion.insert(
        id: 'builtin-allahuekber',
        title: 'Allahu Ekber',
        arabicText: const Value('اللَّهُ أَكْبَرُ'),
        description: const Value('Allah en büyüktür.'),
        defaultTarget: const Value(33),
        createdAt: now,
        updatedAt: now,
        isBuiltIn: const Value(true),
        isArchived: const Value(false),
        sortOrder: const Value(2),
      ),
      for (final entry in [
        ('builtin-lailaheillallah', 'Lâ ilâhe illallah', 33),
        ('builtin-estagfirullah', 'Estağfirullah', 100),
        ('builtin-salavat', 'Salavat', 100),
      ].indexed)
        ZikrsCompanion.insert(
          id: entry.$2.$1,
          title: entry.$2.$2,
          defaultTarget: Value(entry.$2.$3),
          createdAt: now,
          updatedAt: now,
          isBuiltIn: const Value(true),
          sortOrder: Value(3 + entry.$1),
        ),
    ];

    for (final zikr in builtIns) {
      await into(zikrs).insert(zikr, mode: InsertMode.insertOrIgnore);
    }
  }
}
