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

abstract class _$DriftPowersyncDatabase extends GeneratedDatabase {
  _$DriftPowersyncDatabase(QueryExecutor e) : super(e);
  $DriftPowersyncDatabaseManager get managers => $DriftPowersyncDatabaseManager(this);
  late final $LanguageTableTable languageTable = $LanguageTableTable(this);
  late final $ExerciseTableTable exerciseTable = $ExerciseTableTable(this);
  late final $ExerciseTranslationTableTable exerciseTranslationTable =
      $ExerciseTranslationTableTable(this);
  late final $MuscleTableTable muscleTable = $MuscleTableTable(this);
  late final $ExerciseMuscleM2NTable exerciseMuscleM2N = $ExerciseMuscleM2NTable(this);
  late final $ExerciseSecondaryMuscleM2NTable exerciseSecondaryMuscleM2N =
      $ExerciseSecondaryMuscleM2NTable(this);
  late final $EquipmentTableTable equipmentTable = $EquipmentTableTable(this);
  late final $ExerciseCategoryTableTable exerciseCategoryTable = $ExerciseCategoryTableTable(this);
  late final $ExerciseImageTableTable exerciseImageTable = $ExerciseImageTableTable(this);
  late final $ExerciseVideoTableTable exerciseVideoTable = $ExerciseVideoTableTable(this);
  late final $WeightEntryTableTable weightEntryTable = $WeightEntryTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    languageTable,
    exerciseTable,
    exerciseTranslationTable,
    muscleTable,
    exerciseMuscleM2N,
    exerciseSecondaryMuscleM2N,
    equipmentTable,
    exerciseCategoryTable,
    exerciseImageTable,
    exerciseVideoTable,
    weightEntryTable,
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
          (Language, BaseReferences<_$DriftPowersyncDatabase, $LanguageTableTable, Language>),
          Language,
          PrefetchHooks Function()
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
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
      (Language, BaseReferences<_$DriftPowersyncDatabase, $LanguageTableTable, Language>),
      Language,
      PrefetchHooks Function()
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

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
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

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
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

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdate => $composableBuilder(
    column: $table.lastUpdate,
    builder: (column) => column,
  );
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
          (Exercise, BaseReferences<_$DriftPowersyncDatabase, $ExerciseTableTable, Exercise>),
          Exercise,
          PrefetchHooks Function()
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
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
      (Exercise, BaseReferences<_$DriftPowersyncDatabase, $ExerciseTableTable, Exercise>),
      Exercise,
      PrefetchHooks Function()
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

