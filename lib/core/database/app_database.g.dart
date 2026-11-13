// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ZikrsTable extends Zikrs with TableInfo<$ZikrsTable, Zikr> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZikrsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arabicTextMeta = const VerificationMeta(
    'arabicText',
  );
  @override
  late final GeneratedColumn<String> arabicText = GeneratedColumn<String>(
    'arabic_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultTargetMeta = const VerificationMeta(
    'defaultTarget',
  );
  @override
  late final GeneratedColumn<int> defaultTarget = GeneratedColumn<int>(
    'default_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    arabicText,
    description,
    defaultTarget,
    createdAt,
    updatedAt,
    isBuiltIn,
    isFavorite,
    isArchived,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zikrs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Zikr> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('arabic_text')) {
      context.handle(
        _arabicTextMeta,
        arabicText.isAcceptableOrUnknown(data['arabic_text']!, _arabicTextMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('default_target')) {
      context.handle(
        _defaultTargetMeta,
        defaultTarget.isAcceptableOrUnknown(
          data['default_target']!,
          _defaultTargetMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Zikr map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Zikr(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      arabicText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic_text'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      defaultTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_target'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ZikrsTable createAlias(String alias) {
    return $ZikrsTable(attachedDatabase, alias);
  }
}

class Zikr extends DataClass implements Insertable<Zikr> {
  final String id;
  final String title;
  final String? arabicText;
  final String? description;
  final int defaultTarget;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBuiltIn;
  final bool isFavorite;
  final bool isArchived;
  final int sortOrder;
  const Zikr({
    required this.id,
    required this.title,
    this.arabicText,
    this.description,
    required this.defaultTarget,
    required this.createdAt,
    required this.updatedAt,
    required this.isBuiltIn,
    required this.isFavorite,
    required this.isArchived,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || arabicText != null) {
      map['arabic_text'] = Variable<String>(arabicText);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['default_target'] = Variable<int>(defaultTarget);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_archived'] = Variable<bool>(isArchived);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ZikrsCompanion toCompanion(bool nullToAbsent) {
    return ZikrsCompanion(
      id: Value(id),
      title: Value(title),
      arabicText: arabicText == null && nullToAbsent
          ? const Value.absent()
          : Value(arabicText),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      defaultTarget: Value(defaultTarget),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isBuiltIn: Value(isBuiltIn),
      isFavorite: Value(isFavorite),
      isArchived: Value(isArchived),
      sortOrder: Value(sortOrder),
    );
  }

  factory Zikr.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Zikr(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      arabicText: serializer.fromJson<String?>(json['arabicText']),
      description: serializer.fromJson<String?>(json['description']),
      defaultTarget: serializer.fromJson<int>(json['defaultTarget']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'arabicText': serializer.toJson<String?>(arabicText),
      'description': serializer.toJson<String?>(description),
      'defaultTarget': serializer.toJson<int>(defaultTarget),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Zikr copyWith({
    String? id,
    String? title,
    Value<String?> arabicText = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? defaultTarget,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBuiltIn,
    bool? isFavorite,
    bool? isArchived,
    int? sortOrder,
  }) => Zikr(
    id: id ?? this.id,
    title: title ?? this.title,
    arabicText: arabicText.present ? arabicText.value : this.arabicText,
    description: description.present ? description.value : this.description,
    defaultTarget: defaultTarget ?? this.defaultTarget,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    isFavorite: isFavorite ?? this.isFavorite,
    isArchived: isArchived ?? this.isArchived,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Zikr copyWithCompanion(ZikrsCompanion data) {
    return Zikr(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      arabicText: data.arabicText.present
          ? data.arabicText.value
          : this.arabicText,
      description: data.description.present
          ? data.description.value
          : this.description,
      defaultTarget: data.defaultTarget.present
          ? data.defaultTarget.value
          : this.defaultTarget,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Zikr(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('arabicText: $arabicText, ')
          ..write('description: $description, ')
          ..write('defaultTarget: $defaultTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    arabicText,
    description,
    defaultTarget,
    createdAt,
    updatedAt,
    isBuiltIn,
    isFavorite,
    isArchived,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Zikr &&
          other.id == this.id &&
          other.title == this.title &&
          other.arabicText == this.arabicText &&
          other.description == this.description &&
          other.defaultTarget == this.defaultTarget &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isBuiltIn == this.isBuiltIn &&
          other.isFavorite == this.isFavorite &&
          other.isArchived == this.isArchived &&
          other.sortOrder == this.sortOrder);
}

class ZikrsCompanion extends UpdateCompanion<Zikr> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> arabicText;
  final Value<String?> description;
  final Value<int> defaultTarget;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isBuiltIn;
  final Value<bool> isFavorite;
  final Value<bool> isArchived;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ZikrsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.arabicText = const Value.absent(),
    this.description = const Value.absent(),
    this.defaultTarget = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZikrsCompanion.insert({
    required String id,
    required String title,
    this.arabicText = const Value.absent(),
    this.description = const Value.absent(),
    this.defaultTarget = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.isBuiltIn = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Zikr> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? arabicText,
    Expression<String>? description,
    Expression<int>? defaultTarget,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isBuiltIn,
    Expression<bool>? isFavorite,
    Expression<bool>? isArchived,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (arabicText != null) 'arabic_text': arabicText,
      if (description != null) 'description': description,
      if (defaultTarget != null) 'default_target': defaultTarget,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isArchived != null) 'is_archived': isArchived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ZikrsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? arabicText,
    Value<String?>? description,
    Value<int>? defaultTarget,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isBuiltIn,
    Value<bool>? isFavorite,
    Value<bool>? isArchived,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ZikrsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      arabicText: arabicText ?? this.arabicText,
      description: description ?? this.description,
      defaultTarget: defaultTarget ?? this.defaultTarget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (arabicText.present) {
      map['arabic_text'] = Variable<String>(arabicText.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (defaultTarget.present) {
      map['default_target'] = Variable<int>(defaultTarget.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZikrsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('arabicText: $arabicText, ')
          ..write('description: $description, ')
          ..write('defaultTarget: $defaultTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CounterProgressesTable extends CounterProgresses
    with TableInfo<$CounterProgressesTable, CounterProgressesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CounterProgressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _zikrIdMeta = const VerificationMeta('zikrId');
  @override
  late final GeneratedColumn<String> zikrId = GeneratedColumn<String>(
    'zikr_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES zikrs (id)',
    ),
  );
  static const VerificationMeta _currentCountMeta = const VerificationMeta(
    'currentCount',
  );
  @override
  late final GeneratedColumn<int> currentCount = GeneratedColumn<int>(
    'current_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetCountMeta = const VerificationMeta(
    'targetCount',
  );
  @override
  late final GeneratedColumn<int> targetCount = GeneratedColumn<int>(
    'target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionHandledAtMeta =
      const VerificationMeta('completionHandledAt');
  @override
  late final GeneratedColumn<DateTime> completionHandledAt =
      GeneratedColumn<DateTime>(
        'completion_handled_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    zikrId,
    currentCount,
    targetCount,
    completedAt,
    completionHandledAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counter_progresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CounterProgressesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('zikr_id')) {
      context.handle(
        _zikrIdMeta,
        zikrId.isAcceptableOrUnknown(data['zikr_id']!, _zikrIdMeta),
      );
    } else if (isInserting) {
      context.missing(_zikrIdMeta);
    }
    if (data.containsKey('current_count')) {
      context.handle(
        _currentCountMeta,
        currentCount.isAcceptableOrUnknown(
          data['current_count']!,
          _currentCountMeta,
        ),
      );
    }
    if (data.containsKey('target_count')) {
      context.handle(
        _targetCountMeta,
        targetCount.isAcceptableOrUnknown(
          data['target_count']!,
          _targetCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCountMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('completion_handled_at')) {
      context.handle(
        _completionHandledAtMeta,
        completionHandledAt.isAcceptableOrUnknown(
          data['completion_handled_at']!,
          _completionHandledAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {zikrId};
  @override
  CounterProgressesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CounterProgressesData(
      zikrId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zikr_id'],
      )!,
      currentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_count'],
      )!,
      targetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_count'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      completionHandledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completion_handled_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CounterProgressesTable createAlias(String alias) {
    return $CounterProgressesTable(attachedDatabase, alias);
  }
}

class CounterProgressesData extends DataClass
    implements Insertable<CounterProgressesData> {
  final String zikrId;
  final int currentCount;
  final int targetCount;
  final DateTime? completedAt;
  final DateTime? completionHandledAt;
  final DateTime updatedAt;
  const CounterProgressesData({
    required this.zikrId,
    required this.currentCount,
    required this.targetCount,
    this.completedAt,
    this.completionHandledAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['zikr_id'] = Variable<String>(zikrId);
    map['current_count'] = Variable<int>(currentCount);
    map['target_count'] = Variable<int>(targetCount);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || completionHandledAt != null) {
      map['completion_handled_at'] = Variable<DateTime>(completionHandledAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CounterProgressesCompanion toCompanion(bool nullToAbsent) {
    return CounterProgressesCompanion(
      zikrId: Value(zikrId),
      currentCount: Value(currentCount),
      targetCount: Value(targetCount),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      completionHandledAt: completionHandledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completionHandledAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CounterProgressesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CounterProgressesData(
      zikrId: serializer.fromJson<String>(json['zikrId']),
      currentCount: serializer.fromJson<int>(json['currentCount']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      completionHandledAt: serializer.fromJson<DateTime?>(
        json['completionHandledAt'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'zikrId': serializer.toJson<String>(zikrId),
      'currentCount': serializer.toJson<int>(currentCount),
      'targetCount': serializer.toJson<int>(targetCount),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'completionHandledAt': serializer.toJson<DateTime?>(completionHandledAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CounterProgressesData copyWith({
    String? zikrId,
    int? currentCount,
    int? targetCount,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> completionHandledAt = const Value.absent(),
    DateTime? updatedAt,
  }) => CounterProgressesData(
    zikrId: zikrId ?? this.zikrId,
    currentCount: currentCount ?? this.currentCount,
    targetCount: targetCount ?? this.targetCount,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    completionHandledAt: completionHandledAt.present
        ? completionHandledAt.value
        : this.completionHandledAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CounterProgressesData copyWithCompanion(CounterProgressesCompanion data) {
    return CounterProgressesData(
      zikrId: data.zikrId.present ? data.zikrId.value : this.zikrId,
      currentCount: data.currentCount.present
          ? data.currentCount.value
          : this.currentCount,
      targetCount: data.targetCount.present
          ? data.targetCount.value
          : this.targetCount,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      completionHandledAt: data.completionHandledAt.present
          ? data.completionHandledAt.value
          : this.completionHandledAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CounterProgressesData(')
          ..write('zikrId: $zikrId, ')
          ..write('currentCount: $currentCount, ')
          ..write('targetCount: $targetCount, ')
          ..write('completedAt: $completedAt, ')
          ..write('completionHandledAt: $completionHandledAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    zikrId,
    currentCount,
    targetCount,
    completedAt,
    completionHandledAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CounterProgressesData &&
          other.zikrId == this.zikrId &&
          other.currentCount == this.currentCount &&
          other.targetCount == this.targetCount &&
          other.completedAt == this.completedAt &&
          other.completionHandledAt == this.completionHandledAt &&
          other.updatedAt == this.updatedAt);
}

class CounterProgressesCompanion
    extends UpdateCompanion<CounterProgressesData> {
  final Value<String> zikrId;
  final Value<int> currentCount;
  final Value<int> targetCount;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> completionHandledAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CounterProgressesCompanion({
    this.zikrId = const Value.absent(),
    this.currentCount = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completionHandledAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CounterProgressesCompanion.insert({
    required String zikrId,
    this.currentCount = const Value.absent(),
    required int targetCount,
    this.completedAt = const Value.absent(),
    this.completionHandledAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : zikrId = Value(zikrId),
       targetCount = Value(targetCount),
       updatedAt = Value(updatedAt);
  static Insertable<CounterProgressesData> custom({
    Expression<String>? zikrId,
    Expression<int>? currentCount,
    Expression<int>? targetCount,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? completionHandledAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (zikrId != null) 'zikr_id': zikrId,
      if (currentCount != null) 'current_count': currentCount,
      if (targetCount != null) 'target_count': targetCount,
      if (completedAt != null) 'completed_at': completedAt,
      if (completionHandledAt != null)
        'completion_handled_at': completionHandledAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CounterProgressesCompanion copyWith({
    Value<String>? zikrId,
    Value<int>? currentCount,
    Value<int>? targetCount,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? completionHandledAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CounterProgressesCompanion(
      zikrId: zikrId ?? this.zikrId,
      currentCount: currentCount ?? this.currentCount,
      targetCount: targetCount ?? this.targetCount,
      completedAt: completedAt ?? this.completedAt,
      completionHandledAt: completionHandledAt ?? this.completionHandledAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (zikrId.present) {
      map['zikr_id'] = Variable<String>(zikrId.value);
    }
    if (currentCount.present) {
      map['current_count'] = Variable<int>(currentCount.value);
    }
    if (targetCount.present) {
      map['target_count'] = Variable<int>(targetCount.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (completionHandledAt.present) {
      map['completion_handled_at'] = Variable<DateTime>(
        completionHandledAt.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CounterProgressesCompanion(')
          ..write('zikrId: $zikrId, ')
          ..write('currentCount: $currentCount, ')
          ..write('targetCount: $targetCount, ')
          ..write('completedAt: $completedAt, ')
          ..write('completionHandledAt: $completionHandledAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyGoalsTable extends DailyGoals
    with TableInfo<$DailyGoalsTable, DailyGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCountMeta = const VerificationMeta(
    'targetCount',
  );
  @override
  late final GeneratedColumn<int> targetCount = GeneratedColumn<int>(
    'target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedCountMeta = const VerificationMeta(
    'completedCount',
  );
  @override
  late final GeneratedColumn<int> completedCount = GeneratedColumn<int>(
    'completed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionHandledAtMeta =
      const VerificationMeta('completionHandledAt');
  @override
  late final GeneratedColumn<DateTime> completionHandledAt =
      GeneratedColumn<DateTime>(
        'completion_handled_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    targetCount,
    completedCount,
    completedAt,
    completionHandledAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('target_count')) {
      context.handle(
        _targetCountMeta,
        targetCount.isAcceptableOrUnknown(
          data['target_count']!,
          _targetCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCountMeta);
    }
    if (data.containsKey('completed_count')) {
      context.handle(
        _completedCountMeta,
        completedCount.isAcceptableOrUnknown(
          data['completed_count']!,
          _completedCountMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('completion_handled_at')) {
      context.handle(
        _completionHandledAtMeta,
        completionHandledAt.isAcceptableOrUnknown(
          data['completion_handled_at']!,
          _completionHandledAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyGoal(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      targetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_count'],
      )!,
      completedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_count'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      completionHandledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completion_handled_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyGoalsTable createAlias(String alias) {
    return $DailyGoalsTable(attachedDatabase, alias);
  }
}

class DailyGoal extends DataClass implements Insertable<DailyGoal> {
  final DateTime date;
  final int targetCount;
  final int completedCount;
  final DateTime? completedAt;
  final DateTime? completionHandledAt;
  final DateTime updatedAt;
  const DailyGoal({
    required this.date,
    required this.targetCount,
    required this.completedCount,
    this.completedAt,
    this.completionHandledAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['target_count'] = Variable<int>(targetCount);
    map['completed_count'] = Variable<int>(completedCount);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || completionHandledAt != null) {
      map['completion_handled_at'] = Variable<DateTime>(completionHandledAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyGoalsCompanion toCompanion(bool nullToAbsent) {
    return DailyGoalsCompanion(
      date: Value(date),
      targetCount: Value(targetCount),
      completedCount: Value(completedCount),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      completionHandledAt: completionHandledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completionHandledAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyGoal(
      date: serializer.fromJson<DateTime>(json['date']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      completedCount: serializer.fromJson<int>(json['completedCount']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      completionHandledAt: serializer.fromJson<DateTime?>(
        json['completionHandledAt'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'targetCount': serializer.toJson<int>(targetCount),
      'completedCount': serializer.toJson<int>(completedCount),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'completionHandledAt': serializer.toJson<DateTime?>(completionHandledAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyGoal copyWith({
    DateTime? date,
    int? targetCount,
    int? completedCount,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> completionHandledAt = const Value.absent(),
    DateTime? updatedAt,
  }) => DailyGoal(
    date: date ?? this.date,
    targetCount: targetCount ?? this.targetCount,
    completedCount: completedCount ?? this.completedCount,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    completionHandledAt: completionHandledAt.present
        ? completionHandledAt.value
        : this.completionHandledAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyGoal copyWithCompanion(DailyGoalsCompanion data) {
    return DailyGoal(
      date: data.date.present ? data.date.value : this.date,
      targetCount: data.targetCount.present
          ? data.targetCount.value
          : this.targetCount,
      completedCount: data.completedCount.present
          ? data.completedCount.value
          : this.completedCount,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      completionHandledAt: data.completionHandledAt.present
          ? data.completionHandledAt.value
          : this.completionHandledAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoal(')
          ..write('date: $date, ')
          ..write('targetCount: $targetCount, ')
          ..write('completedCount: $completedCount, ')
          ..write('completedAt: $completedAt, ')
          ..write('completionHandledAt: $completionHandledAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    targetCount,
    completedCount,
    completedAt,
    completionHandledAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyGoal &&
          other.date == this.date &&
          other.targetCount == this.targetCount &&
          other.completedCount == this.completedCount &&
          other.completedAt == this.completedAt &&
          other.completionHandledAt == this.completionHandledAt &&
          other.updatedAt == this.updatedAt);
}

class DailyGoalsCompanion extends UpdateCompanion<DailyGoal> {
  final Value<DateTime> date;
  final Value<int> targetCount;
  final Value<int> completedCount;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> completionHandledAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DailyGoalsCompanion({
    this.date = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.completedCount = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completionHandledAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyGoalsCompanion.insert({
    required DateTime date,
    required int targetCount,
    this.completedCount = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.completionHandledAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       targetCount = Value(targetCount),
       updatedAt = Value(updatedAt);
  static Insertable<DailyGoal> custom({
    Expression<DateTime>? date,
    Expression<int>? targetCount,
    Expression<int>? completedCount,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? completionHandledAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (targetCount != null) 'target_count': targetCount,
      if (completedCount != null) 'completed_count': completedCount,
      if (completedAt != null) 'completed_at': completedAt,
      if (completionHandledAt != null)
        'completion_handled_at': completionHandledAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyGoalsCompanion copyWith({
    Value<DateTime>? date,
    Value<int>? targetCount,
    Value<int>? completedCount,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? completionHandledAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DailyGoalsCompanion(
      date: date ?? this.date,
      targetCount: targetCount ?? this.targetCount,
      completedCount: completedCount ?? this.completedCount,
      completedAt: completedAt ?? this.completedAt,
      completionHandledAt: completionHandledAt ?? this.completionHandledAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (targetCount.present) {
      map['target_count'] = Variable<int>(targetCount.value);
    }
    if (completedCount.present) {
      map['completed_count'] = Variable<int>(completedCount.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (completionHandledAt.present) {
      map['completion_handled_at'] = Variable<DateTime>(
        completionHandledAt.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoalsCompanion(')
          ..write('date: $date, ')
          ..write('targetCount: $targetCount, ')
          ..write('completedCount: $completedCount, ')
          ..write('completedAt: $completedAt, ')
          ..write('completionHandledAt: $completionHandledAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyActivitiesTable extends DailyActivities
    with TableInfo<$DailyActivitiesTable, DailyActivity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _activeMillisecondsMeta =
      const VerificationMeta('activeMilliseconds');
  @override
  late final GeneratedColumn<int> activeMilliseconds = GeneratedColumn<int>(
    'active_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zikrIdMeta = const VerificationMeta('zikrId');
  @override
  late final GeneratedColumn<String> zikrId = GeneratedColumn<String>(
    'zikr_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES zikrs (id)',
    ),
  );
  static const VerificationMeta _incrementCountMeta = const VerificationMeta(
    'incrementCount',
  );
  @override
  late final GeneratedColumn<int> incrementCount = GeneratedColumn<int>(
    'increment_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    activeMilliseconds,
    date,
    zikrId,
    incrementCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyActivity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('active_milliseconds')) {
      context.handle(
        _activeMillisecondsMeta,
        activeMilliseconds.isAcceptableOrUnknown(
          data['active_milliseconds']!,
          _activeMillisecondsMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('zikr_id')) {
      context.handle(
        _zikrIdMeta,
        zikrId.isAcceptableOrUnknown(data['zikr_id']!, _zikrIdMeta),
      );
    } else if (isInserting) {
      context.missing(_zikrIdMeta);
    }
    if (data.containsKey('increment_count')) {
      context.handle(
        _incrementCountMeta,
        incrementCount.isAcceptableOrUnknown(
          data['increment_count']!,
          _incrementCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date, zikrId};
  @override
  DailyActivity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyActivity(
      activeMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_milliseconds'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      zikrId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zikr_id'],
      )!,
      incrementCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}increment_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailyActivitiesTable createAlias(String alias) {
    return $DailyActivitiesTable(attachedDatabase, alias);
  }
}

class DailyActivity extends DataClass implements Insertable<DailyActivity> {
  final int activeMilliseconds;
  final DateTime date;
  final String zikrId;
  final int incrementCount;
  final DateTime updatedAt;
  const DailyActivity({
    required this.activeMilliseconds,
    required this.date,
    required this.zikrId,
    required this.incrementCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['active_milliseconds'] = Variable<int>(activeMilliseconds);
    map['date'] = Variable<DateTime>(date);
    map['zikr_id'] = Variable<String>(zikrId);
    map['increment_count'] = Variable<int>(incrementCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyActivitiesCompanion toCompanion(bool nullToAbsent) {
    return DailyActivitiesCompanion(
      activeMilliseconds: Value(activeMilliseconds),
      date: Value(date),
      zikrId: Value(zikrId),
      incrementCount: Value(incrementCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyActivity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyActivity(
      activeMilliseconds: serializer.fromJson<int>(json['activeMilliseconds']),
      date: serializer.fromJson<DateTime>(json['date']),
      zikrId: serializer.fromJson<String>(json['zikrId']),
      incrementCount: serializer.fromJson<int>(json['incrementCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'activeMilliseconds': serializer.toJson<int>(activeMilliseconds),
      'date': serializer.toJson<DateTime>(date),
      'zikrId': serializer.toJson<String>(zikrId),
      'incrementCount': serializer.toJson<int>(incrementCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyActivity copyWith({
    int? activeMilliseconds,
    DateTime? date,
    String? zikrId,
    int? incrementCount,
    DateTime? updatedAt,
  }) => DailyActivity(
    activeMilliseconds: activeMilliseconds ?? this.activeMilliseconds,
    date: date ?? this.date,
    zikrId: zikrId ?? this.zikrId,
    incrementCount: incrementCount ?? this.incrementCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyActivity copyWithCompanion(DailyActivitiesCompanion data) {
    return DailyActivity(
      activeMilliseconds: data.activeMilliseconds.present
          ? data.activeMilliseconds.value
          : this.activeMilliseconds,
      date: data.date.present ? data.date.value : this.date,
      zikrId: data.zikrId.present ? data.zikrId.value : this.zikrId,
      incrementCount: data.incrementCount.present
          ? data.incrementCount.value
          : this.incrementCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyActivity(')
          ..write('activeMilliseconds: $activeMilliseconds, ')
          ..write('date: $date, ')
          ..write('zikrId: $zikrId, ')
          ..write('incrementCount: $incrementCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(activeMilliseconds, date, zikrId, incrementCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyActivity &&
          other.activeMilliseconds == this.activeMilliseconds &&
          other.date == this.date &&
          other.zikrId == this.zikrId &&
          other.incrementCount == this.incrementCount &&
          other.updatedAt == this.updatedAt);
}

class DailyActivitiesCompanion extends UpdateCompanion<DailyActivity> {
  final Value<int> activeMilliseconds;
  final Value<DateTime> date;
  final Value<String> zikrId;
  final Value<int> incrementCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DailyActivitiesCompanion({
    this.activeMilliseconds = const Value.absent(),
    this.date = const Value.absent(),
    this.zikrId = const Value.absent(),
    this.incrementCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyActivitiesCompanion.insert({
    this.activeMilliseconds = const Value.absent(),
    required DateTime date,
    required String zikrId,
    this.incrementCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       zikrId = Value(zikrId),
       updatedAt = Value(updatedAt);
  static Insertable<DailyActivity> custom({
    Expression<int>? activeMilliseconds,
    Expression<DateTime>? date,
    Expression<String>? zikrId,
    Expression<int>? incrementCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (activeMilliseconds != null) 'active_milliseconds': activeMilliseconds,
      if (date != null) 'date': date,
      if (zikrId != null) 'zikr_id': zikrId,
      if (incrementCount != null) 'increment_count': incrementCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyActivitiesCompanion copyWith({
    Value<int>? activeMilliseconds,
    Value<DateTime>? date,
    Value<String>? zikrId,
    Value<int>? incrementCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DailyActivitiesCompanion(
      activeMilliseconds: activeMilliseconds ?? this.activeMilliseconds,
      date: date ?? this.date,
      zikrId: zikrId ?? this.zikrId,
      incrementCount: incrementCount ?? this.incrementCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (activeMilliseconds.present) {
      map['active_milliseconds'] = Variable<int>(activeMilliseconds.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (zikrId.present) {
      map['zikr_id'] = Variable<String>(zikrId.value);
    }
    if (incrementCount.present) {
      map['increment_count'] = Variable<int>(incrementCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyActivitiesCompanion(')
          ..write('activeMilliseconds: $activeMilliseconds, ')
          ..write('date: $date, ')
          ..write('zikrId: $zikrId, ')
          ..write('incrementCount: $incrementCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionEventsTable extends CompletionEvents
    with TableInfo<$CompletionEventsTable, CompletionEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventKeyMeta = const VerificationMeta(
    'eventKey',
  );
  @override
  late final GeneratedColumn<String> eventKey = GeneratedColumn<String>(
    'event_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalTypeMeta = const VerificationMeta(
    'goalType',
  );
  @override
  late final GeneratedColumn<String> goalType = GeneratedColumn<String>(
    'goal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetCountMeta = const VerificationMeta(
    'targetCount',
  );
  @override
  late final GeneratedColumn<int> targetCount = GeneratedColumn<int>(
    'target_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventKey,
    goalType,
    referenceId,
    targetCount,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completion_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletionEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_key')) {
      context.handle(
        _eventKeyMeta,
        eventKey.isAcceptableOrUnknown(data['event_key']!, _eventKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_eventKeyMeta);
    }
    if (data.containsKey('goal_type')) {
      context.handle(
        _goalTypeMeta,
        goalType.isAcceptableOrUnknown(data['goal_type']!, _goalTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_goalTypeMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referenceIdMeta);
    }
    if (data.containsKey('target_count')) {
      context.handle(
        _targetCountMeta,
        targetCount.isAcceptableOrUnknown(
          data['target_count']!,
          _targetCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetCountMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventKey};
  @override
  CompletionEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionEvent(
      eventKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_key'],
      )!,
      goalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_type'],
      )!,
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      )!,
      targetCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_count'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $CompletionEventsTable createAlias(String alias) {
    return $CompletionEventsTable(attachedDatabase, alias);
  }
}

class CompletionEvent extends DataClass implements Insertable<CompletionEvent> {
  final String eventKey;
  final String goalType;
  final String referenceId;
  final int targetCount;
  final DateTime completedAt;
  const CompletionEvent({
    required this.eventKey,
    required this.goalType,
    required this.referenceId,
    required this.targetCount,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_key'] = Variable<String>(eventKey);
    map['goal_type'] = Variable<String>(goalType);
    map['reference_id'] = Variable<String>(referenceId);
    map['target_count'] = Variable<int>(targetCount);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  CompletionEventsCompanion toCompanion(bool nullToAbsent) {
    return CompletionEventsCompanion(
      eventKey: Value(eventKey),
      goalType: Value(goalType),
      referenceId: Value(referenceId),
      targetCount: Value(targetCount),
      completedAt: Value(completedAt),
    );
  }

  factory CompletionEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionEvent(
      eventKey: serializer.fromJson<String>(json['eventKey']),
      goalType: serializer.fromJson<String>(json['goalType']),
      referenceId: serializer.fromJson<String>(json['referenceId']),
      targetCount: serializer.fromJson<int>(json['targetCount']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventKey': serializer.toJson<String>(eventKey),
      'goalType': serializer.toJson<String>(goalType),
      'referenceId': serializer.toJson<String>(referenceId),
      'targetCount': serializer.toJson<int>(targetCount),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  CompletionEvent copyWith({
    String? eventKey,
    String? goalType,
    String? referenceId,
    int? targetCount,
    DateTime? completedAt,
  }) => CompletionEvent(
    eventKey: eventKey ?? this.eventKey,
    goalType: goalType ?? this.goalType,
    referenceId: referenceId ?? this.referenceId,
    targetCount: targetCount ?? this.targetCount,
    completedAt: completedAt ?? this.completedAt,
  );
  CompletionEvent copyWithCompanion(CompletionEventsCompanion data) {
    return CompletionEvent(
      eventKey: data.eventKey.present ? data.eventKey.value : this.eventKey,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      targetCount: data.targetCount.present
          ? data.targetCount.value
          : this.targetCount,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionEvent(')
          ..write('eventKey: $eventKey, ')
          ..write('goalType: $goalType, ')
          ..write('referenceId: $referenceId, ')
          ..write('targetCount: $targetCount, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(eventKey, goalType, referenceId, targetCount, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionEvent &&
          other.eventKey == this.eventKey &&
          other.goalType == this.goalType &&
          other.referenceId == this.referenceId &&
          other.targetCount == this.targetCount &&
          other.completedAt == this.completedAt);
}

class CompletionEventsCompanion extends UpdateCompanion<CompletionEvent> {
  final Value<String> eventKey;
  final Value<String> goalType;
  final Value<String> referenceId;
  final Value<int> targetCount;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const CompletionEventsCompanion({
    this.eventKey = const Value.absent(),
    this.goalType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.targetCount = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionEventsCompanion.insert({
    required String eventKey,
    required String goalType,
    required String referenceId,
    required int targetCount,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : eventKey = Value(eventKey),
       goalType = Value(goalType),
       referenceId = Value(referenceId),
       targetCount = Value(targetCount),
       completedAt = Value(completedAt);
  static Insertable<CompletionEvent> custom({
    Expression<String>? eventKey,
    Expression<String>? goalType,
    Expression<String>? referenceId,
    Expression<int>? targetCount,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventKey != null) 'event_key': eventKey,
      if (goalType != null) 'goal_type': goalType,
      if (referenceId != null) 'reference_id': referenceId,
      if (targetCount != null) 'target_count': targetCount,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionEventsCompanion copyWith({
    Value<String>? eventKey,
    Value<String>? goalType,
    Value<String>? referenceId,
    Value<int>? targetCount,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return CompletionEventsCompanion(
      eventKey: eventKey ?? this.eventKey,
      goalType: goalType ?? this.goalType,
      referenceId: referenceId ?? this.referenceId,
      targetCount: targetCount ?? this.targetCount,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventKey.present) {
      map['event_key'] = Variable<String>(eventKey.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<String>(goalType.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (targetCount.present) {
      map['target_count'] = Variable<int>(targetCount.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionEventsCompanion(')
          ..write('eventKey: $eventKey, ')
          ..write('goalType: $goalType, ')
          ..write('referenceId: $referenceId, ')
          ..write('targetCount: $targetCount, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localeCodeMeta = const VerificationMeta(
    'localeCode',
  );
  @override
  late final GeneratedColumn<String> localeCode = GeneratedColumn<String>(
    'locale_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, localeCode, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('locale_code')) {
      context.handle(
        _localeCodeMeta,
        localeCode.isAcceptableOrUnknown(data['locale_code']!, _localeCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeCodeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_code'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  final int id;
  final String localeCode;
  final DateTime updatedAt;
  const UserPreference({
    required this.id,
    required this.localeCode,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['locale_code'] = Variable<String>(localeCode);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      id: Value(id),
      localeCode: Value(localeCode),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      id: serializer.fromJson<int>(json['id']),
      localeCode: serializer.fromJson<String>(json['localeCode']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localeCode': serializer.toJson<String>(localeCode),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserPreference copyWith({int? id, String? localeCode, DateTime? updatedAt}) =>
      UserPreference(
        id: id ?? this.id,
        localeCode: localeCode ?? this.localeCode,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      id: data.id.present ? data.id.value : this.id,
      localeCode: data.localeCode.present
          ? data.localeCode.value
          : this.localeCode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('id: $id, ')
          ..write('localeCode: $localeCode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, localeCode, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.id == this.id &&
          other.localeCode == this.localeCode &&
          other.updatedAt == this.updatedAt);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<int> id;
  final Value<String> localeCode;
  final Value<DateTime> updatedAt;
  const UserPreferencesCompanion({
    this.id = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    this.id = const Value.absent(),
    required String localeCode,
    required DateTime updatedAt,
  }) : localeCode = Value(localeCode),
       updatedAt = Value(updatedAt);
  static Insertable<UserPreference> custom({
    Expression<int>? id,
    Expression<String>? localeCode,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localeCode != null) 'locale_code': localeCode,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<int>? id,
    Value<String>? localeCode,
    Value<DateTime>? updatedAt,
  }) {
    return UserPreferencesCompanion(
      id: id ?? this.id,
      localeCode: localeCode ?? this.localeCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localeCode.present) {
      map['locale_code'] = Variable<String>(localeCode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('localeCode: $localeCode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ZikrsTable zikrs = $ZikrsTable(this);
  late final $CounterProgressesTable counterProgresses =
      $CounterProgressesTable(this);
  late final $DailyGoalsTable dailyGoals = $DailyGoalsTable(this);
  late final $DailyActivitiesTable dailyActivities = $DailyActivitiesTable(
    this,
  );
  late final $CompletionEventsTable completionEvents = $CompletionEventsTable(
    this,
  );
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    zikrs,
    counterProgresses,
    dailyGoals,
    dailyActivities,
    completionEvents,
    userPreferences,
  ];
}

typedef $$ZikrsTableCreateCompanionBuilder =
    ZikrsCompanion Function({
      required String id,
      required String title,
      Value<String?> arabicText,
      Value<String?> description,
      Value<int> defaultTarget,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<bool> isBuiltIn,
      Value<bool> isFavorite,
      Value<bool> isArchived,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$ZikrsTableUpdateCompanionBuilder =
    ZikrsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> arabicText,
      Value<String?> description,
      Value<int> defaultTarget,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isBuiltIn,
      Value<bool> isFavorite,
      Value<bool> isArchived,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$ZikrsTableReferences
    extends BaseReferences<_$AppDatabase, $ZikrsTable, Zikr> {
  $$ZikrsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $CounterProgressesTable,
    List<CounterProgressesData>
  >
  _counterProgressesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.counterProgresses,
        aliasName: 'zikrs__id__counter_progresses__zikr_id',
      );

  $$CounterProgressesTableProcessedTableManager get counterProgressesRefs {
    final manager = $$CounterProgressesTableTableManager(
      $_db,
      $_db.counterProgresses,
    ).filter((f) => f.zikrId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _counterProgressesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DailyActivitiesTable, List<DailyActivity>>
  _dailyActivitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dailyActivities,
    aliasName: 'zikrs__id__daily_activities__zikr_id',
  );

  $$DailyActivitiesTableProcessedTableManager get dailyActivitiesRefs {
    final manager = $$DailyActivitiesTableTableManager(
      $_db,
      $_db.dailyActivities,
    ).filter((f) => f.zikrId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dailyActivitiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ZikrsTableFilterComposer extends Composer<_$AppDatabase, $ZikrsTable> {
  $$ZikrsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultTarget => $composableBuilder(
    column: $table.defaultTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> counterProgressesRefs(
    Expression<bool> Function($$CounterProgressesTableFilterComposer f) f,
  ) {
    final $$CounterProgressesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.counterProgresses,
      getReferencedColumn: (t) => t.zikrId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CounterProgressesTableFilterComposer(
            $db: $db,
            $table: $db.counterProgresses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> dailyActivitiesRefs(
    Expression<bool> Function($$DailyActivitiesTableFilterComposer f) f,
  ) {
    final $$DailyActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyActivities,
      getReferencedColumn: (t) => t.zikrId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.dailyActivities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ZikrsTableOrderingComposer
    extends Composer<_$AppDatabase, $ZikrsTable> {
  $$ZikrsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultTarget => $composableBuilder(
    column: $table.defaultTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ZikrsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZikrsTable> {
  $$ZikrsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get arabicText => $composableBuilder(
    column: $table.arabicText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultTarget => $composableBuilder(
    column: $table.defaultTarget,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> counterProgressesRefs<T extends Object>(
    Expression<T> Function($$CounterProgressesTableAnnotationComposer a) f,
  ) {
    final $$CounterProgressesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.counterProgresses,
          getReferencedColumn: (t) => t.zikrId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CounterProgressesTableAnnotationComposer(
                $db: $db,
                $table: $db.counterProgresses,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> dailyActivitiesRefs<T extends Object>(
    Expression<T> Function($$DailyActivitiesTableAnnotationComposer a) f,
  ) {
    final $$DailyActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyActivities,
      getReferencedColumn: (t) => t.zikrId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyActivities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ZikrsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ZikrsTable,
          Zikr,
          $$ZikrsTableFilterComposer,
          $$ZikrsTableOrderingComposer,
          $$ZikrsTableAnnotationComposer,
          $$ZikrsTableCreateCompanionBuilder,
          $$ZikrsTableUpdateCompanionBuilder,
          (Zikr, $$ZikrsTableReferences),
          Zikr,
          PrefetchHooks Function({
            bool counterProgressesRefs,
            bool dailyActivitiesRefs,
          })
        > {
  $$ZikrsTableTableManager(_$AppDatabase db, $ZikrsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZikrsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZikrsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZikrsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> arabicText = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> defaultTarget = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZikrsCompanion(
                id: id,
                title: title,
                arabicText: arabicText,
                description: description,
                defaultTarget: defaultTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isBuiltIn: isBuiltIn,
                isFavorite: isFavorite,
                isArchived: isArchived,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> arabicText = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> defaultTarget = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<bool> isBuiltIn = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ZikrsCompanion.insert(
                id: id,
                title: title,
                arabicText: arabicText,
                description: description,
                defaultTarget: defaultTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isBuiltIn: isBuiltIn,
                isFavorite: isFavorite,
                isArchived: isArchived,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ZikrsTable, Zikr>(table),
                  $$ZikrsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({counterProgressesRefs = false, dailyActivitiesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (counterProgressesRefs) db.counterProgresses,
                    if (dailyActivitiesRefs) db.dailyActivities,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (counterProgressesRefs)
                        await $_getPrefetchedDataByColumns<
                          Zikr,
                          $ZikrsTable,
                          CounterProgressesData,
                          $CounterProgressesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ZikrsTableReferences
                              ._counterProgressesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ZikrsTableReferences(
                                db,
                                table,
                                p0,
                              ).counterProgressesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'zikr_id',
                          typedResults: items,
                        ),
                      if (dailyActivitiesRefs)
                        await $_getPrefetchedDataByColumns<
                          Zikr,
                          $ZikrsTable,
                          DailyActivity,
                          $DailyActivitiesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ZikrsTableReferences
                              ._dailyActivitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ZikrsTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyActivitiesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'zikr_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ZikrsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ZikrsTable,
      Zikr,
      $$ZikrsTableFilterComposer,
      $$ZikrsTableOrderingComposer,
      $$ZikrsTableAnnotationComposer,
      $$ZikrsTableCreateCompanionBuilder,
      $$ZikrsTableUpdateCompanionBuilder,
      (Zikr, $$ZikrsTableReferences),
      Zikr,
      PrefetchHooks Function({
        bool counterProgressesRefs,
        bool dailyActivitiesRefs,
      })
    >;
typedef $$CounterProgressesTableCreateCompanionBuilder =
    CounterProgressesCompanion Function({
      required String zikrId,
      Value<int> currentCount,
      required int targetCount,
      Value<DateTime?> completedAt,
      Value<DateTime?> completionHandledAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CounterProgressesTableUpdateCompanionBuilder =
    CounterProgressesCompanion Function({
      Value<String> zikrId,
      Value<int> currentCount,
      Value<int> targetCount,
      Value<DateTime?> completedAt,
      Value<DateTime?> completionHandledAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CounterProgressesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CounterProgressesTable,
          CounterProgressesData
        > {
  $$CounterProgressesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ZikrsTable _zikrIdTable(_$AppDatabase db) =>
      db.zikrs.createAlias('counter_progresses__zikr_id__zikrs__id');

  $$ZikrsTableProcessedTableManager get zikrId {
    final $_column = $_itemColumn<String>('zikr_id')!;

    final manager = $$ZikrsTableTableManager(
      $_db,
      $_db.zikrs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_zikrIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CounterProgressesTableFilterComposer
    extends Composer<_$AppDatabase, $CounterProgressesTable> {
  $$CounterProgressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completionHandledAt => $composableBuilder(
    column: $table.completionHandledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ZikrsTableFilterComposer get zikrId {
    final $$ZikrsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zikrId,
      referencedTable: $db.zikrs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZikrsTableFilterComposer(
            $db: $db,
            $table: $db.zikrs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CounterProgressesTableOrderingComposer
    extends Composer<_$AppDatabase, $CounterProgressesTable> {
  $$CounterProgressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completionHandledAt => $composableBuilder(
    column: $table.completionHandledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ZikrsTableOrderingComposer get zikrId {
    final $$ZikrsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zikrId,
      referencedTable: $db.zikrs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZikrsTableOrderingComposer(
            $db: $db,
            $table: $db.zikrs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CounterProgressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CounterProgressesTable> {
  $$CounterProgressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completionHandledAt => $composableBuilder(
    column: $table.completionHandledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ZikrsTableAnnotationComposer get zikrId {
    final $$ZikrsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zikrId,
      referencedTable: $db.zikrs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZikrsTableAnnotationComposer(
            $db: $db,
            $table: $db.zikrs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CounterProgressesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CounterProgressesTable,
          CounterProgressesData,
          $$CounterProgressesTableFilterComposer,
          $$CounterProgressesTableOrderingComposer,
          $$CounterProgressesTableAnnotationComposer,
          $$CounterProgressesTableCreateCompanionBuilder,
          $$CounterProgressesTableUpdateCompanionBuilder,
          (CounterProgressesData, $$CounterProgressesTableReferences),
          CounterProgressesData,
          PrefetchHooks Function({bool zikrId})
        > {
  $$CounterProgressesTableTableManager(
    _$AppDatabase db,
    $CounterProgressesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CounterProgressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CounterProgressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CounterProgressesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> zikrId = const Value.absent(),
                Value<int> currentCount = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> completionHandledAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CounterProgressesCompanion(
                zikrId: zikrId,
                currentCount: currentCount,
                targetCount: targetCount,
                completedAt: completedAt,
                completionHandledAt: completionHandledAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String zikrId,
                Value<int> currentCount = const Value.absent(),
                required int targetCount,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> completionHandledAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CounterProgressesCompanion.insert(
                zikrId: zikrId,
                currentCount: currentCount,
                targetCount: targetCount,
                completedAt: completedAt,
                completionHandledAt: completionHandledAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CounterProgressesTable, CounterProgressesData>(
                    table,
                  ),
                  $$CounterProgressesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({zikrId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (zikrId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.zikrId,
                                referencedTable:
                                    $$CounterProgressesTableReferences
                                        ._zikrIdTable(db),
                                referencedColumn:
                                    $$CounterProgressesTableReferences
                                        ._zikrIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CounterProgressesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CounterProgressesTable,
      CounterProgressesData,
      $$CounterProgressesTableFilterComposer,
      $$CounterProgressesTableOrderingComposer,
      $$CounterProgressesTableAnnotationComposer,
      $$CounterProgressesTableCreateCompanionBuilder,
      $$CounterProgressesTableUpdateCompanionBuilder,
      (CounterProgressesData, $$CounterProgressesTableReferences),
      CounterProgressesData,
      PrefetchHooks Function({bool zikrId})
    >;
typedef $$DailyGoalsTableCreateCompanionBuilder =
    DailyGoalsCompanion Function({
      required DateTime date,
      required int targetCount,
      Value<int> completedCount,
      Value<DateTime?> completedAt,
      Value<DateTime?> completionHandledAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DailyGoalsTableUpdateCompanionBuilder =
    DailyGoalsCompanion Function({
      Value<DateTime> date,
      Value<int> targetCount,
      Value<int> completedCount,
      Value<DateTime?> completedAt,
      Value<DateTime?> completionHandledAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DailyGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completionHandledAt => $composableBuilder(
    column: $table.completionHandledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completionHandledAt => $composableBuilder(
    column: $table.completionHandledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completionHandledAt => $composableBuilder(
    column: $table.completionHandledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailyGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyGoalsTable,
          DailyGoal,
          $$DailyGoalsTableFilterComposer,
          $$DailyGoalsTableOrderingComposer,
          $$DailyGoalsTableAnnotationComposer,
          $$DailyGoalsTableCreateCompanionBuilder,
          $$DailyGoalsTableUpdateCompanionBuilder,
          (
            DailyGoal,
            BaseReferences<_$AppDatabase, $DailyGoalsTable, DailyGoal>,
          ),
          DailyGoal,
          PrefetchHooks Function()
        > {
  $$DailyGoalsTableTableManager(_$AppDatabase db, $DailyGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> date = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<int> completedCount = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> completionHandledAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyGoalsCompanion(
                date: date,
                targetCount: targetCount,
                completedCount: completedCount,
                completedAt: completedAt,
                completionHandledAt: completionHandledAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime date,
                required int targetCount,
                Value<int> completedCount = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> completionHandledAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyGoalsCompanion.insert(
                date: date,
                targetCount: targetCount,
                completedCount: completedCount,
                completedAt: completedAt,
                completionHandledAt: completionHandledAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyGoalsTable, DailyGoal>(table),
                  BaseReferences<_$AppDatabase, $DailyGoalsTable, DailyGoal>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyGoalsTable,
      DailyGoal,
      $$DailyGoalsTableFilterComposer,
      $$DailyGoalsTableOrderingComposer,
      $$DailyGoalsTableAnnotationComposer,
      $$DailyGoalsTableCreateCompanionBuilder,
      $$DailyGoalsTableUpdateCompanionBuilder,
      (DailyGoal, BaseReferences<_$AppDatabase, $DailyGoalsTable, DailyGoal>),
      DailyGoal,
      PrefetchHooks Function()
    >;
typedef $$DailyActivitiesTableCreateCompanionBuilder =
    DailyActivitiesCompanion Function({
      Value<int> activeMilliseconds,
      required DateTime date,
      required String zikrId,
      Value<int> incrementCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DailyActivitiesTableUpdateCompanionBuilder =
    DailyActivitiesCompanion Function({
      Value<int> activeMilliseconds,
      Value<DateTime> date,
      Value<String> zikrId,
      Value<int> incrementCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DailyActivitiesTableReferences
    extends
        BaseReferences<_$AppDatabase, $DailyActivitiesTable, DailyActivity> {
  $$DailyActivitiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ZikrsTable _zikrIdTable(_$AppDatabase db) =>
      db.zikrs.createAlias('daily_activities__zikr_id__zikrs__id');

  $$ZikrsTableProcessedTableManager get zikrId {
    final $_column = $_itemColumn<String>('zikr_id')!;

    final manager = $$ZikrsTableTableManager(
      $_db,
      $_db.zikrs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_zikrIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DailyActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $DailyActivitiesTable> {
  $$DailyActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get activeMilliseconds => $composableBuilder(
    column: $table.activeMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get incrementCount => $composableBuilder(
    column: $table.incrementCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ZikrsTableFilterComposer get zikrId {
    final $$ZikrsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zikrId,
      referencedTable: $db.zikrs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZikrsTableFilterComposer(
            $db: $db,
            $table: $db.zikrs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyActivitiesTable> {
  $$DailyActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get activeMilliseconds => $composableBuilder(
    column: $table.activeMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get incrementCount => $composableBuilder(
    column: $table.incrementCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ZikrsTableOrderingComposer get zikrId {
    final $$ZikrsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zikrId,
      referencedTable: $db.zikrs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZikrsTableOrderingComposer(
            $db: $db,
            $table: $db.zikrs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyActivitiesTable> {
  $$DailyActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get activeMilliseconds => $composableBuilder(
    column: $table.activeMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get incrementCount => $composableBuilder(
    column: $table.incrementCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ZikrsTableAnnotationComposer get zikrId {
    final $$ZikrsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zikrId,
      referencedTable: $db.zikrs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ZikrsTableAnnotationComposer(
            $db: $db,
            $table: $db.zikrs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DailyActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyActivitiesTable,
          DailyActivity,
          $$DailyActivitiesTableFilterComposer,
          $$DailyActivitiesTableOrderingComposer,
          $$DailyActivitiesTableAnnotationComposer,
          $$DailyActivitiesTableCreateCompanionBuilder,
          $$DailyActivitiesTableUpdateCompanionBuilder,
          (DailyActivity, $$DailyActivitiesTableReferences),
          DailyActivity,
          PrefetchHooks Function({bool zikrId})
        > {
  $$DailyActivitiesTableTableManager(
    _$AppDatabase db,
    $DailyActivitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> activeMilliseconds = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> zikrId = const Value.absent(),
                Value<int> incrementCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyActivitiesCompanion(
                activeMilliseconds: activeMilliseconds,
                date: date,
                zikrId: zikrId,
                incrementCount: incrementCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> activeMilliseconds = const Value.absent(),
                required DateTime date,
                required String zikrId,
                Value<int> incrementCount = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyActivitiesCompanion.insert(
                activeMilliseconds: activeMilliseconds,
                date: date,
                zikrId: zikrId,
                incrementCount: incrementCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyActivitiesTable, DailyActivity>(table),
                  $$DailyActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({zikrId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (zikrId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.zikrId,
                                referencedTable:
                                    $$DailyActivitiesTableReferences
                                        ._zikrIdTable(db),
                                referencedColumn:
                                    $$DailyActivitiesTableReferences
                                        ._zikrIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DailyActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyActivitiesTable,
      DailyActivity,
      $$DailyActivitiesTableFilterComposer,
      $$DailyActivitiesTableOrderingComposer,
      $$DailyActivitiesTableAnnotationComposer,
      $$DailyActivitiesTableCreateCompanionBuilder,
      $$DailyActivitiesTableUpdateCompanionBuilder,
      (DailyActivity, $$DailyActivitiesTableReferences),
      DailyActivity,
      PrefetchHooks Function({bool zikrId})
    >;
typedef $$CompletionEventsTableCreateCompanionBuilder =
    CompletionEventsCompanion Function({
      required String eventKey,
      required String goalType,
      required String referenceId,
      required int targetCount,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$CompletionEventsTableUpdateCompanionBuilder =
    CompletionEventsCompanion Function({
      Value<String> eventKey,
      Value<String> goalType,
      Value<String> referenceId,
      Value<int> targetCount,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$CompletionEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CompletionEventsTable> {
  $$CompletionEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventKey => $composableBuilder(
    column: $table.eventKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletionEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletionEventsTable> {
  $$CompletionEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventKey => $composableBuilder(
    column: $table.eventKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletionEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletionEventsTable> {
  $$CompletionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventKey =>
      $composableBuilder(column: $table.eventKey, builder: (column) => column);

  GeneratedColumn<String> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetCount => $composableBuilder(
    column: $table.targetCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$CompletionEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletionEventsTable,
          CompletionEvent,
          $$CompletionEventsTableFilterComposer,
          $$CompletionEventsTableOrderingComposer,
          $$CompletionEventsTableAnnotationComposer,
          $$CompletionEventsTableCreateCompanionBuilder,
          $$CompletionEventsTableUpdateCompanionBuilder,
          (
            CompletionEvent,
            BaseReferences<
              _$AppDatabase,
              $CompletionEventsTable,
              CompletionEvent
            >,
          ),
          CompletionEvent,
          PrefetchHooks Function()
        > {
  $$CompletionEventsTableTableManager(
    _$AppDatabase db,
    $CompletionEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventKey = const Value.absent(),
                Value<String> goalType = const Value.absent(),
                Value<String> referenceId = const Value.absent(),
                Value<int> targetCount = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionEventsCompanion(
                eventKey: eventKey,
                goalType: goalType,
                referenceId: referenceId,
                targetCount: targetCount,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventKey,
                required String goalType,
                required String referenceId,
                required int targetCount,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => CompletionEventsCompanion.insert(
                eventKey: eventKey,
                goalType: goalType,
                referenceId: referenceId,
                targetCount: targetCount,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletionEventsTable, CompletionEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CompletionEventsTable,
                    CompletionEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletionEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletionEventsTable,
      CompletionEvent,
      $$CompletionEventsTableFilterComposer,
      $$CompletionEventsTableOrderingComposer,
      $$CompletionEventsTableAnnotationComposer,
      $$CompletionEventsTableCreateCompanionBuilder,
      $$CompletionEventsTableUpdateCompanionBuilder,
      (
        CompletionEvent,
        BaseReferences<_$AppDatabase, $CompletionEventsTable, CompletionEvent>,
      ),
      CompletionEvent,
      PrefetchHooks Function()
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      required String localeCode,
      required DateTime updatedAt,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<String> localeCode,
      Value<DateTime> updatedAt,
    });

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreference,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (
            UserPreference,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTable,
              UserPreference
            >,
          ),
          UserPreference,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> localeCode = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserPreferencesCompanion(
                id: id,
                localeCode: localeCode,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String localeCode,
                required DateTime updatedAt,
              }) => UserPreferencesCompanion.insert(
                id: id,
                localeCode: localeCode,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserPreferencesTable, UserPreference>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserPreferencesTable,
                    UserPreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreference,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (
        UserPreference,
        BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference>,
      ),
      UserPreference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ZikrsTableTableManager get zikrs =>
      $$ZikrsTableTableManager(_db, _db.zikrs);
  $$CounterProgressesTableTableManager get counterProgresses =>
      $$CounterProgressesTableTableManager(_db, _db.counterProgresses);
  $$DailyGoalsTableTableManager get dailyGoals =>
      $$DailyGoalsTableTableManager(_db, _db.dailyGoals);
  $$DailyActivitiesTableTableManager get dailyActivities =>
      $$DailyActivitiesTableTableManager(_db, _db.dailyActivities);
  $$CompletionEventsTableTableManager get completionEvents =>
      $$CompletionEventsTableTableManager(_db, _db.completionEvents);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
}
