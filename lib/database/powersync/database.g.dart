// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LanguageTableTable extends LanguageTable with TableInfo<$LanguageTableTable, Language> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LanguageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, shortName, fullName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'core_language';
  @override
  VerificationContext validateIntegrity(
    Insertable<Language> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Language map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Language(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
    );
  }

  @override
  $LanguageTableTable createAlias(String alias) {
    return $LanguageTableTable(attachedDatabase, alias);
  }
}

class LanguageTableCompanion extends UpdateCompanion<Language> {
  final Value<int> id;
  final Value<String> shortName;
  final Value<String> fullName;
  final Value<int> rowid;
  const LanguageTableCompanion({
    this.id = const Value.absent(),
    this.shortName = const Value.absent(),
    this.fullName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LanguageTableCompanion.insert({
    required int id,
    required String shortName,
    required String fullName,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shortName = Value(shortName),
       fullName = Value(fullName);
  static Insertable<Language> custom({
    Expression<int>? id,
    Expression<String>? shortName,
    Expression<String>? fullName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shortName != null) 'short_name': shortName,
      if (fullName != null) 'full_name': fullName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LanguageTableCompanion copyWith({
    Value<int>? id,
    Value<String>? shortName,
    Value<String>? fullName,
    Value<int>? rowid,
  }) {
    return LanguageTableCompanion(
      id: id ?? this.id,
      shortName: shortName ?? this.shortName,
      fullName: fullName ?? this.fullName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LanguageTableCompanion(')
          ..write('id: $id, ')
          ..write('shortName: $shortName, ')
          ..write('fullName: $fullName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseCategoryTableTable extends ExerciseCategoryTable
    with TableInfo<$ExerciseCategoryTableTable, ExerciseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseCategoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises_exercisecategory';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ExerciseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ExerciseCategoryTableTable createAlias(String alias) {
    return $ExerciseCategoryTableTable(attachedDatabase, alias);
  }
}

class ExerciseCategoryTableCompanion extends UpdateCompanion<ExerciseCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> rowid;
  const ExerciseCategoryTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseCategoryTableCompanion.insert({
    required int id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ExerciseCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseCategoryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return ExerciseCategoryTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseCategoryTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseTableTable extends ExerciseTable with TableInfo<$ExerciseTableTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variationIdMeta = const VerificationMeta(
    'variationId',
  );
  @override
  late final GeneratedColumn<int> variationId = GeneratedColumn<int>(
    'variation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises_exercisecategory (id)',
    ),
  );
  static const VerificationMeta _createdMeta = const VerificationMeta(
    'created',
  );
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdateMeta = const VerificationMeta(
    'lastUpdate',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdate = GeneratedColumn<DateTime>(
    'last_update',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    variationId,
    categoryId,
    created,
    lastUpdate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises_exercise';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('variation_id')) {
      context.handle(
        _variationIdMeta,
        variationId.isAcceptableOrUnknown(
          data['variation_id']!,
          _variationIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('created')) {
      context.handle(
        _createdMeta,
        created.isAcceptableOrUnknown(data['created']!, _createdMeta),
      );
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
        _lastUpdateMeta,
        lastUpdate.isAcceptableOrUnknown(data['last_update']!, _lastUpdateMeta),
      );
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      )!,
      lastUpdate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_update'],
      )!,
      variationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}variation_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $ExerciseTableTable createAlias(String alias) {
    return $ExerciseTableTable(attachedDatabase, alias);
  }
}

class ExerciseTableCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int?> variationId;
  final Value<int> categoryId;
  final Value<DateTime> created;
  final Value<DateTime> lastUpdate;
  final Value<int> rowid;
  const ExerciseTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.variationId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.created = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseTableCompanion.insert({
    required int id,
    required String uuid,
    this.variationId = const Value.absent(),
    required int categoryId,
    required DateTime created,
    required DateTime lastUpdate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       uuid = Value(uuid),
       categoryId = Value(categoryId),
       created = Value(created),
       lastUpdate = Value(lastUpdate);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? variationId,
    Expression<int>? categoryId,
    Expression<DateTime>? created,
    Expression<DateTime>? lastUpdate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (variationId != null) 'variation_id': variationId,
      if (categoryId != null) 'category_id': categoryId,
      if (created != null) 'created': created,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<int?>? variationId,
    Value<int>? categoryId,
    Value<DateTime>? created,
    Value<DateTime>? lastUpdate,
    Value<int>? rowid,
  }) {
    return ExerciseTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      variationId: variationId ?? this.variationId,
      categoryId: categoryId ?? this.categoryId,
      created: created ?? this.created,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (variationId.present) {
      map['variation_id'] = Variable<int>(variationId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<DateTime>(lastUpdate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('variationId: $variationId, ')
          ..write('categoryId: $categoryId, ')
          ..write('created: $created, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseTranslationTableTable extends ExerciseTranslationTable
    with TableInfo<$ExerciseTranslationTableTable, Translation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseTranslationTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises_exercise (id)',
    ),
  );
  static const VerificationMeta _languageIdMeta = const VerificationMeta(
    'languageId',
  );
  @override
  late final GeneratedColumn<int> languageId = GeneratedColumn<int>(
    'language_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES core_language (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdMeta = const VerificationMeta(
    'created',
  );
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdateMeta = const VerificationMeta(
    'lastUpdate',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdate = GeneratedColumn<DateTime>(
    'last_update',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    exerciseId,
    languageId,
    name,
    description,
    created,
    lastUpdate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises_translation';
  @override
  VerificationContext validateIntegrity(
    Insertable<Translation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('language_id')) {
      context.handle(
        _languageIdMeta,
        languageId.isAcceptableOrUnknown(data['language_id']!, _languageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_languageIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('created')) {
      context.handle(
        _createdMeta,
        created.isAcceptableOrUnknown(data['created']!, _createdMeta),
      );
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
        _lastUpdateMeta,
        lastUpdate.isAcceptableOrUnknown(data['last_update']!, _lastUpdateMeta),
      );
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Translation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Translation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
    );
  }

  @override
  $ExerciseTranslationTableTable createAlias(String alias) {
    return $ExerciseTranslationTableTable(attachedDatabase, alias);
  }
}

class ExerciseTranslationTableCompanion extends UpdateCompanion<Translation> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int> exerciseId;
  final Value<int> languageId;
  final Value<String> name;
  final Value<String> description;
  final Value<DateTime> created;
  final Value<DateTime> lastUpdate;
  final Value<int> rowid;
  const ExerciseTranslationTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.languageId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.created = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseTranslationTableCompanion.insert({
    required int id,
    required String uuid,
    required int exerciseId,
    required int languageId,
    required String name,
    required String description,
    required DateTime created,
    required DateTime lastUpdate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       uuid = Value(uuid),
       exerciseId = Value(exerciseId),
       languageId = Value(languageId),
       name = Value(name),
       description = Value(description),
       created = Value(created),
       lastUpdate = Value(lastUpdate);
  static Insertable<Translation> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? exerciseId,
    Expression<int>? languageId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? created,
    Expression<DateTime>? lastUpdate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (languageId != null) 'language_id': languageId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (created != null) 'created': created,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseTranslationTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<int>? exerciseId,
    Value<int>? languageId,
    Value<String>? name,
    Value<String>? description,
    Value<DateTime>? created,
    Value<DateTime>? lastUpdate,
    Value<int>? rowid,
  }) {
    return ExerciseTranslationTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      exerciseId: exerciseId ?? this.exerciseId,
      languageId: languageId ?? this.languageId,
      name: name ?? this.name,
      description: description ?? this.description,
      created: created ?? this.created,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (languageId.present) {
      map['language_id'] = Variable<int>(languageId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<DateTime>(lastUpdate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseTranslationTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('languageId: $languageId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('created: $created, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MuscleTableTable extends MuscleTable with TableInfo<$MuscleTableTable, Muscle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MuscleTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFrontMeta = const VerificationMeta(
    'isFront',
  );
  @override
  late final GeneratedColumn<bool> isFront = GeneratedColumn<bool>(
    'is_front',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_front" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, nameEn, isFront];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises_muscle';
  @override
  VerificationContext validateIntegrity(
    Insertable<Muscle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('is_front')) {
      context.handle(
        _isFrontMeta,
        isFront.isAcceptableOrUnknown(data['is_front']!, _isFrontMeta),
      );
    } else if (isInserting) {
      context.missing(_isFrontMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Muscle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Muscle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
      isFront: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_front'],
      )!,
    );
  }

  @override
  $MuscleTableTable createAlias(String alias) {
    return $MuscleTableTable(attachedDatabase, alias);
  }
}

class MuscleTableCompanion extends UpdateCompanion<Muscle> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameEn;
  final Value<bool> isFront;
  final Value<int> rowid;
  const MuscleTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.isFront = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MuscleTableCompanion.insert({
    required int id,
    required String name,
    required String nameEn,
    required bool isFront,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       nameEn = Value(nameEn),
       isFront = Value(isFront);
  static Insertable<Muscle> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameEn,
    Expression<bool>? isFront,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameEn != null) 'name_en': nameEn,
      if (isFront != null) 'is_front': isFront,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MuscleTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameEn,
    Value<bool>? isFront,
    Value<int>? rowid,
  }) {
    return MuscleTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      isFront: isFront ?? this.isFront,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (isFront.present) {
      map['is_front'] = Variable<bool>(isFront.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MuscleTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEn: $nameEn, ')
          ..write('isFront: $isFront, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMuscleM2NTable extends ExerciseMuscleM2N
    with TableInfo<$ExerciseMuscleM2NTable, ExerciseMuscleM2NData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMuscleM2NTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises_exercise (id)',
    ),
  );
  static const VerificationMeta _muscleIdMeta = const VerificationMeta(
    'muscleId',
  );
  @override
  late final GeneratedColumn<int> muscleId = GeneratedColumn<int>(
    'muscle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises_muscle (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, exerciseId, muscleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises_exercise_muscles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseMuscleM2NData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('muscle_id')) {
      context.handle(
        _muscleIdMeta,
        muscleId.isAcceptableOrUnknown(data['muscle_id']!, _muscleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_muscleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ExerciseMuscleM2NData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMuscleM2NData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      muscleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muscle_id'],
      )!,
    );
  }

  @override
  $ExerciseMuscleM2NTable createAlias(String alias) {
    return $ExerciseMuscleM2NTable(attachedDatabase, alias);
  }
}

class ExerciseMuscleM2NData extends DataClass implements Insertable<ExerciseMuscleM2NData> {
  final int id;
  final int exerciseId;
  final int muscleId;
  const ExerciseMuscleM2NData({
    required this.id,
    required this.exerciseId,
    required this.muscleId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['muscle_id'] = Variable<int>(muscleId);
    return map;
  }

  ExerciseMuscleM2NCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMuscleM2NCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      muscleId: Value(muscleId),
    );
  }

  factory ExerciseMuscleM2NData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMuscleM2NData(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      muscleId: serializer.fromJson<int>(json['muscleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'muscleId': serializer.toJson<int>(muscleId),
    };
  }

  ExerciseMuscleM2NData copyWith({int? id, int? exerciseId, int? muscleId}) =>
      ExerciseMuscleM2NData(
        id: id ?? this.id,
        exerciseId: exerciseId ?? this.exerciseId,
        muscleId: muscleId ?? this.muscleId,
      );
  ExerciseMuscleM2NData copyWithCompanion(ExerciseMuscleM2NCompanion data) {
    return ExerciseMuscleM2NData(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      muscleId: data.muscleId.present ? data.muscleId.value : this.muscleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscleM2NData(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleId: $muscleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, exerciseId, muscleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseMuscleM2NData &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.muscleId == this.muscleId);
}

class ExerciseMuscleM2NCompanion extends UpdateCompanion<ExerciseMuscleM2NData> {
  final Value<int> id;
  final Value<int> exerciseId;
  final Value<int> muscleId;
  final Value<int> rowid;
  const ExerciseMuscleM2NCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.muscleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMuscleM2NCompanion.insert({
    required int id,
    required int exerciseId,
    required int muscleId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseId = Value(exerciseId),
       muscleId = Value(muscleId);
  static Insertable<ExerciseMuscleM2NData> custom({
    Expression<int>? id,
    Expression<int>? exerciseId,
    Expression<int>? muscleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (muscleId != null) 'muscle_id': muscleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMuscleM2NCompanion copyWith({
    Value<int>? id,
    Value<int>? exerciseId,
    Value<int>? muscleId,
    Value<int>? rowid,
  }) {
    return ExerciseMuscleM2NCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      muscleId: muscleId ?? this.muscleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (muscleId.present) {
      map['muscle_id'] = Variable<int>(muscleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMuscleM2NCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleId: $muscleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseSecondaryMuscleM2NTable extends ExerciseSecondaryMuscleM2N
    with TableInfo<$ExerciseSecondaryMuscleM2NTable, ExerciseSecondaryMuscleM2NData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseSecondaryMuscleM2NTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises_exercise (id)',
    ),
  );
  static const VerificationMeta _muscleIdMeta = const VerificationMeta(
    'muscleId',
  );
  @override
  late final GeneratedColumn<int> muscleId = GeneratedColumn<int>(
    'muscle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises_muscle (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, exerciseId, muscleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises_exercise_muscles_secondary';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseSecondaryMuscleM2NData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('muscle_id')) {
      context.handle(
        _muscleIdMeta,
        muscleId.isAcceptableOrUnknown(data['muscle_id']!, _muscleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_muscleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ExerciseSecondaryMuscleM2NData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseSecondaryMuscleM2NData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      muscleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muscle_id'],
      )!,
    );
  }

  @override
  $ExerciseSecondaryMuscleM2NTable createAlias(String alias) {
    return $ExerciseSecondaryMuscleM2NTable(attachedDatabase, alias);
  }
}

class ExerciseSecondaryMuscleM2NData extends DataClass
    implements Insertable<ExerciseSecondaryMuscleM2NData> {
  final int id;
  final int exerciseId;
  final int muscleId;
  const ExerciseSecondaryMuscleM2NData({
    required this.id,
    required this.exerciseId,
    required this.muscleId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['muscle_id'] = Variable<int>(muscleId);
    return map;
  }

  ExerciseSecondaryMuscleM2NCompanion toCompanion(bool nullToAbsent) {
    return ExerciseSecondaryMuscleM2NCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      muscleId: Value(muscleId),
    );
  }

  factory ExerciseSecondaryMuscleM2NData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseSecondaryMuscleM2NData(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      muscleId: serializer.fromJson<int>(json['muscleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'muscleId': serializer.toJson<int>(muscleId),
    };
  }

  ExerciseSecondaryMuscleM2NData copyWith({
    int? id,
    int? exerciseId,
    int? muscleId,
  }) => ExerciseSecondaryMuscleM2NData(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    muscleId: muscleId ?? this.muscleId,
  );
  ExerciseSecondaryMuscleM2NData copyWithCompanion(
    ExerciseSecondaryMuscleM2NCompanion data,
  ) {
    return ExerciseSecondaryMuscleM2NData(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      muscleId: data.muscleId.present ? data.muscleId.value : this.muscleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSecondaryMuscleM2NData(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleId: $muscleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, exerciseId, muscleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseSecondaryMuscleM2NData &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.muscleId == this.muscleId);
}

class ExerciseSecondaryMuscleM2NCompanion extends UpdateCompanion<ExerciseSecondaryMuscleM2NData> {
  final Value<int> id;
  final Value<int> exerciseId;
  final Value<int> muscleId;
  final Value<int> rowid;
  const ExerciseSecondaryMuscleM2NCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.muscleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseSecondaryMuscleM2NCompanion.insert({
    required int id,
    required int exerciseId,
    required int muscleId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseId = Value(exerciseId),
       muscleId = Value(muscleId);
  static Insertable<ExerciseSecondaryMuscleM2NData> custom({
    Expression<int>? id,
    Expression<int>? exerciseId,
    Expression<int>? muscleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (muscleId != null) 'muscle_id': muscleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseSecondaryMuscleM2NCompanion copyWith({
    Value<int>? id,
    Value<int>? exerciseId,
    Value<int>? muscleId,
    Value<int>? rowid,
  }) {
    return ExerciseSecondaryMuscleM2NCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      muscleId: muscleId ?? this.muscleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (muscleId.present) {
      map['muscle_id'] = Variable<int>(muscleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseSecondaryMuscleM2NCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('muscleId: $muscleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EquipmentTableTable extends EquipmentTable with TableInfo<$EquipmentTableTable, Equipment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquipmentTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises_equipment';
  @override
  VerificationContext validateIntegrity(
    Insertable<Equipment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Equipment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Equipment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $EquipmentTableTable createAlias(String alias) {
    return $EquipmentTableTable(attachedDatabase, alias);
  }
}

class EquipmentTableCompanion extends UpdateCompanion<Equipment> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> rowid;
  const EquipmentTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EquipmentTableCompanion.insert({
    required int id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Equipment> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EquipmentTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return EquipmentTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseEquipmentM2NTable extends ExerciseEquipmentM2N
    with TableInfo<$ExerciseEquipmentM2NTable, ExerciseEquipmentM2NData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseEquipmentM2NTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises_exercise (id)',
    ),
  );
  static const VerificationMeta _equipmentIdMeta = const VerificationMeta(
    'equipmentId',
  );
  @override
  late final GeneratedColumn<int> equipmentId = GeneratedColumn<int>(
    'equipment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises_equipment (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, exerciseId, equipmentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises_exercise_equipment';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseEquipmentM2NData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('equipment_id')) {
      context.handle(
        _equipmentIdMeta,
        equipmentId.isAcceptableOrUnknown(
          data['equipment_id']!,
          _equipmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ExerciseEquipmentM2NData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseEquipmentM2NData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      equipmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}equipment_id'],
      )!,
    );
  }

  @override
  $ExerciseEquipmentM2NTable createAlias(String alias) {
    return $ExerciseEquipmentM2NTable(attachedDatabase, alias);
  }
}

class ExerciseEquipmentM2NData extends DataClass implements Insertable<ExerciseEquipmentM2NData> {
  final int id;
  final int exerciseId;
  final int equipmentId;
  const ExerciseEquipmentM2NData({
    required this.id,
    required this.exerciseId,
    required this.equipmentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['equipment_id'] = Variable<int>(equipmentId);
    return map;
  }

  ExerciseEquipmentM2NCompanion toCompanion(bool nullToAbsent) {
    return ExerciseEquipmentM2NCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      equipmentId: Value(equipmentId),
    );
  }

  factory ExerciseEquipmentM2NData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseEquipmentM2NData(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      equipmentId: serializer.fromJson<int>(json['equipmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'equipmentId': serializer.toJson<int>(equipmentId),
    };
  }

  ExerciseEquipmentM2NData copyWith({
    int? id,
    int? exerciseId,
    int? equipmentId,
  }) => ExerciseEquipmentM2NData(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    equipmentId: equipmentId ?? this.equipmentId,
  );
  ExerciseEquipmentM2NData copyWithCompanion(
    ExerciseEquipmentM2NCompanion data,
  ) {
    return ExerciseEquipmentM2NData(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      equipmentId: data.equipmentId.present ? data.equipmentId.value : this.equipmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEquipmentM2NData(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipmentId: $equipmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, exerciseId, equipmentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseEquipmentM2NData &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.equipmentId == this.equipmentId);
}

class ExerciseEquipmentM2NCompanion extends UpdateCompanion<ExerciseEquipmentM2NData> {
  final Value<int> id;
  final Value<int> exerciseId;
  final Value<int> equipmentId;
  final Value<int> rowid;
  const ExerciseEquipmentM2NCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseEquipmentM2NCompanion.insert({
    required int id,
    required int exerciseId,
    required int equipmentId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseId = Value(exerciseId),
       equipmentId = Value(equipmentId);
  static Insertable<ExerciseEquipmentM2NData> custom({
    Expression<int>? id,
    Expression<int>? exerciseId,
    Expression<int>? equipmentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (equipmentId != null) 'equipment_id': equipmentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseEquipmentM2NCompanion copyWith({
    Value<int>? id,
    Value<int>? exerciseId,
    Value<int>? equipmentId,
    Value<int>? rowid,
  }) {
    return ExerciseEquipmentM2NCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      equipmentId: equipmentId ?? this.equipmentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (equipmentId.present) {
      map['equipment_id'] = Variable<int>(equipmentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseEquipmentM2NCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseImageTableTable extends ExerciseImageTable
    with TableInfo<$ExerciseImageTableTable, ExerciseImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseImageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises_exercise (id)',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isMainMeta = const VerificationMeta('isMain');
  @override
  late final GeneratedColumn<bool> isMain = GeneratedColumn<bool>(
    'is_main',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_main" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, uuid, exerciseId, url, isMain];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises_exerciseimage';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('is_main')) {
      context.handle(
        _isMainMeta,
        isMain.isAcceptableOrUnknown(data['is_main']!, _isMainMeta),
      );
    } else if (isInserting) {
      context.missing(_isMainMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ExerciseImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseImage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      isMain: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_main'],
      )!,
    );
  }

  @override
  $ExerciseImageTableTable createAlias(String alias) {
    return $ExerciseImageTableTable(attachedDatabase, alias);
  }
}

class ExerciseImageTableCompanion extends UpdateCompanion<ExerciseImage> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int> exerciseId;
  final Value<String> url;
  final Value<bool> isMain;
  final Value<int> rowid;
  const ExerciseImageTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.url = const Value.absent(),
    this.isMain = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseImageTableCompanion.insert({
    required int id,
    required String uuid,
    required int exerciseId,
    required String url,
    required bool isMain,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       uuid = Value(uuid),
       exerciseId = Value(exerciseId),
       url = Value(url),
       isMain = Value(isMain);
  static Insertable<ExerciseImage> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? exerciseId,
    Expression<String>? url,
    Expression<bool>? isMain,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (url != null) 'url': url,
      if (isMain != null) 'is_main': isMain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseImageTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<int>? exerciseId,
    Value<String>? url,
    Value<bool>? isMain,
    Value<int>? rowid,
  }) {
    return ExerciseImageTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      exerciseId: exerciseId ?? this.exerciseId,
      url: url ?? this.url,
      isMain: isMain ?? this.isMain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (isMain.present) {
      map['is_main'] = Variable<bool>(isMain.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseImageTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('url: $url, ')
          ..write('isMain: $isMain, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseVideoTableTable extends ExerciseVideoTable
    with TableInfo<$ExerciseVideoTableTable, Video> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseVideoTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises_exercise (id)',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codecMeta = const VerificationMeta('codec');
  @override
  late final GeneratedColumn<String> codec = GeneratedColumn<String>(
    'codec',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codecLongMeta = const VerificationMeta(
    'codecLong',
  );
  @override
  late final GeneratedColumn<String> codecLong = GeneratedColumn<String>(
    'codec_long',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseIdMeta = const VerificationMeta(
    'licenseId',
  );
  @override
  late final GeneratedColumn<int> licenseId = GeneratedColumn<int>(
    'license_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseAuthorMeta = const VerificationMeta(
    'licenseAuthor',
  );
  @override
  late final GeneratedColumn<String> licenseAuthor = GeneratedColumn<String>(
    'license_author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    exerciseId,
    url,
    size,
    duration,
    width,
    height,
    codec,
    codecLong,
    licenseId,
    licenseAuthor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises_exercisevideo';
  @override
  VerificationContext validateIntegrity(
    Insertable<Video> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('codec')) {
      context.handle(
        _codecMeta,
        codec.isAcceptableOrUnknown(data['codec']!, _codecMeta),
      );
    } else if (isInserting) {
      context.missing(_codecMeta);
    }
    if (data.containsKey('codec_long')) {
      context.handle(
        _codecLongMeta,
        codecLong.isAcceptableOrUnknown(data['codec_long']!, _codecLongMeta),
      );
    } else if (isInserting) {
      context.missing(_codecLongMeta);
    }
    if (data.containsKey('license_id')) {
      context.handle(
        _licenseIdMeta,
        licenseId.isAcceptableOrUnknown(data['license_id']!, _licenseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_licenseIdMeta);
    }
    if (data.containsKey('license_author')) {
      context.handle(
        _licenseAuthorMeta,
        licenseAuthor.isAcceptableOrUnknown(
          data['license_author']!,
          _licenseAuthorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_licenseAuthorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Video map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Video(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      codec: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codec'],
      )!,
      codecLong: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codec_long'],
      )!,
      licenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}license_id'],
      )!,
      licenseAuthor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_author'],
      )!,
    );
  }

  @override
  $ExerciseVideoTableTable createAlias(String alias) {
    return $ExerciseVideoTableTable(attachedDatabase, alias);
  }
}

class ExerciseVideoTableCompanion extends UpdateCompanion<Video> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int> exerciseId;
  final Value<String> url;
  final Value<int> size;
  final Value<int> duration;
  final Value<int> width;
  final Value<int> height;
  final Value<String> codec;
  final Value<String> codecLong;
  final Value<int> licenseId;
  final Value<String> licenseAuthor;
  final Value<int> rowid;
  const ExerciseVideoTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.url = const Value.absent(),
    this.size = const Value.absent(),
    this.duration = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.codec = const Value.absent(),
    this.codecLong = const Value.absent(),
    this.licenseId = const Value.absent(),
    this.licenseAuthor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseVideoTableCompanion.insert({
    required int id,
    required String uuid,
    required int exerciseId,
    required String url,
    required int size,
    required int duration,
    required int width,
    required int height,
    required String codec,
    required String codecLong,
    required int licenseId,
    required String licenseAuthor,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       uuid = Value(uuid),
       exerciseId = Value(exerciseId),
       url = Value(url),
       size = Value(size),
       duration = Value(duration),
       width = Value(width),
       height = Value(height),
       codec = Value(codec),
       codecLong = Value(codecLong),
       licenseId = Value(licenseId),
       licenseAuthor = Value(licenseAuthor);
  static Insertable<Video> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? exerciseId,
    Expression<String>? url,
    Expression<int>? size,
    Expression<int>? duration,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? codec,
    Expression<String>? codecLong,
    Expression<int>? licenseId,
    Expression<String>? licenseAuthor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (url != null) 'url': url,
      if (size != null) 'size': size,
      if (duration != null) 'duration': duration,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (codec != null) 'codec': codec,
      if (codecLong != null) 'codec_long': codecLong,
      if (licenseId != null) 'license_id': licenseId,
      if (licenseAuthor != null) 'license_author': licenseAuthor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseVideoTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<int>? exerciseId,
    Value<String>? url,
    Value<int>? size,
    Value<int>? duration,
    Value<int>? width,
    Value<int>? height,
    Value<String>? codec,
    Value<String>? codecLong,
    Value<int>? licenseId,
    Value<String>? licenseAuthor,
    Value<int>? rowid,
  }) {
    return ExerciseVideoTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      exerciseId: exerciseId ?? this.exerciseId,
      url: url ?? this.url,
      size: size ?? this.size,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      codec: codec ?? this.codec,
      codecLong: codecLong ?? this.codecLong,
      licenseId: licenseId ?? this.licenseId,
      licenseAuthor: licenseAuthor ?? this.licenseAuthor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (codec.present) {
      map['codec'] = Variable<String>(codec.value);
    }
    if (codecLong.present) {
      map['codec_long'] = Variable<String>(codecLong.value);
    }
    if (licenseId.present) {
      map['license_id'] = Variable<int>(licenseId.value);
    }
    if (licenseAuthor.present) {
      map['license_author'] = Variable<String>(licenseAuthor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseVideoTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('url: $url, ')
          ..write('size: $size, ')
          ..write('duration: $duration, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('codec: $codec, ')
          ..write('codecLong: $codecLong, ')
          ..write('licenseId: $licenseId, ')
          ..write('licenseAuthor: $licenseAuthor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightEntryTableTable extends WeightEntryTable
    with TableInfo<$WeightEntryTableTable, WeightEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightEntryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, weight, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_weightentry';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  WeightEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
    );
  }

  @override
  $WeightEntryTableTable createAlias(String alias) {
    return $WeightEntryTableTable(attachedDatabase, alias);
  }
}

class WeightEntryTableCompanion extends UpdateCompanion<WeightEntry> {
  final Value<String> id;
  final Value<double> weight;
  final Value<DateTime?> date;
  final Value<int> rowid;
  const WeightEntryTableCompanion({
    this.id = const Value.absent(),
    this.weight = const Value.absent(),
    this.date = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightEntryTableCompanion.insert({
    this.id = const Value.absent(),
    required double weight,
    this.date = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : weight = Value(weight);
  static Insertable<WeightEntry> custom({
    Expression<String>? id,
    Expression<double>? weight,
    Expression<DateTime>? date,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weight != null) 'weight': weight,
      if (date != null) 'date': date,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightEntryTableCompanion copyWith({
    Value<String>? id,
    Value<double>? weight,
    Value<DateTime?>? date,
    Value<int>? rowid,
  }) {
    return WeightEntryTableCompanion(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntryTableCompanion(')
          ..write('id: $id, ')
          ..write('weight: $weight, ')
          ..write('date: $date, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementCategoryTableTable extends MeasurementCategoryTable
    with TableInfo<$MeasurementCategoryTableTable, MeasurementCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementCategoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, unit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements_category';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  MeasurementCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
    );
  }

  @override
  $MeasurementCategoryTableTable createAlias(String alias) {
    return $MeasurementCategoryTableTable(attachedDatabase, alias);
  }
}

class MeasurementCategoryTableCompanion extends UpdateCompanion<MeasurementCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> unit;
  final Value<int> rowid;
  const MeasurementCategoryTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementCategoryTableCompanion.insert({
    required int id,
    required String name,
    required String unit,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       unit = Value(unit);
  static Insertable<MeasurementCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementCategoryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? unit,
    Value<int>? rowid,
  }) {
    return MeasurementCategoryTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementCategoryTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutLogTableTable extends WorkoutLogTable with TableInfo<$WorkoutLogTableTable, Log> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iterationMeta = const VerificationMeta(
    'iteration',
  );
  @override
  late final GeneratedColumn<int> iteration = GeneratedColumn<int>(
    'iteration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slotEntryIdMeta = const VerificationMeta(
    'slotEntryId',
  );
  @override
  late final GeneratedColumn<int> slotEntryId = GeneratedColumn<int>(
    'slot_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rirMeta = const VerificationMeta('rir');
  @override
  late final GeneratedColumn<double> rir = GeneratedColumn<double>(
    'rir',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rirTargetMeta = const VerificationMeta(
    'rirTarget',
  );
  @override
  late final GeneratedColumn<double> rirTarget = GeneratedColumn<double>(
    'rir_target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<double> repetitions = GeneratedColumn<double>(
    'repetitions',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repetitionsTargetMeta = const VerificationMeta(
    'repetitionsTarget',
  );
  @override
  late final GeneratedColumn<double> repetitionsTarget = GeneratedColumn<double>(
    'repetitions_target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repetitionsUnitIdMeta = const VerificationMeta(
    'repetitionsUnitId',
  );
  @override
  late final GeneratedColumn<int> repetitionsUnitId = GeneratedColumn<int>(
    'repetitions_unit_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightTargetMeta = const VerificationMeta(
    'weightTarget',
  );
  @override
  late final GeneratedColumn<double> weightTarget = GeneratedColumn<double>(
    'weight_target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightUnitIdMeta = const VerificationMeta(
    'weightUnitId',
  );
  @override
  late final GeneratedColumn<int> weightUnitId = GeneratedColumn<int>(
    'weight_unit_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    routineId,
    sessionId,
    iteration,
    slotEntryId,
    rir,
    rirTarget,
    repetitions,
    repetitionsTarget,
    repetitionsUnitId,
    weight,
    weightTarget,
    weightUnitId,
    date,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manager_workoutlog';
  @override
  VerificationContext validateIntegrity(
    Insertable<Log> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('iteration')) {
      context.handle(
        _iterationMeta,
        iteration.isAcceptableOrUnknown(data['iteration']!, _iterationMeta),
      );
    }
    if (data.containsKey('slot_entry_id')) {
      context.handle(
        _slotEntryIdMeta,
        slotEntryId.isAcceptableOrUnknown(
          data['slot_entry_id']!,
          _slotEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('rir')) {
      context.handle(
        _rirMeta,
        rir.isAcceptableOrUnknown(data['rir']!, _rirMeta),
      );
    }
    if (data.containsKey('rir_target')) {
      context.handle(
        _rirTargetMeta,
        rirTarget.isAcceptableOrUnknown(data['rir_target']!, _rirTargetMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('repetitions_target')) {
      context.handle(
        _repetitionsTargetMeta,
        repetitionsTarget.isAcceptableOrUnknown(
          data['repetitions_target']!,
          _repetitionsTargetMeta,
        ),
      );
    }
    if (data.containsKey('repetitions_unit_id')) {
      context.handle(
        _repetitionsUnitIdMeta,
        repetitionsUnitId.isAcceptableOrUnknown(
          data['repetitions_unit_id']!,
          _repetitionsUnitIdMeta,
        ),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('weight_target')) {
      context.handle(
        _weightTargetMeta,
        weightTarget.isAcceptableOrUnknown(
          data['weight_target']!,
          _weightTargetMeta,
        ),
      );
    }
    if (data.containsKey('weight_unit_id')) {
      context.handle(
        _weightUnitIdMeta,
        weightUnitId.isAcceptableOrUnknown(
          data['weight_unit_id']!,
          _weightUnitIdMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Log map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Log(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      iteration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iteration'],
      ),
      slotEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_entry_id'],
      ),
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_id'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}repetitions'],
      ),
      repetitionsTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}repetitions_target'],
      ),
      repetitionsUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions_unit_id'],
      ),
      rir: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rir'],
      ),
      rirTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rir_target'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      weightTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_target'],
      ),
      weightUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_unit_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $WorkoutLogTableTable createAlias(String alias) {
    return $WorkoutLogTableTable(attachedDatabase, alias);
  }
}

class WorkoutLogTableCompanion extends UpdateCompanion<Log> {
  final Value<String> id;
  final Value<int> exerciseId;
  final Value<int> routineId;
  final Value<int?> sessionId;
  final Value<int?> iteration;
  final Value<int?> slotEntryId;
  final Value<double?> rir;
  final Value<double?> rirTarget;
  final Value<double?> repetitions;
  final Value<double?> repetitionsTarget;
  final Value<int?> repetitionsUnitId;
  final Value<double?> weight;
  final Value<double?> weightTarget;
  final Value<int?> weightUnitId;
  final Value<DateTime> date;
  final Value<int> rowid;
  const WorkoutLogTableCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.routineId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.iteration = const Value.absent(),
    this.slotEntryId = const Value.absent(),
    this.rir = const Value.absent(),
    this.rirTarget = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.repetitionsTarget = const Value.absent(),
    this.repetitionsUnitId = const Value.absent(),
    this.weight = const Value.absent(),
    this.weightTarget = const Value.absent(),
    this.weightUnitId = const Value.absent(),
    this.date = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutLogTableCompanion.insert({
    this.id = const Value.absent(),
    required int exerciseId,
    required int routineId,
    this.sessionId = const Value.absent(),
    this.iteration = const Value.absent(),
    this.slotEntryId = const Value.absent(),
    this.rir = const Value.absent(),
    this.rirTarget = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.repetitionsTarget = const Value.absent(),
    this.repetitionsUnitId = const Value.absent(),
    this.weight = const Value.absent(),
    this.weightTarget = const Value.absent(),
    this.weightUnitId = const Value.absent(),
    required DateTime date,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       routineId = Value(routineId),
       date = Value(date);
  static Insertable<Log> custom({
    Expression<String>? id,
    Expression<int>? exerciseId,
    Expression<int>? routineId,
    Expression<int>? sessionId,
    Expression<int>? iteration,
    Expression<int>? slotEntryId,
    Expression<double>? rir,
    Expression<double>? rirTarget,
    Expression<double>? repetitions,
    Expression<double>? repetitionsTarget,
    Expression<int>? repetitionsUnitId,
    Expression<double>? weight,
    Expression<double>? weightTarget,
    Expression<int>? weightUnitId,
    Expression<DateTime>? date,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (routineId != null) 'routine_id': routineId,
      if (sessionId != null) 'session_id': sessionId,
      if (iteration != null) 'iteration': iteration,
      if (slotEntryId != null) 'slot_entry_id': slotEntryId,
      if (rir != null) 'rir': rir,
      if (rirTarget != null) 'rir_target': rirTarget,
      if (repetitions != null) 'repetitions': repetitions,
      if (repetitionsTarget != null) 'repetitions_target': repetitionsTarget,
      if (repetitionsUnitId != null) 'repetitions_unit_id': repetitionsUnitId,
      if (weight != null) 'weight': weight,
      if (weightTarget != null) 'weight_target': weightTarget,
      if (weightUnitId != null) 'weight_unit_id': weightUnitId,
      if (date != null) 'date': date,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutLogTableCompanion copyWith({
    Value<String>? id,
    Value<int>? exerciseId,
    Value<int>? routineId,
    Value<int?>? sessionId,
    Value<int?>? iteration,
    Value<int?>? slotEntryId,
    Value<double?>? rir,
    Value<double?>? rirTarget,
    Value<double?>? repetitions,
    Value<double?>? repetitionsTarget,
    Value<int?>? repetitionsUnitId,
    Value<double?>? weight,
    Value<double?>? weightTarget,
    Value<int?>? weightUnitId,
    Value<DateTime>? date,
    Value<int>? rowid,
  }) {
    return WorkoutLogTableCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      routineId: routineId ?? this.routineId,
      sessionId: sessionId ?? this.sessionId,
      iteration: iteration ?? this.iteration,
      slotEntryId: slotEntryId ?? this.slotEntryId,
      rir: rir ?? this.rir,
      rirTarget: rirTarget ?? this.rirTarget,
      repetitions: repetitions ?? this.repetitions,
      repetitionsTarget: repetitionsTarget ?? this.repetitionsTarget,
      repetitionsUnitId: repetitionsUnitId ?? this.repetitionsUnitId,
      weight: weight ?? this.weight,
      weightTarget: weightTarget ?? this.weightTarget,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      date: date ?? this.date,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (iteration.present) {
      map['iteration'] = Variable<int>(iteration.value);
    }
    if (slotEntryId.present) {
      map['slot_entry_id'] = Variable<int>(slotEntryId.value);
    }
    if (rir.present) {
      map['rir'] = Variable<double>(rir.value);
    }
    if (rirTarget.present) {
      map['rir_target'] = Variable<double>(rirTarget.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<double>(repetitions.value);
    }
    if (repetitionsTarget.present) {
      map['repetitions_target'] = Variable<double>(repetitionsTarget.value);
    }
    if (repetitionsUnitId.present) {
      map['repetitions_unit_id'] = Variable<int>(repetitionsUnitId.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (weightTarget.present) {
      map['weight_target'] = Variable<double>(weightTarget.value);
    }
    if (weightUnitId.present) {
      map['weight_unit_id'] = Variable<int>(weightUnitId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutLogTableCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('routineId: $routineId, ')
          ..write('sessionId: $sessionId, ')
          ..write('iteration: $iteration, ')
          ..write('slotEntryId: $slotEntryId, ')
          ..write('rir: $rir, ')
          ..write('rirTarget: $rirTarget, ')
          ..write('repetitions: $repetitions, ')
          ..write('repetitionsTarget: $repetitionsTarget, ')
          ..write('repetitionsUnitId: $repetitionsUnitId, ')
          ..write('weight: $weight, ')
          ..write('weightTarget: $weightTarget, ')
          ..write('weightUnitId: $weightUnitId, ')
          ..write('date: $date, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionTableTable extends WorkoutSessionTable
    with TableInfo<$WorkoutSessionTableTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => uuid.v4(),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<int> routineId = GeneratedColumn<int>(
    'routine_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<int> dayId = GeneratedColumn<int>(
    'day_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<int, String> impression = GeneratedColumn<String>(
    'impression',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<int>($WorkoutSessionTableTable.$converterimpression);
  @override
  late final GeneratedColumnWithTypeConverter<TimeOfDay?, String> timeStart =
      GeneratedColumn<String>(
        'time_start',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TimeOfDay?>(
        $WorkoutSessionTableTable.$convertertimeStartn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<TimeOfDay?, String> timeEnd = GeneratedColumn<String>(
    'time_end',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<TimeOfDay?>($WorkoutSessionTableTable.$convertertimeEndn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    dayId,
    date,
    notes,
    impression,
    timeStart,
    timeEnd,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manager_workoutsession';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_id'],
      ),
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_id'],
      ),
      impression: $WorkoutSessionTableTable.$converterimpression.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}impression'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      timeStart: $WorkoutSessionTableTable.$convertertimeStartn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}time_start'],
        ),
      ),
      timeEnd: $WorkoutSessionTableTable.$convertertimeEndn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}time_end'],
        ),
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $WorkoutSessionTableTable createAlias(String alias) {
    return $WorkoutSessionTableTable(attachedDatabase, alias);
  }

  static TypeConverter<int, String> $converterimpression = const IntToStringConverter();
  static TypeConverter<TimeOfDay, String> $convertertimeStart = const TimeOfDayConverter();
  static TypeConverter<TimeOfDay?, String?> $convertertimeStartn = NullAwareTypeConverter.wrap(
    $convertertimeStart,
  );
  static TypeConverter<TimeOfDay, String> $convertertimeEnd = const TimeOfDayConverter();
  static TypeConverter<TimeOfDay?, String?> $convertertimeEndn = NullAwareTypeConverter.wrap(
    $convertertimeEnd,
  );
}

class WorkoutSessionTableCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<String> id;
  final Value<int?> routineId;
  final Value<int?> dayId;
  final Value<DateTime> date;
  final Value<String> notes;
  final Value<int> impression;
  final Value<TimeOfDay?> timeStart;
  final Value<TimeOfDay?> timeEnd;
  final Value<int> rowid;
  const WorkoutSessionTableCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.dayId = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.impression = const Value.absent(),
    this.timeStart = const Value.absent(),
    this.timeEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionTableCompanion.insert({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.dayId = const Value.absent(),
    required DateTime date,
    required String notes,
    required int impression,
    this.timeStart = const Value.absent(),
    this.timeEnd = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       notes = Value(notes),
       impression = Value(impression);
  static Insertable<WorkoutSession> custom({
    Expression<String>? id,
    Expression<int>? routineId,
    Expression<int>? dayId,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? impression,
    Expression<String>? timeStart,
    Expression<String>? timeEnd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (dayId != null) 'day_id': dayId,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (impression != null) 'impression': impression,
      if (timeStart != null) 'time_start': timeStart,
      if (timeEnd != null) 'time_end': timeEnd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionTableCompanion copyWith({
    Value<String>? id,
    Value<int?>? routineId,
    Value<int?>? dayId,
    Value<DateTime>? date,
    Value<String>? notes,
    Value<int>? impression,
    Value<TimeOfDay?>? timeStart,
    Value<TimeOfDay?>? timeEnd,
    Value<int>? rowid,
  }) {
    return WorkoutSessionTableCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      dayId: dayId ?? this.dayId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      impression: impression ?? this.impression,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<int>(routineId.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<int>(dayId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (impression.present) {
      map['impression'] = Variable<String>(
        $WorkoutSessionTableTable.$converterimpression.toSql(impression.value),
      );
    }
    if (timeStart.present) {
      map['time_start'] = Variable<String>(
        $WorkoutSessionTableTable.$convertertimeStartn.toSql(timeStart.value),
      );
    }
    if (timeEnd.present) {
      map['time_end'] = Variable<String>(
        $WorkoutSessionTableTable.$convertertimeEndn.toSql(timeEnd.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionTableCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('dayId: $dayId, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('impression: $impression, ')
          ..write('timeStart: $timeStart, ')
          ..write('timeEnd: $timeEnd, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DriftPowersyncDatabase extends GeneratedDatabase {
  _$DriftPowersyncDatabase(QueryExecutor e) : super(e);
  $DriftPowersyncDatabaseManager get managers => $DriftPowersyncDatabaseManager(this);
  late final $LanguageTableTable languageTable = $LanguageTableTable(this);
  late final $ExerciseCategoryTableTable exerciseCategoryTable = $ExerciseCategoryTableTable(this);
  late final $ExerciseTableTable exerciseTable = $ExerciseTableTable(this);
  late final $ExerciseTranslationTableTable exerciseTranslationTable =
      $ExerciseTranslationTableTable(this);
  late final $MuscleTableTable muscleTable = $MuscleTableTable(this);
  late final $ExerciseMuscleM2NTable exerciseMuscleM2N = $ExerciseMuscleM2NTable(this);
  late final $ExerciseSecondaryMuscleM2NTable exerciseSecondaryMuscleM2N =
      $ExerciseSecondaryMuscleM2NTable(this);
  late final $EquipmentTableTable equipmentTable = $EquipmentTableTable(this);
  late final $ExerciseEquipmentM2NTable exerciseEquipmentM2N = $ExerciseEquipmentM2NTable(this);
  late final $ExerciseImageTableTable exerciseImageTable = $ExerciseImageTableTable(this);
  late final $ExerciseVideoTableTable exerciseVideoTable = $ExerciseVideoTableTable(this);
  late final $WeightEntryTableTable weightEntryTable = $WeightEntryTableTable(
    this,
  );
  late final $MeasurementCategoryTableTable measurementCategoryTable =
      $MeasurementCategoryTableTable(this);
  late final $WorkoutLogTableTable workoutLogTable = $WorkoutLogTableTable(
    this,
  );
  late final $WorkoutSessionTableTable workoutSessionTable = $WorkoutSessionTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    languageTable,
    exerciseCategoryTable,
    exerciseTable,
    exerciseTranslationTable,
    muscleTable,
    exerciseMuscleM2N,
    exerciseSecondaryMuscleM2N,
    equipmentTable,
    exerciseEquipmentM2N,
    exerciseImageTable,
    exerciseVideoTable,
    weightEntryTable,
    measurementCategoryTable,
    workoutLogTable,
    workoutSessionTable,
  ];
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$LanguageTableTableCreateCompanionBuilder =
    LanguageTableCompanion Function({
      required int id,
      required String shortName,
      required String fullName,
      Value<int> rowid,
    });
typedef $$LanguageTableTableUpdateCompanionBuilder =
    LanguageTableCompanion Function({
      Value<int> id,
      Value<String> shortName,
      Value<String> fullName,
      Value<int> rowid,
    });

final class $$LanguageTableTableReferences
    extends BaseReferences<_$DriftPowersyncDatabase, $LanguageTableTable, Language> {
  $$LanguageTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ExerciseTranslationTableTable, List<Translation>>
  _exerciseTranslationTableRefsTable(_$DriftPowersyncDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseTranslationTable,
    aliasName: $_aliasNameGenerator(
      db.languageTable.id,
      db.exerciseTranslationTable.languageId,
    ),
  );

  $$ExerciseTranslationTableTableProcessedTableManager get exerciseTranslationTableRefs {
    final manager = $$ExerciseTranslationTableTableTableManager(
      $_db,
      $_db.exerciseTranslationTable,
    ).filter((f) => f.languageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseTranslationTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LanguageTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $LanguageTableTable> {
  $$LanguageTableTableFilterComposer({
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

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseTranslationTableRefs(
    Expression<bool> Function($$ExerciseTranslationTableTableFilterComposer f) f,
  ) {
    final $$ExerciseTranslationTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseTranslationTable,
      getReferencedColumn: (t) => t.languageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTranslationTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTranslationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LanguageTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $LanguageTableTable> {
  $$LanguageTableTableOrderingComposer({
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

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LanguageTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $LanguageTableTable> {
  $$LanguageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  Expression<T> exerciseTranslationTableRefs<T extends Object>(
    Expression<T> Function($$ExerciseTranslationTableTableAnnotationComposer a) f,
  ) {
    final $$ExerciseTranslationTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseTranslationTable,
      getReferencedColumn: (t) => t.languageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTranslationTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTranslationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LanguageTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $LanguageTableTable,
          Language,
          $$LanguageTableTableFilterComposer,
          $$LanguageTableTableOrderingComposer,
          $$LanguageTableTableAnnotationComposer,
          $$LanguageTableTableCreateCompanionBuilder,
          $$LanguageTableTableUpdateCompanionBuilder,
          (Language, $$LanguageTableTableReferences),
          Language,
          PrefetchHooks Function({bool exerciseTranslationTableRefs})
        > {
  $$LanguageTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $LanguageTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LanguageTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LanguageTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LanguageTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> shortName = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LanguageTableCompanion(
                id: id,
                shortName: shortName,
                fullName: fullName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String shortName,
                required String fullName,
                Value<int> rowid = const Value.absent(),
              }) => LanguageTableCompanion.insert(
                id: id,
                shortName: shortName,
                fullName: fullName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LanguageTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseTranslationTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseTranslationTableRefs) db.exerciseTranslationTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseTranslationTableRefs)
                    await $_getPrefetchedData<Language, $LanguageTableTable, Translation>(
                      currentTable: table,
                      referencedTable: $$LanguageTableTableReferences
                          ._exerciseTranslationTableRefsTable(db),
                      managerFromTypedResult: (p0) => $$LanguageTableTableReferences(
                        db,
                        table,
                        p0,
                      ).exerciseTranslationTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.languageId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LanguageTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $LanguageTableTable,
      Language,
      $$LanguageTableTableFilterComposer,
      $$LanguageTableTableOrderingComposer,
      $$LanguageTableTableAnnotationComposer,
      $$LanguageTableTableCreateCompanionBuilder,
      $$LanguageTableTableUpdateCompanionBuilder,
      (Language, $$LanguageTableTableReferences),
      Language,
      PrefetchHooks Function({bool exerciseTranslationTableRefs})
    >;
typedef $$ExerciseCategoryTableTableCreateCompanionBuilder =
    ExerciseCategoryTableCompanion Function({
      required int id,
      required String name,
      Value<int> rowid,
    });
typedef $$ExerciseCategoryTableTableUpdateCompanionBuilder =
    ExerciseCategoryTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> rowid,
    });

final class $$ExerciseCategoryTableTableReferences
    extends
        BaseReferences<_$DriftPowersyncDatabase, $ExerciseCategoryTableTable, ExerciseCategory> {
  $$ExerciseCategoryTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ExerciseTableTable, List<Exercise>> _exerciseTableRefsTable(
    _$DriftPowersyncDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.exerciseTable,
    aliasName: $_aliasNameGenerator(
      db.exerciseCategoryTable.id,
      db.exerciseTable.categoryId,
    ),
  );

  $$ExerciseTableTableProcessedTableManager get exerciseTableRefs {
    final manager = $$ExerciseTableTableTableManager(
      $_db,
      $_db.exerciseTable,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExerciseCategoryTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseCategoryTableTable> {
  $$ExerciseCategoryTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseTableRefs(
    Expression<bool> Function($$ExerciseTableTableFilterComposer f) f,
  ) {
    final $$ExerciseTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseCategoryTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseCategoryTableTable> {
  $$ExerciseCategoryTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseCategoryTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseCategoryTableTable> {
  $$ExerciseCategoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> exerciseTableRefs<T extends Object>(
    Expression<T> Function($$ExerciseTableTableAnnotationComposer a) f,
  ) {
    final $$ExerciseTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseCategoryTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $ExerciseCategoryTableTable,
          ExerciseCategory,
          $$ExerciseCategoryTableTableFilterComposer,
          $$ExerciseCategoryTableTableOrderingComposer,
          $$ExerciseCategoryTableTableAnnotationComposer,
          $$ExerciseCategoryTableTableCreateCompanionBuilder,
          $$ExerciseCategoryTableTableUpdateCompanionBuilder,
          (ExerciseCategory, $$ExerciseCategoryTableTableReferences),
          ExerciseCategory,
          PrefetchHooks Function({bool exerciseTableRefs})
        > {
  $$ExerciseCategoryTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $ExerciseCategoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExerciseCategoryTableTableFilterComposer(
            $db: db,
            $table: table,
          ),
          createOrderingComposer: () => $$ExerciseCategoryTableTableOrderingComposer(
            $db: db,
            $table: table,
          ),
          createComputedFieldComposer: () => $$ExerciseCategoryTableTableAnnotationComposer(
            $db: db,
            $table: table,
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseCategoryTableCompanion(
                id: id,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseCategoryTableCompanion.insert(
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseCategoryTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseTableRefs) db.exerciseTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseTableRefs)
                    await $_getPrefetchedData<
                      ExerciseCategory,
                      $ExerciseCategoryTableTable,
                      Exercise
                    >(
                      currentTable: table,
                      referencedTable: $$ExerciseCategoryTableTableReferences
                          ._exerciseTableRefsTable(db),
                      managerFromTypedResult: (p0) => $$ExerciseCategoryTableTableReferences(
                        db,
                        table,
                        p0,
                      ).exerciseTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseCategoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $ExerciseCategoryTableTable,
      ExerciseCategory,
      $$ExerciseCategoryTableTableFilterComposer,
      $$ExerciseCategoryTableTableOrderingComposer,
      $$ExerciseCategoryTableTableAnnotationComposer,
      $$ExerciseCategoryTableTableCreateCompanionBuilder,
      $$ExerciseCategoryTableTableUpdateCompanionBuilder,
      (ExerciseCategory, $$ExerciseCategoryTableTableReferences),
      ExerciseCategory,
      PrefetchHooks Function({bool exerciseTableRefs})
    >;
typedef $$ExerciseTableTableCreateCompanionBuilder =
    ExerciseTableCompanion Function({
      required int id,
      required String uuid,
      Value<int?> variationId,
      required int categoryId,
      required DateTime created,
      required DateTime lastUpdate,
      Value<int> rowid,
    });
typedef $$ExerciseTableTableUpdateCompanionBuilder =
    ExerciseTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<int?> variationId,
      Value<int> categoryId,
      Value<DateTime> created,
      Value<DateTime> lastUpdate,
      Value<int> rowid,
    });

final class $$ExerciseTableTableReferences
    extends BaseReferences<_$DriftPowersyncDatabase, $ExerciseTableTable, Exercise> {
  $$ExerciseTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExerciseCategoryTableTable _categoryIdTable(
    _$DriftPowersyncDatabase db,
  ) => db.exerciseCategoryTable.createAlias(
    $_aliasNameGenerator(
      db.exerciseTable.categoryId,
      db.exerciseCategoryTable.id,
    ),
  );

  $$ExerciseCategoryTableTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$ExerciseCategoryTableTableTableManager(
      $_db,
      $_db.exerciseCategoryTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExerciseTranslationTableTable, List<Translation>>
  _exerciseTranslationTableRefsTable(_$DriftPowersyncDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseTranslationTable,
    aliasName: $_aliasNameGenerator(
      db.exerciseTable.id,
      db.exerciseTranslationTable.exerciseId,
    ),
  );

  $$ExerciseTranslationTableTableProcessedTableManager get exerciseTranslationTableRefs {
    final manager = $$ExerciseTranslationTableTableTableManager(
      $_db,
      $_db.exerciseTranslationTable,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseTranslationTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseMuscleM2NTable, List<ExerciseMuscleM2NData>>
  _exerciseMuscleM2NRefsTable(_$DriftPowersyncDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseMuscleM2N,
    aliasName: $_aliasNameGenerator(
      db.exerciseTable.id,
      db.exerciseMuscleM2N.exerciseId,
    ),
  );

  $$ExerciseMuscleM2NTableProcessedTableManager get exerciseMuscleM2NRefs {
    final manager = $$ExerciseMuscleM2NTableTableManager(
      $_db,
      $_db.exerciseMuscleM2N,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseMuscleM2NRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseSecondaryMuscleM2NTable, List<ExerciseSecondaryMuscleM2NData>>
  _exerciseSecondaryMuscleM2NRefsTable(_$DriftPowersyncDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseSecondaryMuscleM2N,
        aliasName: $_aliasNameGenerator(
          db.exerciseTable.id,
          db.exerciseSecondaryMuscleM2N.exerciseId,
        ),
      );

  $$ExerciseSecondaryMuscleM2NTableProcessedTableManager get exerciseSecondaryMuscleM2NRefs {
    final manager = $$ExerciseSecondaryMuscleM2NTableTableManager(
      $_db,
      $_db.exerciseSecondaryMuscleM2N,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseSecondaryMuscleM2NRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseEquipmentM2NTable, List<ExerciseEquipmentM2NData>>
  _exerciseEquipmentM2NRefsTable(_$DriftPowersyncDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseEquipmentM2N,
    aliasName: $_aliasNameGenerator(
      db.exerciseTable.id,
      db.exerciseEquipmentM2N.exerciseId,
    ),
  );

  $$ExerciseEquipmentM2NTableProcessedTableManager get exerciseEquipmentM2NRefs {
    final manager = $$ExerciseEquipmentM2NTableTableManager(
      $_db,
      $_db.exerciseEquipmentM2N,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseEquipmentM2NRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseImageTableTable, List<ExerciseImage>>
  _exerciseImageTableRefsTable(_$DriftPowersyncDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseImageTable,
    aliasName: $_aliasNameGenerator(
      db.exerciseTable.id,
      db.exerciseImageTable.exerciseId,
    ),
  );

  $$ExerciseImageTableTableProcessedTableManager get exerciseImageTableRefs {
    final manager = $$ExerciseImageTableTableTableManager(
      $_db,
      $_db.exerciseImageTable,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseImageTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseVideoTableTable, List<Video>> _exerciseVideoTableRefsTable(
    _$DriftPowersyncDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.exerciseVideoTable,
    aliasName: $_aliasNameGenerator(
      db.exerciseTable.id,
      db.exerciseVideoTable.exerciseId,
    ),
  );

  $$ExerciseVideoTableTableProcessedTableManager get exerciseVideoTableRefs {
    final manager = $$ExerciseVideoTableTableTableManager(
      $_db,
      $_db.exerciseVideoTable,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseVideoTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExerciseTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseTableTable> {
  $$ExerciseTableTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get variationId => $composableBuilder(
    column: $table.variationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdate => $composableBuilder(
    column: $table.lastUpdate,
    builder: (column) => ColumnFilters(column),
  );

  $$ExerciseCategoryTableTableFilterComposer get categoryId {
    final $$ExerciseCategoryTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.exerciseCategoryTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseCategoryTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseCategoryTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseTranslationTableRefs(
    Expression<bool> Function($$ExerciseTranslationTableTableFilterComposer f) f,
  ) {
    final $$ExerciseTranslationTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseTranslationTable,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTranslationTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTranslationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseMuscleM2NRefs(
    Expression<bool> Function($$ExerciseMuscleM2NTableFilterComposer f) f,
  ) {
    final $$ExerciseMuscleM2NTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscleM2N,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMuscleM2NTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscleM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseSecondaryMuscleM2NRefs(
    Expression<bool> Function($$ExerciseSecondaryMuscleM2NTableFilterComposer f) f,
  ) {
    final $$ExerciseSecondaryMuscleM2NTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSecondaryMuscleM2N,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSecondaryMuscleM2NTableFilterComposer(
            $db: $db,
            $table: $db.exerciseSecondaryMuscleM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseEquipmentM2NRefs(
    Expression<bool> Function($$ExerciseEquipmentM2NTableFilterComposer f) f,
  ) {
    final $$ExerciseEquipmentM2NTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseEquipmentM2N,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseEquipmentM2NTableFilterComposer(
            $db: $db,
            $table: $db.exerciseEquipmentM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseImageTableRefs(
    Expression<bool> Function($$ExerciseImageTableTableFilterComposer f) f,
  ) {
    final $$ExerciseImageTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseImageTable,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseImageTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseImageTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseVideoTableRefs(
    Expression<bool> Function($$ExerciseVideoTableTableFilterComposer f) f,
  ) {
    final $$ExerciseVideoTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseVideoTable,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseVideoTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseVideoTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseTableTable> {
  $$ExerciseTableTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get variationId => $composableBuilder(
    column: $table.variationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdate => $composableBuilder(
    column: $table.lastUpdate,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseCategoryTableTableOrderingComposer get categoryId {
    final $$ExerciseCategoryTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.exerciseCategoryTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseCategoryTableTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseCategoryTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseTableTable> {
  $$ExerciseTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get variationId => $composableBuilder(
    column: $table.variationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdate => $composableBuilder(
    column: $table.lastUpdate,
    builder: (column) => column,
  );

  $$ExerciseCategoryTableTableAnnotationComposer get categoryId {
    final $$ExerciseCategoryTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.exerciseCategoryTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseCategoryTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseCategoryTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseTranslationTableRefs<T extends Object>(
    Expression<T> Function($$ExerciseTranslationTableTableAnnotationComposer a) f,
  ) {
    final $$ExerciseTranslationTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseTranslationTable,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTranslationTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTranslationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseMuscleM2NRefs<T extends Object>(
    Expression<T> Function($$ExerciseMuscleM2NTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMuscleM2NTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscleM2N,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMuscleM2NTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseMuscleM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseSecondaryMuscleM2NRefs<T extends Object>(
    Expression<T> Function(
      $$ExerciseSecondaryMuscleM2NTableAnnotationComposer a,
    )
    f,
  ) {
    final $$ExerciseSecondaryMuscleM2NTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSecondaryMuscleM2N,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSecondaryMuscleM2NTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseSecondaryMuscleM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseEquipmentM2NRefs<T extends Object>(
    Expression<T> Function($$ExerciseEquipmentM2NTableAnnotationComposer a) f,
  ) {
    final $$ExerciseEquipmentM2NTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseEquipmentM2N,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseEquipmentM2NTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseEquipmentM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseImageTableRefs<T extends Object>(
    Expression<T> Function($$ExerciseImageTableTableAnnotationComposer a) f,
  ) {
    final $$ExerciseImageTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseImageTable,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseImageTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseImageTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseVideoTableRefs<T extends Object>(
    Expression<T> Function($$ExerciseVideoTableTableAnnotationComposer a) f,
  ) {
    final $$ExerciseVideoTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseVideoTable,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseVideoTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseVideoTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExerciseTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $ExerciseTableTable,
          Exercise,
          $$ExerciseTableTableFilterComposer,
          $$ExerciseTableTableOrderingComposer,
          $$ExerciseTableTableAnnotationComposer,
          $$ExerciseTableTableCreateCompanionBuilder,
          $$ExerciseTableTableUpdateCompanionBuilder,
          (Exercise, $$ExerciseTableTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool categoryId,
            bool exerciseTranslationTableRefs,
            bool exerciseMuscleM2NRefs,
            bool exerciseSecondaryMuscleM2NRefs,
            bool exerciseEquipmentM2NRefs,
            bool exerciseImageTableRefs,
            bool exerciseVideoTableRefs,
          })
        > {
  $$ExerciseTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $ExerciseTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExerciseTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int?> variationId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<DateTime> created = const Value.absent(),
                Value<DateTime> lastUpdate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTableCompanion(
                id: id,
                uuid: uuid,
                variationId: variationId,
                categoryId: categoryId,
                created: created,
                lastUpdate: lastUpdate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String uuid,
                Value<int?> variationId = const Value.absent(),
                required int categoryId,
                required DateTime created,
                required DateTime lastUpdate,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTableCompanion.insert(
                id: id,
                uuid: uuid,
                variationId: variationId,
                categoryId: categoryId,
                created: created,
                lastUpdate: lastUpdate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                exerciseTranslationTableRefs = false,
                exerciseMuscleM2NRefs = false,
                exerciseSecondaryMuscleM2NRefs = false,
                exerciseEquipmentM2NRefs = false,
                exerciseImageTableRefs = false,
                exerciseVideoTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseTranslationTableRefs) db.exerciseTranslationTable,
                    if (exerciseMuscleM2NRefs) db.exerciseMuscleM2N,
                    if (exerciseSecondaryMuscleM2NRefs) db.exerciseSecondaryMuscleM2N,
                    if (exerciseEquipmentM2NRefs) db.exerciseEquipmentM2N,
                    if (exerciseImageTableRefs) db.exerciseImageTable,
                    if (exerciseVideoTableRefs) db.exerciseVideoTable,
                  ],
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
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$ExerciseTableTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$ExerciseTableTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseTranslationTableRefs)
                        await $_getPrefetchedData<Exercise, $ExerciseTableTable, Translation>(
                          currentTable: table,
                          referencedTable: $$ExerciseTableTableReferences
                              ._exerciseTranslationTableRefsTable(db),
                          managerFromTypedResult: (p0) => $$ExerciseTableTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseTranslationTableRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseMuscleM2NRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExerciseTableTable,
                          ExerciseMuscleM2NData
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseTableTableReferences
                              ._exerciseMuscleM2NRefsTable(db),
                          managerFromTypedResult: (p0) => $$ExerciseTableTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseMuscleM2NRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseSecondaryMuscleM2NRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExerciseTableTable,
                          ExerciseSecondaryMuscleM2NData
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseTableTableReferences
                              ._exerciseSecondaryMuscleM2NRefsTable(db),
                          managerFromTypedResult: (p0) => $$ExerciseTableTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseSecondaryMuscleM2NRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseEquipmentM2NRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExerciseTableTable,
                          ExerciseEquipmentM2NData
                        >(
                          currentTable: table,
                          referencedTable: $$ExerciseTableTableReferences
                              ._exerciseEquipmentM2NRefsTable(db),
                          managerFromTypedResult: (p0) => $$ExerciseTableTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseEquipmentM2NRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseImageTableRefs)
                        await $_getPrefetchedData<Exercise, $ExerciseTableTable, ExerciseImage>(
                          currentTable: table,
                          referencedTable: $$ExerciseTableTableReferences
                              ._exerciseImageTableRefsTable(db),
                          managerFromTypedResult: (p0) => $$ExerciseTableTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseImageTableRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseVideoTableRefs)
                        await $_getPrefetchedData<Exercise, $ExerciseTableTable, Video>(
                          currentTable: table,
                          referencedTable: $$ExerciseTableTableReferences
                              ._exerciseVideoTableRefsTable(db),
                          managerFromTypedResult: (p0) => $$ExerciseTableTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseVideoTableRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExerciseTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $ExerciseTableTable,
      Exercise,
      $$ExerciseTableTableFilterComposer,
      $$ExerciseTableTableOrderingComposer,
      $$ExerciseTableTableAnnotationComposer,
      $$ExerciseTableTableCreateCompanionBuilder,
      $$ExerciseTableTableUpdateCompanionBuilder,
      (Exercise, $$ExerciseTableTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool categoryId,
        bool exerciseTranslationTableRefs,
        bool exerciseMuscleM2NRefs,
        bool exerciseSecondaryMuscleM2NRefs,
        bool exerciseEquipmentM2NRefs,
        bool exerciseImageTableRefs,
        bool exerciseVideoTableRefs,
      })
    >;
typedef $$ExerciseTranslationTableTableCreateCompanionBuilder =
    ExerciseTranslationTableCompanion Function({
      required int id,
      required String uuid,
      required int exerciseId,
      required int languageId,
      required String name,
      required String description,
      required DateTime created,
      required DateTime lastUpdate,
      Value<int> rowid,
    });
typedef $$ExerciseTranslationTableTableUpdateCompanionBuilder =
    ExerciseTranslationTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<int> exerciseId,
      Value<int> languageId,
      Value<String> name,
      Value<String> description,
      Value<DateTime> created,
      Value<DateTime> lastUpdate,
      Value<int> rowid,
    });

final class $$ExerciseTranslationTableTableReferences
    extends BaseReferences<_$DriftPowersyncDatabase, $ExerciseTranslationTableTable, Translation> {
  $$ExerciseTranslationTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExerciseTableTable _exerciseIdTable(_$DriftPowersyncDatabase db) =>
      db.exerciseTable.createAlias(
        $_aliasNameGenerator(
          db.exerciseTranslationTable.exerciseId,
          db.exerciseTable.id,
        ),
      );

  $$ExerciseTableTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableTableManager(
      $_db,
      $_db.exerciseTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LanguageTableTable _languageIdTable(_$DriftPowersyncDatabase db) =>
      db.languageTable.createAlias(
        $_aliasNameGenerator(
          db.exerciseTranslationTable.languageId,
          db.languageTable.id,
        ),
      );

  $$LanguageTableTableProcessedTableManager get languageId {
    final $_column = $_itemColumn<int>('language_id')!;

    final manager = $$LanguageTableTableTableManager(
      $_db,
      $_db.languageTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_languageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseTranslationTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseTranslationTableTable> {
  $$ExerciseTranslationTableTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdate => $composableBuilder(
    column: $table.lastUpdate,
    builder: (column) => ColumnFilters(column),
  );

  $$ExerciseTableTableFilterComposer get exerciseId {
    final $$ExerciseTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LanguageTableTableFilterComposer get languageId {
    final $$LanguageTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.languageId,
      referencedTable: $db.languageTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LanguageTableTableFilterComposer(
            $db: $db,
            $table: $db.languageTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseTranslationTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseTranslationTableTable> {
  $$ExerciseTranslationTableTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdate => $composableBuilder(
    column: $table.lastUpdate,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseTableTableOrderingComposer get exerciseId {
    final $$ExerciseTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LanguageTableTableOrderingComposer get languageId {
    final $$LanguageTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.languageId,
      referencedTable: $db.languageTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LanguageTableTableOrderingComposer(
            $db: $db,
            $table: $db.languageTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseTranslationTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseTranslationTableTable> {
  $$ExerciseTranslationTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdate => $composableBuilder(
    column: $table.lastUpdate,
    builder: (column) => column,
  );

  $$ExerciseTableTableAnnotationComposer get exerciseId {
    final $$ExerciseTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LanguageTableTableAnnotationComposer get languageId {
    final $$LanguageTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.languageId,
      referencedTable: $db.languageTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LanguageTableTableAnnotationComposer(
            $db: $db,
            $table: $db.languageTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseTranslationTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $ExerciseTranslationTableTable,
          Translation,
          $$ExerciseTranslationTableTableFilterComposer,
          $$ExerciseTranslationTableTableOrderingComposer,
          $$ExerciseTranslationTableTableAnnotationComposer,
          $$ExerciseTranslationTableTableCreateCompanionBuilder,
          $$ExerciseTranslationTableTableUpdateCompanionBuilder,
          (Translation, $$ExerciseTranslationTableTableReferences),
          Translation,
          PrefetchHooks Function({bool exerciseId, bool languageId})
        > {
  $$ExerciseTranslationTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $ExerciseTranslationTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExerciseTranslationTableTableFilterComposer(
            $db: db,
            $table: table,
          ),
          createOrderingComposer: () => $$ExerciseTranslationTableTableOrderingComposer(
            $db: db,
            $table: table,
          ),
          createComputedFieldComposer: () => $$ExerciseTranslationTableTableAnnotationComposer(
            $db: db,
            $table: table,
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> languageId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> created = const Value.absent(),
                Value<DateTime> lastUpdate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTranslationTableCompanion(
                id: id,
                uuid: uuid,
                exerciseId: exerciseId,
                languageId: languageId,
                name: name,
                description: description,
                created: created,
                lastUpdate: lastUpdate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String uuid,
                required int exerciseId,
                required int languageId,
                required String name,
                required String description,
                required DateTime created,
                required DateTime lastUpdate,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseTranslationTableCompanion.insert(
                id: id,
                uuid: uuid,
                exerciseId: exerciseId,
                languageId: languageId,
                name: name,
                description: description,
                created: created,
                lastUpdate: lastUpdate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseTranslationTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, languageId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$ExerciseTranslationTableTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$ExerciseTranslationTableTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (languageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.languageId,
                                referencedTable: $$ExerciseTranslationTableTableReferences
                                    ._languageIdTable(db),
                                referencedColumn: $$ExerciseTranslationTableTableReferences
                                    ._languageIdTable(db)
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

typedef $$ExerciseTranslationTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $ExerciseTranslationTableTable,
      Translation,
      $$ExerciseTranslationTableTableFilterComposer,
      $$ExerciseTranslationTableTableOrderingComposer,
      $$ExerciseTranslationTableTableAnnotationComposer,
      $$ExerciseTranslationTableTableCreateCompanionBuilder,
      $$ExerciseTranslationTableTableUpdateCompanionBuilder,
      (Translation, $$ExerciseTranslationTableTableReferences),
      Translation,
      PrefetchHooks Function({bool exerciseId, bool languageId})
    >;
typedef $$MuscleTableTableCreateCompanionBuilder =
    MuscleTableCompanion Function({
      required int id,
      required String name,
      required String nameEn,
      required bool isFront,
      Value<int> rowid,
    });
typedef $$MuscleTableTableUpdateCompanionBuilder =
    MuscleTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> nameEn,
      Value<bool> isFront,
      Value<int> rowid,
    });

final class $$MuscleTableTableReferences
    extends BaseReferences<_$DriftPowersyncDatabase, $MuscleTableTable, Muscle> {
  $$MuscleTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseMuscleM2NTable, List<ExerciseMuscleM2NData>>
  _exerciseMuscleM2NRefsTable(_$DriftPowersyncDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseMuscleM2N,
    aliasName: $_aliasNameGenerator(
      db.muscleTable.id,
      db.exerciseMuscleM2N.muscleId,
    ),
  );

  $$ExerciseMuscleM2NTableProcessedTableManager get exerciseMuscleM2NRefs {
    final manager = $$ExerciseMuscleM2NTableTableManager(
      $_db,
      $_db.exerciseMuscleM2N,
    ).filter((f) => f.muscleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseMuscleM2NRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseSecondaryMuscleM2NTable, List<ExerciseSecondaryMuscleM2NData>>
  _exerciseSecondaryMuscleM2NRefsTable(_$DriftPowersyncDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseSecondaryMuscleM2N,
        aliasName: $_aliasNameGenerator(
          db.muscleTable.id,
          db.exerciseSecondaryMuscleM2N.muscleId,
        ),
      );

  $$ExerciseSecondaryMuscleM2NTableProcessedTableManager get exerciseSecondaryMuscleM2NRefs {
    final manager = $$ExerciseSecondaryMuscleM2NTableTableManager(
      $_db,
      $_db.exerciseSecondaryMuscleM2N,
    ).filter((f) => f.muscleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseSecondaryMuscleM2NRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MuscleTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $MuscleTableTable> {
  $$MuscleTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFront => $composableBuilder(
    column: $table.isFront,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseMuscleM2NRefs(
    Expression<bool> Function($$ExerciseMuscleM2NTableFilterComposer f) f,
  ) {
    final $$ExerciseMuscleM2NTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscleM2N,
      getReferencedColumn: (t) => t.muscleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMuscleM2NTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMuscleM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseSecondaryMuscleM2NRefs(
    Expression<bool> Function($$ExerciseSecondaryMuscleM2NTableFilterComposer f) f,
  ) {
    final $$ExerciseSecondaryMuscleM2NTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSecondaryMuscleM2N,
      getReferencedColumn: (t) => t.muscleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSecondaryMuscleM2NTableFilterComposer(
            $db: $db,
            $table: $db.exerciseSecondaryMuscleM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MuscleTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $MuscleTableTable> {
  $$MuscleTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFront => $composableBuilder(
    column: $table.isFront,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MuscleTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $MuscleTableTable> {
  $$MuscleTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<bool> get isFront =>
      $composableBuilder(column: $table.isFront, builder: (column) => column);

  Expression<T> exerciseMuscleM2NRefs<T extends Object>(
    Expression<T> Function($$ExerciseMuscleM2NTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMuscleM2NTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMuscleM2N,
      getReferencedColumn: (t) => t.muscleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMuscleM2NTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseMuscleM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseSecondaryMuscleM2NRefs<T extends Object>(
    Expression<T> Function(
      $$ExerciseSecondaryMuscleM2NTableAnnotationComposer a,
    )
    f,
  ) {
    final $$ExerciseSecondaryMuscleM2NTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseSecondaryMuscleM2N,
      getReferencedColumn: (t) => t.muscleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseSecondaryMuscleM2NTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseSecondaryMuscleM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MuscleTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $MuscleTableTable,
          Muscle,
          $$MuscleTableTableFilterComposer,
          $$MuscleTableTableOrderingComposer,
          $$MuscleTableTableAnnotationComposer,
          $$MuscleTableTableCreateCompanionBuilder,
          $$MuscleTableTableUpdateCompanionBuilder,
          (Muscle, $$MuscleTableTableReferences),
          Muscle,
          PrefetchHooks Function({
            bool exerciseMuscleM2NRefs,
            bool exerciseSecondaryMuscleM2NRefs,
          })
        > {
  $$MuscleTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $MuscleTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MuscleTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MuscleTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MuscleTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<bool> isFront = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MuscleTableCompanion(
                id: id,
                name: name,
                nameEn: nameEn,
                isFront: isFront,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String name,
                required String nameEn,
                required bool isFront,
                Value<int> rowid = const Value.absent(),
              }) => MuscleTableCompanion.insert(
                id: id,
                name: name,
                nameEn: nameEn,
                isFront: isFront,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MuscleTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                exerciseMuscleM2NRefs = false,
                exerciseSecondaryMuscleM2NRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseMuscleM2NRefs) db.exerciseMuscleM2N,
                    if (exerciseSecondaryMuscleM2NRefs) db.exerciseSecondaryMuscleM2N,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseMuscleM2NRefs)
                        await $_getPrefetchedData<Muscle, $MuscleTableTable, ExerciseMuscleM2NData>(
                          currentTable: table,
                          referencedTable: $$MuscleTableTableReferences._exerciseMuscleM2NRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) => $$MuscleTableTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseMuscleM2NRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where(
                                (e) => e.muscleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseSecondaryMuscleM2NRefs)
                        await $_getPrefetchedData<
                          Muscle,
                          $MuscleTableTable,
                          ExerciseSecondaryMuscleM2NData
                        >(
                          currentTable: table,
                          referencedTable: $$MuscleTableTableReferences
                              ._exerciseSecondaryMuscleM2NRefsTable(db),
                          managerFromTypedResult: (p0) => $$MuscleTableTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseSecondaryMuscleM2NRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where(
                                (e) => e.muscleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MuscleTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $MuscleTableTable,
      Muscle,
      $$MuscleTableTableFilterComposer,
      $$MuscleTableTableOrderingComposer,
      $$MuscleTableTableAnnotationComposer,
      $$MuscleTableTableCreateCompanionBuilder,
      $$MuscleTableTableUpdateCompanionBuilder,
      (Muscle, $$MuscleTableTableReferences),
      Muscle,
      PrefetchHooks Function({
        bool exerciseMuscleM2NRefs,
        bool exerciseSecondaryMuscleM2NRefs,
      })
    >;
typedef $$ExerciseMuscleM2NTableCreateCompanionBuilder =
    ExerciseMuscleM2NCompanion Function({
      required int id,
      required int exerciseId,
      required int muscleId,
      Value<int> rowid,
    });
typedef $$ExerciseMuscleM2NTableUpdateCompanionBuilder =
    ExerciseMuscleM2NCompanion Function({
      Value<int> id,
      Value<int> exerciseId,
      Value<int> muscleId,
      Value<int> rowid,
    });

final class $$ExerciseMuscleM2NTableReferences
    extends
        BaseReferences<_$DriftPowersyncDatabase, $ExerciseMuscleM2NTable, ExerciseMuscleM2NData> {
  $$ExerciseMuscleM2NTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExerciseTableTable _exerciseIdTable(_$DriftPowersyncDatabase db) =>
      db.exerciseTable.createAlias(
        $_aliasNameGenerator(
          db.exerciseMuscleM2N.exerciseId,
          db.exerciseTable.id,
        ),
      );

  $$ExerciseTableTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableTableManager(
      $_db,
      $_db.exerciseTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MuscleTableTable _muscleIdTable(_$DriftPowersyncDatabase db) =>
      db.muscleTable.createAlias(
        $_aliasNameGenerator(db.exerciseMuscleM2N.muscleId, db.muscleTable.id),
      );

  $$MuscleTableTableProcessedTableManager get muscleId {
    final $_column = $_itemColumn<int>('muscle_id')!;

    final manager = $$MuscleTableTableTableManager(
      $_db,
      $_db.muscleTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_muscleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseMuscleM2NTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseMuscleM2NTable> {
  $$ExerciseMuscleM2NTableFilterComposer({
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

  $$ExerciseTableTableFilterComposer get exerciseId {
    final $$ExerciseTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleTableTableFilterComposer get muscleId {
    final $$MuscleTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscleTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleTableTableFilterComposer(
            $db: $db,
            $table: $db.muscleTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMuscleM2NTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseMuscleM2NTable> {
  $$ExerciseMuscleM2NTableOrderingComposer({
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

  $$ExerciseTableTableOrderingComposer get exerciseId {
    final $$ExerciseTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleTableTableOrderingComposer get muscleId {
    final $$MuscleTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscleTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleTableTableOrderingComposer(
            $db: $db,
            $table: $db.muscleTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMuscleM2NTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseMuscleM2NTable> {
  $$ExerciseMuscleM2NTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  $$ExerciseTableTableAnnotationComposer get exerciseId {
    final $$ExerciseTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleTableTableAnnotationComposer get muscleId {
    final $$MuscleTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscleTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleTableTableAnnotationComposer(
            $db: $db,
            $table: $db.muscleTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMuscleM2NTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $ExerciseMuscleM2NTable,
          ExerciseMuscleM2NData,
          $$ExerciseMuscleM2NTableFilterComposer,
          $$ExerciseMuscleM2NTableOrderingComposer,
          $$ExerciseMuscleM2NTableAnnotationComposer,
          $$ExerciseMuscleM2NTableCreateCompanionBuilder,
          $$ExerciseMuscleM2NTableUpdateCompanionBuilder,
          (ExerciseMuscleM2NData, $$ExerciseMuscleM2NTableReferences),
          ExerciseMuscleM2NData,
          PrefetchHooks Function({bool exerciseId, bool muscleId})
        > {
  $$ExerciseMuscleM2NTableTableManager(
    _$DriftPowersyncDatabase db,
    $ExerciseMuscleM2NTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseMuscleM2NTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseMuscleM2NTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExerciseMuscleM2NTableAnnotationComposer(
            $db: db,
            $table: table,
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> muscleId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMuscleM2NCompanion(
                id: id,
                exerciseId: exerciseId,
                muscleId: muscleId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required int exerciseId,
                required int muscleId,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMuscleM2NCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                muscleId: muscleId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseMuscleM2NTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, muscleId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$ExerciseMuscleM2NTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$ExerciseMuscleM2NTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (muscleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.muscleId,
                                referencedTable: $$ExerciseMuscleM2NTableReferences._muscleIdTable(
                                  db,
                                ),
                                referencedColumn: $$ExerciseMuscleM2NTableReferences
                                    ._muscleIdTable(db)
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

typedef $$ExerciseMuscleM2NTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $ExerciseMuscleM2NTable,
      ExerciseMuscleM2NData,
      $$ExerciseMuscleM2NTableFilterComposer,
      $$ExerciseMuscleM2NTableOrderingComposer,
      $$ExerciseMuscleM2NTableAnnotationComposer,
      $$ExerciseMuscleM2NTableCreateCompanionBuilder,
      $$ExerciseMuscleM2NTableUpdateCompanionBuilder,
      (ExerciseMuscleM2NData, $$ExerciseMuscleM2NTableReferences),
      ExerciseMuscleM2NData,
      PrefetchHooks Function({bool exerciseId, bool muscleId})
    >;
typedef $$ExerciseSecondaryMuscleM2NTableCreateCompanionBuilder =
    ExerciseSecondaryMuscleM2NCompanion Function({
      required int id,
      required int exerciseId,
      required int muscleId,
      Value<int> rowid,
    });
typedef $$ExerciseSecondaryMuscleM2NTableUpdateCompanionBuilder =
    ExerciseSecondaryMuscleM2NCompanion Function({
      Value<int> id,
      Value<int> exerciseId,
      Value<int> muscleId,
      Value<int> rowid,
    });

final class $$ExerciseSecondaryMuscleM2NTableReferences
    extends
        BaseReferences<
          _$DriftPowersyncDatabase,
          $ExerciseSecondaryMuscleM2NTable,
          ExerciseSecondaryMuscleM2NData
        > {
  $$ExerciseSecondaryMuscleM2NTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExerciseTableTable _exerciseIdTable(_$DriftPowersyncDatabase db) =>
      db.exerciseTable.createAlias(
        $_aliasNameGenerator(
          db.exerciseSecondaryMuscleM2N.exerciseId,
          db.exerciseTable.id,
        ),
      );

  $$ExerciseTableTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableTableManager(
      $_db,
      $_db.exerciseTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MuscleTableTable _muscleIdTable(_$DriftPowersyncDatabase db) =>
      db.muscleTable.createAlias(
        $_aliasNameGenerator(
          db.exerciseSecondaryMuscleM2N.muscleId,
          db.muscleTable.id,
        ),
      );

  $$MuscleTableTableProcessedTableManager get muscleId {
    final $_column = $_itemColumn<int>('muscle_id')!;

    final manager = $$MuscleTableTableTableManager(
      $_db,
      $_db.muscleTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_muscleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseSecondaryMuscleM2NTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseSecondaryMuscleM2NTable> {
  $$ExerciseSecondaryMuscleM2NTableFilterComposer({
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

  $$ExerciseTableTableFilterComposer get exerciseId {
    final $$ExerciseTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleTableTableFilterComposer get muscleId {
    final $$MuscleTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscleTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleTableTableFilterComposer(
            $db: $db,
            $table: $db.muscleTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSecondaryMuscleM2NTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseSecondaryMuscleM2NTable> {
  $$ExerciseSecondaryMuscleM2NTableOrderingComposer({
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

  $$ExerciseTableTableOrderingComposer get exerciseId {
    final $$ExerciseTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleTableTableOrderingComposer get muscleId {
    final $$MuscleTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscleTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleTableTableOrderingComposer(
            $db: $db,
            $table: $db.muscleTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSecondaryMuscleM2NTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseSecondaryMuscleM2NTable> {
  $$ExerciseSecondaryMuscleM2NTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  $$ExerciseTableTableAnnotationComposer get exerciseId {
    final $$ExerciseTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MuscleTableTableAnnotationComposer get muscleId {
    final $$MuscleTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.muscleId,
      referencedTable: $db.muscleTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MuscleTableTableAnnotationComposer(
            $db: $db,
            $table: $db.muscleTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseSecondaryMuscleM2NTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $ExerciseSecondaryMuscleM2NTable,
          ExerciseSecondaryMuscleM2NData,
          $$ExerciseSecondaryMuscleM2NTableFilterComposer,
          $$ExerciseSecondaryMuscleM2NTableOrderingComposer,
          $$ExerciseSecondaryMuscleM2NTableAnnotationComposer,
          $$ExerciseSecondaryMuscleM2NTableCreateCompanionBuilder,
          $$ExerciseSecondaryMuscleM2NTableUpdateCompanionBuilder,
          (ExerciseSecondaryMuscleM2NData, $$ExerciseSecondaryMuscleM2NTableReferences),
          ExerciseSecondaryMuscleM2NData,
          PrefetchHooks Function({bool exerciseId, bool muscleId})
        > {
  $$ExerciseSecondaryMuscleM2NTableTableManager(
    _$DriftPowersyncDatabase db,
    $ExerciseSecondaryMuscleM2NTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ExerciseSecondaryMuscleM2NTableFilterComposer(
            $db: db,
            $table: table,
          ),
          createOrderingComposer: () => $$ExerciseSecondaryMuscleM2NTableOrderingComposer(
            $db: db,
            $table: table,
          ),
          createComputedFieldComposer: () => $$ExerciseSecondaryMuscleM2NTableAnnotationComposer(
            $db: db,
            $table: table,
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> muscleId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseSecondaryMuscleM2NCompanion(
                id: id,
                exerciseId: exerciseId,
                muscleId: muscleId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required int exerciseId,
                required int muscleId,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseSecondaryMuscleM2NCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                muscleId: muscleId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseSecondaryMuscleM2NTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, muscleId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$ExerciseSecondaryMuscleM2NTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$ExerciseSecondaryMuscleM2NTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (muscleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.muscleId,
                                referencedTable: $$ExerciseSecondaryMuscleM2NTableReferences
                                    ._muscleIdTable(db),
                                referencedColumn: $$ExerciseSecondaryMuscleM2NTableReferences
                                    ._muscleIdTable(db)
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

typedef $$ExerciseSecondaryMuscleM2NTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $ExerciseSecondaryMuscleM2NTable,
      ExerciseSecondaryMuscleM2NData,
      $$ExerciseSecondaryMuscleM2NTableFilterComposer,
      $$ExerciseSecondaryMuscleM2NTableOrderingComposer,
      $$ExerciseSecondaryMuscleM2NTableAnnotationComposer,
      $$ExerciseSecondaryMuscleM2NTableCreateCompanionBuilder,
      $$ExerciseSecondaryMuscleM2NTableUpdateCompanionBuilder,
      (ExerciseSecondaryMuscleM2NData, $$ExerciseSecondaryMuscleM2NTableReferences),
      ExerciseSecondaryMuscleM2NData,
      PrefetchHooks Function({bool exerciseId, bool muscleId})
    >;
typedef $$EquipmentTableTableCreateCompanionBuilder =
    EquipmentTableCompanion Function({
      required int id,
      required String name,
      Value<int> rowid,
    });
typedef $$EquipmentTableTableUpdateCompanionBuilder =
    EquipmentTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> rowid,
    });

final class $$EquipmentTableTableReferences
    extends BaseReferences<_$DriftPowersyncDatabase, $EquipmentTableTable, Equipment> {
  $$EquipmentTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ExerciseEquipmentM2NTable, List<ExerciseEquipmentM2NData>>
  _exerciseEquipmentM2NRefsTable(_$DriftPowersyncDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseEquipmentM2N,
    aliasName: $_aliasNameGenerator(
      db.equipmentTable.id,
      db.exerciseEquipmentM2N.equipmentId,
    ),
  );

  $$ExerciseEquipmentM2NTableProcessedTableManager get exerciseEquipmentM2NRefs {
    final manager = $$ExerciseEquipmentM2NTableTableManager(
      $_db,
      $_db.exerciseEquipmentM2N,
    ).filter((f) => f.equipmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseEquipmentM2NRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EquipmentTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $EquipmentTableTable> {
  $$EquipmentTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseEquipmentM2NRefs(
    Expression<bool> Function($$ExerciseEquipmentM2NTableFilterComposer f) f,
  ) {
    final $$ExerciseEquipmentM2NTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseEquipmentM2N,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseEquipmentM2NTableFilterComposer(
            $db: $db,
            $table: $db.exerciseEquipmentM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EquipmentTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $EquipmentTableTable> {
  $$EquipmentTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EquipmentTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $EquipmentTableTable> {
  $$EquipmentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> exerciseEquipmentM2NRefs<T extends Object>(
    Expression<T> Function($$ExerciseEquipmentM2NTableAnnotationComposer a) f,
  ) {
    final $$ExerciseEquipmentM2NTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseEquipmentM2N,
      getReferencedColumn: (t) => t.equipmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseEquipmentM2NTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseEquipmentM2N,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EquipmentTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $EquipmentTableTable,
          Equipment,
          $$EquipmentTableTableFilterComposer,
          $$EquipmentTableTableOrderingComposer,
          $$EquipmentTableTableAnnotationComposer,
          $$EquipmentTableTableCreateCompanionBuilder,
          $$EquipmentTableTableUpdateCompanionBuilder,
          (Equipment, $$EquipmentTableTableReferences),
          Equipment,
          PrefetchHooks Function({bool exerciseEquipmentM2NRefs})
        > {
  $$EquipmentTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $EquipmentTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EquipmentTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EquipmentTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EquipmentTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EquipmentTableCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required int id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => EquipmentTableCompanion.insert(
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EquipmentTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseEquipmentM2NRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseEquipmentM2NRefs) db.exerciseEquipmentM2N,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseEquipmentM2NRefs)
                    await $_getPrefetchedData<
                      Equipment,
                      $EquipmentTableTable,
                      ExerciseEquipmentM2NData
                    >(
                      currentTable: table,
                      referencedTable: $$EquipmentTableTableReferences
                          ._exerciseEquipmentM2NRefsTable(db),
                      managerFromTypedResult: (p0) => $$EquipmentTableTableReferences(
                        db,
                        table,
                        p0,
                      ).exerciseEquipmentM2NRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.equipmentId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EquipmentTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $EquipmentTableTable,
      Equipment,
      $$EquipmentTableTableFilterComposer,
      $$EquipmentTableTableOrderingComposer,
      $$EquipmentTableTableAnnotationComposer,
      $$EquipmentTableTableCreateCompanionBuilder,
      $$EquipmentTableTableUpdateCompanionBuilder,
      (Equipment, $$EquipmentTableTableReferences),
      Equipment,
      PrefetchHooks Function({bool exerciseEquipmentM2NRefs})
    >;
typedef $$ExerciseEquipmentM2NTableCreateCompanionBuilder =
    ExerciseEquipmentM2NCompanion Function({
      required int id,
      required int exerciseId,
      required int equipmentId,
      Value<int> rowid,
    });
typedef $$ExerciseEquipmentM2NTableUpdateCompanionBuilder =
    ExerciseEquipmentM2NCompanion Function({
      Value<int> id,
      Value<int> exerciseId,
      Value<int> equipmentId,
      Value<int> rowid,
    });

final class $$ExerciseEquipmentM2NTableReferences
    extends
        BaseReferences<
          _$DriftPowersyncDatabase,
          $ExerciseEquipmentM2NTable,
          ExerciseEquipmentM2NData
        > {
  $$ExerciseEquipmentM2NTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExerciseTableTable _exerciseIdTable(_$DriftPowersyncDatabase db) =>
      db.exerciseTable.createAlias(
        $_aliasNameGenerator(
          db.exerciseEquipmentM2N.exerciseId,
          db.exerciseTable.id,
        ),
      );

  $$ExerciseTableTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableTableManager(
      $_db,
      $_db.exerciseTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EquipmentTableTable _equipmentIdTable(_$DriftPowersyncDatabase db) =>
      db.equipmentTable.createAlias(
        $_aliasNameGenerator(
          db.exerciseEquipmentM2N.equipmentId,
          db.equipmentTable.id,
        ),
      );

  $$EquipmentTableTableProcessedTableManager get equipmentId {
    final $_column = $_itemColumn<int>('equipment_id')!;

    final manager = $$EquipmentTableTableTableManager(
      $_db,
      $_db.equipmentTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseEquipmentM2NTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseEquipmentM2NTable> {
  $$ExerciseEquipmentM2NTableFilterComposer({
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

  $$ExerciseTableTableFilterComposer get exerciseId {
    final $$ExerciseTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableTableFilterComposer get equipmentId {
    final $$EquipmentTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipmentTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableTableFilterComposer(
            $db: $db,
            $table: $db.equipmentTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseEquipmentM2NTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseEquipmentM2NTable> {
  $$ExerciseEquipmentM2NTableOrderingComposer({
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

  $$ExerciseTableTableOrderingComposer get exerciseId {
    final $$ExerciseTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableTableOrderingComposer get equipmentId {
    final $$EquipmentTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipmentTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableTableOrderingComposer(
            $db: $db,
            $table: $db.equipmentTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseEquipmentM2NTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseEquipmentM2NTable> {
  $$ExerciseEquipmentM2NTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  $$ExerciseTableTableAnnotationComposer get exerciseId {
    final $$ExerciseTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EquipmentTableTableAnnotationComposer get equipmentId {
    final $$EquipmentTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.equipmentId,
      referencedTable: $db.equipmentTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EquipmentTableTableAnnotationComposer(
            $db: $db,
            $table: $db.equipmentTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseEquipmentM2NTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $ExerciseEquipmentM2NTable,
          ExerciseEquipmentM2NData,
          $$ExerciseEquipmentM2NTableFilterComposer,
          $$ExerciseEquipmentM2NTableOrderingComposer,
          $$ExerciseEquipmentM2NTableAnnotationComposer,
          $$ExerciseEquipmentM2NTableCreateCompanionBuilder,
          $$ExerciseEquipmentM2NTableUpdateCompanionBuilder,
          (ExerciseEquipmentM2NData, $$ExerciseEquipmentM2NTableReferences),
          ExerciseEquipmentM2NData,
          PrefetchHooks Function({bool exerciseId, bool equipmentId})
        > {
  $$ExerciseEquipmentM2NTableTableManager(
    _$DriftPowersyncDatabase db,
    $ExerciseEquipmentM2NTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseEquipmentM2NTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ExerciseEquipmentM2NTableOrderingComposer(
            $db: db,
            $table: table,
          ),
          createComputedFieldComposer: () => $$ExerciseEquipmentM2NTableAnnotationComposer(
            $db: db,
            $table: table,
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> equipmentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEquipmentM2NCompanion(
                id: id,
                exerciseId: exerciseId,
                equipmentId: equipmentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required int exerciseId,
                required int equipmentId,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseEquipmentM2NCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                equipmentId: equipmentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseEquipmentM2NTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, equipmentId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$ExerciseEquipmentM2NTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$ExerciseEquipmentM2NTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (equipmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.equipmentId,
                                referencedTable: $$ExerciseEquipmentM2NTableReferences
                                    ._equipmentIdTable(db),
                                referencedColumn: $$ExerciseEquipmentM2NTableReferences
                                    ._equipmentIdTable(db)
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

typedef $$ExerciseEquipmentM2NTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $ExerciseEquipmentM2NTable,
      ExerciseEquipmentM2NData,
      $$ExerciseEquipmentM2NTableFilterComposer,
      $$ExerciseEquipmentM2NTableOrderingComposer,
      $$ExerciseEquipmentM2NTableAnnotationComposer,
      $$ExerciseEquipmentM2NTableCreateCompanionBuilder,
      $$ExerciseEquipmentM2NTableUpdateCompanionBuilder,
      (ExerciseEquipmentM2NData, $$ExerciseEquipmentM2NTableReferences),
      ExerciseEquipmentM2NData,
      PrefetchHooks Function({bool exerciseId, bool equipmentId})
    >;
typedef $$ExerciseImageTableTableCreateCompanionBuilder =
    ExerciseImageTableCompanion Function({
      required int id,
      required String uuid,
      required int exerciseId,
      required String url,
      required bool isMain,
      Value<int> rowid,
    });
typedef $$ExerciseImageTableTableUpdateCompanionBuilder =
    ExerciseImageTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<int> exerciseId,
      Value<String> url,
      Value<bool> isMain,
      Value<int> rowid,
    });

final class $$ExerciseImageTableTableReferences
    extends BaseReferences<_$DriftPowersyncDatabase, $ExerciseImageTableTable, ExerciseImage> {
  $$ExerciseImageTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExerciseTableTable _exerciseIdTable(_$DriftPowersyncDatabase db) =>
      db.exerciseTable.createAlias(
        $_aliasNameGenerator(
          db.exerciseImageTable.exerciseId,
          db.exerciseTable.id,
        ),
      );

  $$ExerciseTableTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableTableManager(
      $_db,
      $_db.exerciseTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseImageTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseImageTableTable> {
  $$ExerciseImageTableTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMain => $composableBuilder(
    column: $table.isMain,
    builder: (column) => ColumnFilters(column),
  );

  $$ExerciseTableTableFilterComposer get exerciseId {
    final $$ExerciseTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseImageTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseImageTableTable> {
  $$ExerciseImageTableTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMain => $composableBuilder(
    column: $table.isMain,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseTableTableOrderingComposer get exerciseId {
    final $$ExerciseTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseImageTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseImageTableTable> {
  $$ExerciseImageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<bool> get isMain =>
      $composableBuilder(column: $table.isMain, builder: (column) => column);

  $$ExerciseTableTableAnnotationComposer get exerciseId {
    final $$ExerciseTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseImageTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $ExerciseImageTableTable,
          ExerciseImage,
          $$ExerciseImageTableTableFilterComposer,
          $$ExerciseImageTableTableOrderingComposer,
          $$ExerciseImageTableTableAnnotationComposer,
          $$ExerciseImageTableTableCreateCompanionBuilder,
          $$ExerciseImageTableTableUpdateCompanionBuilder,
          (ExerciseImage, $$ExerciseImageTableTableReferences),
          ExerciseImage,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ExerciseImageTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $ExerciseImageTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseImageTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseImageTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExerciseImageTableTableAnnotationComposer(
            $db: db,
            $table: table,
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<bool> isMain = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseImageTableCompanion(
                id: id,
                uuid: uuid,
                exerciseId: exerciseId,
                url: url,
                isMain: isMain,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String uuid,
                required int exerciseId,
                required String url,
                required bool isMain,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseImageTableCompanion.insert(
                id: id,
                uuid: uuid,
                exerciseId: exerciseId,
                url: url,
                isMain: isMain,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseImageTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$ExerciseImageTableTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$ExerciseImageTableTableReferences
                                    ._exerciseIdTable(db)
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

typedef $$ExerciseImageTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $ExerciseImageTableTable,
      ExerciseImage,
      $$ExerciseImageTableTableFilterComposer,
      $$ExerciseImageTableTableOrderingComposer,
      $$ExerciseImageTableTableAnnotationComposer,
      $$ExerciseImageTableTableCreateCompanionBuilder,
      $$ExerciseImageTableTableUpdateCompanionBuilder,
      (ExerciseImage, $$ExerciseImageTableTableReferences),
      ExerciseImage,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$ExerciseVideoTableTableCreateCompanionBuilder =
    ExerciseVideoTableCompanion Function({
      required int id,
      required String uuid,
      required int exerciseId,
      required String url,
      required int size,
      required int duration,
      required int width,
      required int height,
      required String codec,
      required String codecLong,
      required int licenseId,
      required String licenseAuthor,
      Value<int> rowid,
    });
typedef $$ExerciseVideoTableTableUpdateCompanionBuilder =
    ExerciseVideoTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<int> exerciseId,
      Value<String> url,
      Value<int> size,
      Value<int> duration,
      Value<int> width,
      Value<int> height,
      Value<String> codec,
      Value<String> codecLong,
      Value<int> licenseId,
      Value<String> licenseAuthor,
      Value<int> rowid,
    });

final class $$ExerciseVideoTableTableReferences
    extends BaseReferences<_$DriftPowersyncDatabase, $ExerciseVideoTableTable, Video> {
  $$ExerciseVideoTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExerciseTableTable _exerciseIdTable(_$DriftPowersyncDatabase db) =>
      db.exerciseTable.createAlias(
        $_aliasNameGenerator(
          db.exerciseVideoTable.exerciseId,
          db.exerciseTable.id,
        ),
      );

  $$ExerciseTableTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExerciseTableTableTableManager(
      $_db,
      $_db.exerciseTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseVideoTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseVideoTableTable> {
  $$ExerciseVideoTableTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codec => $composableBuilder(
    column: $table.codec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codecLong => $composableBuilder(
    column: $table.codecLong,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get licenseId => $composableBuilder(
    column: $table.licenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseAuthor => $composableBuilder(
    column: $table.licenseAuthor,
    builder: (column) => ColumnFilters(column),
  );

  $$ExerciseTableTableFilterComposer get exerciseId {
    final $$ExerciseTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableFilterComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseVideoTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseVideoTableTable> {
  $$ExerciseVideoTableTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codec => $composableBuilder(
    column: $table.codec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codecLong => $composableBuilder(
    column: $table.codecLong,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get licenseId => $composableBuilder(
    column: $table.licenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseAuthor => $composableBuilder(
    column: $table.licenseAuthor,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExerciseTableTableOrderingComposer get exerciseId {
    final $$ExerciseTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableOrderingComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseVideoTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $ExerciseVideoTableTable> {
  $$ExerciseVideoTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get codec =>
      $composableBuilder(column: $table.codec, builder: (column) => column);

  GeneratedColumn<String> get codecLong =>
      $composableBuilder(column: $table.codecLong, builder: (column) => column);

  GeneratedColumn<int> get licenseId =>
      $composableBuilder(column: $table.licenseId, builder: (column) => column);

  GeneratedColumn<String> get licenseAuthor => $composableBuilder(
    column: $table.licenseAuthor,
    builder: (column) => column,
  );

  $$ExerciseTableTableAnnotationComposer get exerciseId {
    final $$ExerciseTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exerciseTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseTableTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseVideoTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $ExerciseVideoTableTable,
          Video,
          $$ExerciseVideoTableTableFilterComposer,
          $$ExerciseVideoTableTableOrderingComposer,
          $$ExerciseVideoTableTableAnnotationComposer,
          $$ExerciseVideoTableTableCreateCompanionBuilder,
          $$ExerciseVideoTableTableUpdateCompanionBuilder,
          (Video, $$ExerciseVideoTableTableReferences),
          Video,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ExerciseVideoTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $ExerciseVideoTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseVideoTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseVideoTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ExerciseVideoTableTableAnnotationComposer(
            $db: db,
            $table: table,
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<String> codec = const Value.absent(),
                Value<String> codecLong = const Value.absent(),
                Value<int> licenseId = const Value.absent(),
                Value<String> licenseAuthor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseVideoTableCompanion(
                id: id,
                uuid: uuid,
                exerciseId: exerciseId,
                url: url,
                size: size,
                duration: duration,
                width: width,
                height: height,
                codec: codec,
                codecLong: codecLong,
                licenseId: licenseId,
                licenseAuthor: licenseAuthor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String uuid,
                required int exerciseId,
                required String url,
                required int size,
                required int duration,
                required int width,
                required int height,
                required String codec,
                required String codecLong,
                required int licenseId,
                required String licenseAuthor,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseVideoTableCompanion.insert(
                id: id,
                uuid: uuid,
                exerciseId: exerciseId,
                url: url,
                size: size,
                duration: duration,
                width: width,
                height: height,
                codec: codec,
                codecLong: codecLong,
                licenseId: licenseId,
                licenseAuthor: licenseAuthor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseVideoTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$ExerciseVideoTableTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$ExerciseVideoTableTableReferences
                                    ._exerciseIdTable(db)
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

typedef $$ExerciseVideoTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $ExerciseVideoTableTable,
      Video,
      $$ExerciseVideoTableTableFilterComposer,
      $$ExerciseVideoTableTableOrderingComposer,
      $$ExerciseVideoTableTableAnnotationComposer,
      $$ExerciseVideoTableTableCreateCompanionBuilder,
      $$ExerciseVideoTableTableUpdateCompanionBuilder,
      (Video, $$ExerciseVideoTableTableReferences),
      Video,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$WeightEntryTableTableCreateCompanionBuilder =
    WeightEntryTableCompanion Function({
      Value<String> id,
      required double weight,
      Value<DateTime?> date,
      Value<int> rowid,
    });
typedef $$WeightEntryTableTableUpdateCompanionBuilder =
    WeightEntryTableCompanion Function({
      Value<String> id,
      Value<double> weight,
      Value<DateTime?> date,
      Value<int> rowid,
    });

class $$WeightEntryTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $WeightEntryTableTable> {
  $$WeightEntryTableTableFilterComposer({
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

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightEntryTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $WeightEntryTableTable> {
  $$WeightEntryTableTableOrderingComposer({
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

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightEntryTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $WeightEntryTableTable> {
  $$WeightEntryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$WeightEntryTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $WeightEntryTableTable,
          WeightEntry,
          $$WeightEntryTableTableFilterComposer,
          $$WeightEntryTableTableOrderingComposer,
          $$WeightEntryTableTableAnnotationComposer,
          $$WeightEntryTableTableCreateCompanionBuilder,
          $$WeightEntryTableTableUpdateCompanionBuilder,
          (
            WeightEntry,
            BaseReferences<_$DriftPowersyncDatabase, $WeightEntryTableTable, WeightEntry>,
          ),
          WeightEntry,
          PrefetchHooks Function()
        > {
  $$WeightEntryTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $WeightEntryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightEntryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightEntryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightEntryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightEntryTableCompanion(
                id: id,
                weight: weight,
                date: date,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required double weight,
                Value<DateTime?> date = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightEntryTableCompanion.insert(
                id: id,
                weight: weight,
                date: date,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightEntryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $WeightEntryTableTable,
      WeightEntry,
      $$WeightEntryTableTableFilterComposer,
      $$WeightEntryTableTableOrderingComposer,
      $$WeightEntryTableTableAnnotationComposer,
      $$WeightEntryTableTableCreateCompanionBuilder,
      $$WeightEntryTableTableUpdateCompanionBuilder,
      (WeightEntry, BaseReferences<_$DriftPowersyncDatabase, $WeightEntryTableTable, WeightEntry>),
      WeightEntry,
      PrefetchHooks Function()
    >;
typedef $$MeasurementCategoryTableTableCreateCompanionBuilder =
    MeasurementCategoryTableCompanion Function({
      required int id,
      required String name,
      required String unit,
      Value<int> rowid,
    });
typedef $$MeasurementCategoryTableTableUpdateCompanionBuilder =
    MeasurementCategoryTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> unit,
      Value<int> rowid,
    });

class $$MeasurementCategoryTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $MeasurementCategoryTableTable> {
  $$MeasurementCategoryTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MeasurementCategoryTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $MeasurementCategoryTableTable> {
  $$MeasurementCategoryTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementCategoryTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $MeasurementCategoryTableTable> {
  $$MeasurementCategoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);
}

class $$MeasurementCategoryTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $MeasurementCategoryTableTable,
          MeasurementCategory,
          $$MeasurementCategoryTableTableFilterComposer,
          $$MeasurementCategoryTableTableOrderingComposer,
          $$MeasurementCategoryTableTableAnnotationComposer,
          $$MeasurementCategoryTableTableCreateCompanionBuilder,
          $$MeasurementCategoryTableTableUpdateCompanionBuilder,
          (
            MeasurementCategory,
            BaseReferences<
              _$DriftPowersyncDatabase,
              $MeasurementCategoryTableTable,
              MeasurementCategory
            >,
          ),
          MeasurementCategory,
          PrefetchHooks Function()
        > {
  $$MeasurementCategoryTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $MeasurementCategoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MeasurementCategoryTableTableFilterComposer(
            $db: db,
            $table: table,
          ),
          createOrderingComposer: () => $$MeasurementCategoryTableTableOrderingComposer(
            $db: db,
            $table: table,
          ),
          createComputedFieldComposer: () => $$MeasurementCategoryTableTableAnnotationComposer(
            $db: db,
            $table: table,
          ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementCategoryTableCompanion(
                id: id,
                name: name,
                unit: unit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String name,
                required String unit,
                Value<int> rowid = const Value.absent(),
              }) => MeasurementCategoryTableCompanion.insert(
                id: id,
                name: name,
                unit: unit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeasurementCategoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $MeasurementCategoryTableTable,
      MeasurementCategory,
      $$MeasurementCategoryTableTableFilterComposer,
      $$MeasurementCategoryTableTableOrderingComposer,
      $$MeasurementCategoryTableTableAnnotationComposer,
      $$MeasurementCategoryTableTableCreateCompanionBuilder,
      $$MeasurementCategoryTableTableUpdateCompanionBuilder,
      (
        MeasurementCategory,
        BaseReferences<
          _$DriftPowersyncDatabase,
          $MeasurementCategoryTableTable,
          MeasurementCategory
        >,
      ),
      MeasurementCategory,
      PrefetchHooks Function()
    >;
typedef $$WorkoutLogTableTableCreateCompanionBuilder =
    WorkoutLogTableCompanion Function({
      Value<String> id,
      required int exerciseId,
      required int routineId,
      Value<int?> sessionId,
      Value<int?> iteration,
      Value<int?> slotEntryId,
      Value<double?> rir,
      Value<double?> rirTarget,
      Value<double?> repetitions,
      Value<double?> repetitionsTarget,
      Value<int?> repetitionsUnitId,
      Value<double?> weight,
      Value<double?> weightTarget,
      Value<int?> weightUnitId,
      required DateTime date,
      Value<int> rowid,
    });
typedef $$WorkoutLogTableTableUpdateCompanionBuilder =
    WorkoutLogTableCompanion Function({
      Value<String> id,
      Value<int> exerciseId,
      Value<int> routineId,
      Value<int?> sessionId,
      Value<int?> iteration,
      Value<int?> slotEntryId,
      Value<double?> rir,
      Value<double?> rirTarget,
      Value<double?> repetitions,
      Value<double?> repetitionsTarget,
      Value<int?> repetitionsUnitId,
      Value<double?> weight,
      Value<double?> weightTarget,
      Value<int?> weightUnitId,
      Value<DateTime> date,
      Value<int> rowid,
    });

class $$WorkoutLogTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $WorkoutLogTableTable> {
  $$WorkoutLogTableTableFilterComposer({
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

  ColumnFilters<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iteration => $composableBuilder(
    column: $table.iteration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slotEntryId => $composableBuilder(
    column: $table.slotEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rirTarget => $composableBuilder(
    column: $table.rirTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get repetitionsTarget => $composableBuilder(
    column: $table.repetitionsTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitionsUnitId => $composableBuilder(
    column: $table.repetitionsUnitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightTarget => $composableBuilder(
    column: $table.weightTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weightUnitId => $composableBuilder(
    column: $table.weightUnitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutLogTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $WorkoutLogTableTable> {
  $$WorkoutLogTableTableOrderingComposer({
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

  ColumnOrderings<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iteration => $composableBuilder(
    column: $table.iteration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slotEntryId => $composableBuilder(
    column: $table.slotEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rirTarget => $composableBuilder(
    column: $table.rirTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get repetitionsTarget => $composableBuilder(
    column: $table.repetitionsTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitionsUnitId => $composableBuilder(
    column: $table.repetitionsUnitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightTarget => $composableBuilder(
    column: $table.weightTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightUnitId => $composableBuilder(
    column: $table.weightUnitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutLogTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $WorkoutLogTableTable> {
  $$WorkoutLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get iteration =>
      $composableBuilder(column: $table.iteration, builder: (column) => column);

  GeneratedColumn<int> get slotEntryId => $composableBuilder(
    column: $table.slotEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rir =>
      $composableBuilder(column: $table.rir, builder: (column) => column);

  GeneratedColumn<double> get rirTarget =>
      $composableBuilder(column: $table.rirTarget, builder: (column) => column);

  GeneratedColumn<double> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get repetitionsTarget => $composableBuilder(
    column: $table.repetitionsTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitionsUnitId => $composableBuilder(
    column: $table.repetitionsUnitId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<double> get weightTarget => $composableBuilder(
    column: $table.weightTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weightUnitId => $composableBuilder(
    column: $table.weightUnitId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$WorkoutLogTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $WorkoutLogTableTable,
          Log,
          $$WorkoutLogTableTableFilterComposer,
          $$WorkoutLogTableTableOrderingComposer,
          $$WorkoutLogTableTableAnnotationComposer,
          $$WorkoutLogTableTableCreateCompanionBuilder,
          $$WorkoutLogTableTableUpdateCompanionBuilder,
          (Log, BaseReferences<_$DriftPowersyncDatabase, $WorkoutLogTableTable, Log>),
          Log,
          PrefetchHooks Function()
        > {
  $$WorkoutLogTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $WorkoutLogTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutLogTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> routineId = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int?> iteration = const Value.absent(),
                Value<int?> slotEntryId = const Value.absent(),
                Value<double?> rir = const Value.absent(),
                Value<double?> rirTarget = const Value.absent(),
                Value<double?> repetitions = const Value.absent(),
                Value<double?> repetitionsTarget = const Value.absent(),
                Value<int?> repetitionsUnitId = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<double?> weightTarget = const Value.absent(),
                Value<int?> weightUnitId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutLogTableCompanion(
                id: id,
                exerciseId: exerciseId,
                routineId: routineId,
                sessionId: sessionId,
                iteration: iteration,
                slotEntryId: slotEntryId,
                rir: rir,
                rirTarget: rirTarget,
                repetitions: repetitions,
                repetitionsTarget: repetitionsTarget,
                repetitionsUnitId: repetitionsUnitId,
                weight: weight,
                weightTarget: weightTarget,
                weightUnitId: weightUnitId,
                date: date,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required int exerciseId,
                required int routineId,
                Value<int?> sessionId = const Value.absent(),
                Value<int?> iteration = const Value.absent(),
                Value<int?> slotEntryId = const Value.absent(),
                Value<double?> rir = const Value.absent(),
                Value<double?> rirTarget = const Value.absent(),
                Value<double?> repetitions = const Value.absent(),
                Value<double?> repetitionsTarget = const Value.absent(),
                Value<int?> repetitionsUnitId = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<double?> weightTarget = const Value.absent(),
                Value<int?> weightUnitId = const Value.absent(),
                required DateTime date,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutLogTableCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                routineId: routineId,
                sessionId: sessionId,
                iteration: iteration,
                slotEntryId: slotEntryId,
                rir: rir,
                rirTarget: rirTarget,
                repetitions: repetitions,
                repetitionsTarget: repetitionsTarget,
                repetitionsUnitId: repetitionsUnitId,
                weight: weight,
                weightTarget: weightTarget,
                weightUnitId: weightUnitId,
                date: date,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutLogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $WorkoutLogTableTable,
      Log,
      $$WorkoutLogTableTableFilterComposer,
      $$WorkoutLogTableTableOrderingComposer,
      $$WorkoutLogTableTableAnnotationComposer,
      $$WorkoutLogTableTableCreateCompanionBuilder,
      $$WorkoutLogTableTableUpdateCompanionBuilder,
      (Log, BaseReferences<_$DriftPowersyncDatabase, $WorkoutLogTableTable, Log>),
      Log,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionTableTableCreateCompanionBuilder =
    WorkoutSessionTableCompanion Function({
      Value<String> id,
      Value<int?> routineId,
      Value<int?> dayId,
      required DateTime date,
      required String notes,
      required int impression,
      Value<TimeOfDay?> timeStart,
      Value<TimeOfDay?> timeEnd,
      Value<int> rowid,
    });
typedef $$WorkoutSessionTableTableUpdateCompanionBuilder =
    WorkoutSessionTableCompanion Function({
      Value<String> id,
      Value<int?> routineId,
      Value<int?> dayId,
      Value<DateTime> date,
      Value<String> notes,
      Value<int> impression,
      Value<TimeOfDay?> timeStart,
      Value<TimeOfDay?> timeEnd,
      Value<int> rowid,
    });

class $$WorkoutSessionTableTableFilterComposer
    extends Composer<_$DriftPowersyncDatabase, $WorkoutSessionTableTable> {
  $$WorkoutSessionTableTableFilterComposer({
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

  ColumnFilters<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<int, int, String> get impression => $composableBuilder(
    column: $table.impression,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<TimeOfDay?, TimeOfDay, String> get timeStart => $composableBuilder(
    column: $table.timeStart,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<TimeOfDay?, TimeOfDay, String> get timeEnd => $composableBuilder(
    column: $table.timeEnd,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$WorkoutSessionTableTableOrderingComposer
    extends Composer<_$DriftPowersyncDatabase, $WorkoutSessionTableTable> {
  $$WorkoutSessionTableTableOrderingComposer({
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

  ColumnOrderings<int> get routineId => $composableBuilder(
    column: $table.routineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayId => $composableBuilder(
    column: $table.dayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get impression => $composableBuilder(
    column: $table.impression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeStart => $composableBuilder(
    column: $table.timeStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeEnd => $composableBuilder(
    column: $table.timeEnd,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionTableTableAnnotationComposer
    extends Composer<_$DriftPowersyncDatabase, $WorkoutSessionTableTable> {
  $$WorkoutSessionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get routineId =>
      $composableBuilder(column: $table.routineId, builder: (column) => column);

  GeneratedColumn<int> get dayId =>
      $composableBuilder(column: $table.dayId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<int, String> get impression => $composableBuilder(
    column: $table.impression,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TimeOfDay?, String> get timeStart =>
      $composableBuilder(column: $table.timeStart, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TimeOfDay?, String> get timeEnd =>
      $composableBuilder(column: $table.timeEnd, builder: (column) => column);
}

class $$WorkoutSessionTableTableTableManager
    extends
        RootTableManager<
          _$DriftPowersyncDatabase,
          $WorkoutSessionTableTable,
          WorkoutSession,
          $$WorkoutSessionTableTableFilterComposer,
          $$WorkoutSessionTableTableOrderingComposer,
          $$WorkoutSessionTableTableAnnotationComposer,
          $$WorkoutSessionTableTableCreateCompanionBuilder,
          $$WorkoutSessionTableTableUpdateCompanionBuilder,
          (
            WorkoutSession,
            BaseReferences<_$DriftPowersyncDatabase, $WorkoutSessionTableTable, WorkoutSession>,
          ),
          WorkoutSession,
          PrefetchHooks Function()
        > {
  $$WorkoutSessionTableTableTableManager(
    _$DriftPowersyncDatabase db,
    $WorkoutSessionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WorkoutSessionTableTableOrderingComposer(
            $db: db,
            $table: table,
          ),
          createComputedFieldComposer: () => $$WorkoutSessionTableTableAnnotationComposer(
            $db: db,
            $table: table,
          ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> routineId = const Value.absent(),
                Value<int?> dayId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> impression = const Value.absent(),
                Value<TimeOfDay?> timeStart = const Value.absent(),
                Value<TimeOfDay?> timeEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionTableCompanion(
                id: id,
                routineId: routineId,
                dayId: dayId,
                date: date,
                notes: notes,
                impression: impression,
                timeStart: timeStart,
                timeEnd: timeEnd,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> routineId = const Value.absent(),
                Value<int?> dayId = const Value.absent(),
                required DateTime date,
                required String notes,
                required int impression,
                Value<TimeOfDay?> timeStart = const Value.absent(),
                Value<TimeOfDay?> timeEnd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionTableCompanion.insert(
                id: id,
                routineId: routineId,
                dayId: dayId,
                date: date,
                notes: notes,
                impression: impression,
                timeStart: timeStart,
                timeEnd: timeEnd,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSessionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$DriftPowersyncDatabase,
      $WorkoutSessionTableTable,
      WorkoutSession,
      $$WorkoutSessionTableTableFilterComposer,
      $$WorkoutSessionTableTableOrderingComposer,
      $$WorkoutSessionTableTableAnnotationComposer,
      $$WorkoutSessionTableTableCreateCompanionBuilder,
      $$WorkoutSessionTableTableUpdateCompanionBuilder,
      (
        WorkoutSession,
        BaseReferences<_$DriftPowersyncDatabase, $WorkoutSessionTableTable, WorkoutSession>,
      ),
      WorkoutSession,
      PrefetchHooks Function()
    >;

class $DriftPowersyncDatabaseManager {
  final _$DriftPowersyncDatabase _db;
  $DriftPowersyncDatabaseManager(this._db);
  $$LanguageTableTableTableManager get languageTable =>
      $$LanguageTableTableTableManager(_db, _db.languageTable);
  $$ExerciseCategoryTableTableTableManager get exerciseCategoryTable =>
      $$ExerciseCategoryTableTableTableManager(_db, _db.exerciseCategoryTable);
  $$ExerciseTableTableTableManager get exerciseTable =>
      $$ExerciseTableTableTableManager(_db, _db.exerciseTable);
  $$ExerciseTranslationTableTableTableManager get exerciseTranslationTable =>
      $$ExerciseTranslationTableTableTableManager(
        _db,
        _db.exerciseTranslationTable,
      );
  $$MuscleTableTableTableManager get muscleTable =>
      $$MuscleTableTableTableManager(_db, _db.muscleTable);
  $$ExerciseMuscleM2NTableTableManager get exerciseMuscleM2N =>
      $$ExerciseMuscleM2NTableTableManager(_db, _db.exerciseMuscleM2N);
  $$ExerciseSecondaryMuscleM2NTableTableManager get exerciseSecondaryMuscleM2N =>
      $$ExerciseSecondaryMuscleM2NTableTableManager(
        _db,
        _db.exerciseSecondaryMuscleM2N,
      );
  $$EquipmentTableTableTableManager get equipmentTable =>
      $$EquipmentTableTableTableManager(_db, _db.equipmentTable);
  $$ExerciseEquipmentM2NTableTableManager get exerciseEquipmentM2N =>
      $$ExerciseEquipmentM2NTableTableManager(_db, _db.exerciseEquipmentM2N);
  $$ExerciseImageTableTableTableManager get exerciseImageTable =>
      $$ExerciseImageTableTableTableManager(_db, _db.exerciseImageTable);
  $$ExerciseVideoTableTableTableManager get exerciseVideoTable =>
      $$ExerciseVideoTableTableTableManager(_db, _db.exerciseVideoTable);
  $$WeightEntryTableTableTableManager get weightEntryTable =>
      $$WeightEntryTableTableTableManager(_db, _db.weightEntryTable);
  $$MeasurementCategoryTableTableTableManager get measurementCategoryTable =>
      $$MeasurementCategoryTableTableTableManager(
        _db,
        _db.measurementCategoryTable,
      );
  $$WorkoutLogTableTableTableManager get workoutLogTable =>
      $$WorkoutLogTableTableTableManager(_db, _db.workoutLogTable);
  $$WorkoutSessionTableTableTableManager get workoutSessionTable =>
      $$WorkoutSessionTableTableTableManager(_db, _db.workoutSessionTable);
}