  ColumnFilters<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get languageId => $composableBuilder(
    column: $table.languageId,
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

  ColumnOrderings<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get languageId => $composableBuilder(
    column: $table.languageId,
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

  GeneratedColumn<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get languageId => $composableBuilder(
    column: $table.languageId,
    builder: (column) => column,
  );

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
          (
            Translation,
            BaseReferences<_$DriftPowersyncDatabase, $ExerciseTranslationTableTable, Translation>,
          ),
          Translation,
          PrefetchHooks Function()
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
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
      (
        Translation,
        BaseReferences<_$DriftPowersyncDatabase, $ExerciseTranslationTableTable, Translation>,
      ),
      Translation,
      PrefetchHooks Function()
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
          (Muscle, BaseReferences<_$DriftPowersyncDatabase, $MuscleTableTable, Muscle>),
          Muscle,
          PrefetchHooks Function()
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
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
      (Muscle, BaseReferences<_$DriftPowersyncDatabase, $MuscleTableTable, Muscle>),
      Muscle,
      PrefetchHooks Function()
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

  ColumnFilters<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get muscleId => $composableBuilder(
    column: $table.muscleId,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get muscleId => $composableBuilder(
    column: $table.muscleId,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get muscleId =>
      $composableBuilder(column: $table.muscleId, builder: (column) => column);
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
          (
            ExerciseMuscleM2NData,
            BaseReferences<
              _$DriftPowersyncDatabase,
              $ExerciseMuscleM2NTable,
              ExerciseMuscleM2NData
            >,
          ),
          ExerciseMuscleM2NData,
          PrefetchHooks Function()
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
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
      (
        ExerciseMuscleM2NData,
        BaseReferences<_$DriftPowersyncDatabase, $ExerciseMuscleM2NTable, ExerciseMuscleM2NData>,
      ),
      ExerciseMuscleM2NData,
      PrefetchHooks Function()
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

  ColumnFilters<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get muscleId => $composableBuilder(
    column: $table.muscleId,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get muscleId => $composableBuilder(
    column: $table.muscleId,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get muscleId =>
      $composableBuilder(column: $table.muscleId, builder: (column) => column);
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
          (
            ExerciseSecondaryMuscleM2NData,
            BaseReferences<
              _$DriftPowersyncDatabase,
              $ExerciseSecondaryMuscleM2NTable,
              ExerciseSecondaryMuscleM2NData
            >,
          ),
          ExerciseSecondaryMuscleM2NData,
          PrefetchHooks Function()
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
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
      (
        ExerciseSecondaryMuscleM2NData,
        BaseReferences<
          _$DriftPowersyncDatabase,
          $ExerciseSecondaryMuscleM2NTable,
          ExerciseSecondaryMuscleM2NData
        >,
      ),
      ExerciseSecondaryMuscleM2NData,
      PrefetchHooks Function()
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
          (Equipment, BaseReferences<_$DriftPowersyncDatabase, $EquipmentTableTable, Equipment>),
          Equipment,
          PrefetchHooks Function()
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
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
      (Equipment, BaseReferences<_$DriftPowersyncDatabase, $EquipmentTableTable, Equipment>),
      Equipment,
      PrefetchHooks Function()
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
          (
            ExerciseCategory,
            BaseReferences<_$DriftPowersyncDatabase, $ExerciseCategoryTableTable, ExerciseCategory>,
          ),
          ExerciseCategory,
          PrefetchHooks Function()
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
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
      (
        ExerciseCategory,
        BaseReferences<_$DriftPowersyncDatabase, $ExerciseCategoryTableTable, ExerciseCategory>,
      ),
      ExerciseCategory,
      PrefetchHooks Function()
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

  ColumnFilters<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
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

  ColumnOrderings<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
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

  GeneratedColumn<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<bool> get isMain =>
      $composableBuilder(column: $table.isMain, builder: (column) => column);
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
          (
            ExerciseImage,
            BaseReferences<_$DriftPowersyncDatabase, $ExerciseImageTableTable, ExerciseImage>,
          ),
          ExerciseImage,
          PrefetchHooks Function()
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
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
      (
        ExerciseImage,
        BaseReferences<_$DriftPowersyncDatabase, $ExerciseImageTableTable, ExerciseImage>,
      ),
      ExerciseImage,
      PrefetchHooks Function()
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

  ColumnFilters<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
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

  ColumnOrderings<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
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

  GeneratedColumn<int> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

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
          (Video, BaseReferences<_$DriftPowersyncDatabase, $ExerciseVideoTableTable, Video>),
          Video,
          PrefetchHooks Function()
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
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
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
      (Video, BaseReferences<_$DriftPowersyncDatabase, $ExerciseVideoTableTable, Video>),
      Video,
      PrefetchHooks Function()
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

class $DriftPowersyncDatabaseManager {
  final _$DriftPowersyncDatabase _db;
  $DriftPowersyncDatabaseManager(this._db);
  $$LanguageTableTableTableManager get languageTable =>
      $$LanguageTableTableTableManager(_db, _db.languageTable);
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
  $$ExerciseCategoryTableTableTableManager get exerciseCategoryTable =>
      $$ExerciseCategoryTableTableTableManager(_db, _db.exerciseCategoryTable);
  $$ExerciseImageTableTableTableManager get exerciseImageTable =>
      $$ExerciseImageTableTableTableManager(_db, _db.exerciseImageTable);
  $$ExerciseVideoTableTableTableManager get exerciseVideoTable =>
      $$ExerciseVideoTableTableTableManager(_db, _db.exerciseVideoTable);
  $$WeightEntryTableTableTableManager get weightEntryTable =>
      $$WeightEntryTableTableTableManager(_db, _db.weightEntryTable);
}
