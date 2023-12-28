// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises with TableInfo<$ExercisesTable, ExerciseTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>('data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdateMeta = const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<DateTime> lastUpdate = GeneratedColumn<DateTime>(
      'last_update', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta('lastFetched');
  @override
  late final GeneratedColumn<DateTime> lastFetched = GeneratedColumn<DateTime>(
      'last_fetched', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, data, lastUpdate, lastFetched];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('data')) {
      context.handle(_dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta, lastUpdate.isAcceptableOrUnknown(data['last_update']!, _lastUpdateMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    if (data.containsKey('last_fetched')) {
      context.handle(_lastFetchedMeta,
          lastFetched.isAcceptableOrUnknown(data['last_fetched']!, _lastFetchedMeta));
    } else if (isInserting) {
      context.missing(_lastFetchedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ExerciseTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseTable(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      data: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_update'])!,
      lastFetched: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_fetched'])!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class ExerciseTable extends DataClass implements Insertable<ExerciseTable> {
  final int id;
  final String data;
  final DateTime lastUpdate;

  /// The date when the exercise was last fetched from the API. While we know
  /// when the exercise itself was last updated in `lastUpdate`, we can save
  /// ourselves a lot of requests if we don't check too often
  final DateTime lastFetched;
  const ExerciseTable(
      {required this.id, required this.data, required this.lastUpdate, required this.lastFetched});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['data'] = Variable<String>(data);
    map['last_update'] = Variable<DateTime>(lastUpdate);
    map['last_fetched'] = Variable<DateTime>(lastFetched);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      data: Value(data),
      lastUpdate: Value(lastUpdate),
      lastFetched: Value(lastFetched),
    );
  }

  factory ExerciseTable.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseTable(
      id: serializer.fromJson<int>(json['id']),
      data: serializer.fromJson<String>(json['data']),
      lastUpdate: serializer.fromJson<DateTime>(json['lastUpdate']),
      lastFetched: serializer.fromJson<DateTime>(json['lastFetched']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'data': serializer.toJson<String>(data),
      'lastUpdate': serializer.toJson<DateTime>(lastUpdate),
      'lastFetched': serializer.toJson<DateTime>(lastFetched),
    };
  }

  ExerciseTable copyWith({int? id, String? data, DateTime? lastUpdate, DateTime? lastFetched}) =>
      ExerciseTable(
        id: id ?? this.id,
        data: data ?? this.data,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        lastFetched: lastFetched ?? this.lastFetched,
      );
  @override
  String toString() {
    return (StringBuffer('ExerciseTable(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('lastFetched: $lastFetched')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data, lastUpdate, lastFetched);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseTable &&
          other.id == this.id &&
          other.data == this.data &&
          other.lastUpdate == this.lastUpdate &&
          other.lastFetched == this.lastFetched);
}

class ExercisesCompanion extends UpdateCompanion<ExerciseTable> {
  final Value<int> id;
  final Value<String> data;
  final Value<DateTime> lastUpdate;
  final Value<DateTime> lastFetched;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required int id,
    required String data,
    required DateTime lastUpdate,
    required DateTime lastFetched,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        data = Value(data),
        lastUpdate = Value(lastUpdate),
        lastFetched = Value(lastFetched);
  static Insertable<ExerciseTable> custom({
    Expression<int>? id,
    Expression<String>? data,
    Expression<DateTime>? lastUpdate,
    Expression<DateTime>? lastFetched,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith(
      {Value<int>? id,
      Value<String>? data,
      Value<DateTime>? lastUpdate,
      Value<DateTime>? lastFetched,
      Value<int>? rowid}) {
    return ExercisesCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      lastFetched: lastFetched ?? this.lastFetched,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<DateTime>(lastUpdate.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<DateTime>(lastFetched.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MusclesTable extends Muscles with TableInfo<$MusclesTable, MuscleTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MusclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumnWithTypeConverter<Muscle, String> data = GeneratedColumn<String>(
          'data', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true)
      .withConverter<Muscle>($MusclesTable.$converterdata);
  @override
  List<GeneratedColumn> get $columns => [id, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'muscles';
  @override
  VerificationContext validateIntegrity(Insertable<MuscleTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    context.handle(_dataMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  MuscleTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MuscleTable(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      data: $MusclesTable.$converterdata.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}data'])!),
    );
  }

  @override
  $MusclesTable createAlias(String alias) {
    return $MusclesTable(attachedDatabase, alias);
  }

  static TypeConverter<Muscle, String> $converterdata = const MuscleConverter();
}

class MuscleTable extends DataClass implements Insertable<MuscleTable> {
  final int id;
  final Muscle data;
  const MuscleTable({required this.id, required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      final converter = $MusclesTable.$converterdata;
      map['data'] = Variable<String>(converter.toSql(data));
    }
    return map;
  }

  MusclesCompanion toCompanion(bool nullToAbsent) {
    return MusclesCompanion(
      id: Value(id),
      data: Value(data),
    );
  }

  factory MuscleTable.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MuscleTable(
      id: serializer.fromJson<int>(json['id']),
      data: serializer.fromJson<Muscle>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'data': serializer.toJson<Muscle>(data),
    };
  }

  MuscleTable copyWith({int? id, Muscle? data}) => MuscleTable(
        id: id ?? this.id,
        data: data ?? this.data,
      );
  @override
  String toString() {
    return (StringBuffer('MuscleTable(')
          ..write('id: $id, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MuscleTable && other.id == this.id && other.data == this.data);
}

class MusclesCompanion extends UpdateCompanion<MuscleTable> {
  final Value<int> id;
  final Value<Muscle> data;
  final Value<int> rowid;
  const MusclesCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MusclesCompanion.insert({
    required int id,
    required Muscle data,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        data = Value(data);
  static Insertable<MuscleTable> custom({
    Expression<int>? id,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MusclesCompanion copyWith({Value<int>? id, Value<Muscle>? data, Value<int>? rowid}) {
    return MusclesCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (data.present) {
      final converter = $MusclesTable.$converterdata;

      map['data'] = Variable<String>(converter.toSql(data.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MusclesCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EquipmentsTable extends Equipments with TableInfo<$EquipmentsTable, EquipmentTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquipmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumnWithTypeConverter<Equipment, String> data = GeneratedColumn<String>(
          'data', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true)
      .withConverter<Equipment>($EquipmentsTable.$converterdata);
  @override
  List<GeneratedColumn> get $columns => [id, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equipments';
  @override
  VerificationContext validateIntegrity(Insertable<EquipmentTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    context.handle(_dataMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  EquipmentTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EquipmentTable(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      data: $EquipmentsTable.$converterdata.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}data'])!),
    );
  }

  @override
  $EquipmentsTable createAlias(String alias) {
    return $EquipmentsTable(attachedDatabase, alias);
  }

  static TypeConverter<Equipment, String> $converterdata = const EquipmentConverter();
}

class EquipmentTable extends DataClass implements Insertable<EquipmentTable> {
  final int id;
  final Equipment data;
  const EquipmentTable({required this.id, required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      final converter = $EquipmentsTable.$converterdata;
      map['data'] = Variable<String>(converter.toSql(data));
    }
    return map;
  }

  EquipmentsCompanion toCompanion(bool nullToAbsent) {
    return EquipmentsCompanion(
      id: Value(id),
      data: Value(data),
    );
  }

  factory EquipmentTable.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EquipmentTable(
      id: serializer.fromJson<int>(json['id']),
      data: serializer.fromJson<Equipment>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'data': serializer.toJson<Equipment>(data),
    };
  }

  EquipmentTable copyWith({int? id, Equipment? data}) => EquipmentTable(
        id: id ?? this.id,
        data: data ?? this.data,
      );
  @override
  String toString() {
    return (StringBuffer('EquipmentTable(')
          ..write('id: $id, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EquipmentTable && other.id == this.id && other.data == this.data);
}

class EquipmentsCompanion extends UpdateCompanion<EquipmentTable> {
  final Value<int> id;
  final Value<Equipment> data;
  final Value<int> rowid;
  const EquipmentsCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EquipmentsCompanion.insert({
    required int id,
    required Equipment data,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        data = Value(data);
  static Insertable<EquipmentTable> custom({
    Expression<int>? id,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EquipmentsCompanion copyWith({Value<int>? id, Value<Equipment>? data, Value<int>? rowid}) {
    return EquipmentsCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (data.present) {
      final converter = $EquipmentsTable.$converterdata;

      map['data'] = Variable<String>(converter.toSql(data.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentsCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories with TableInfo<$CategoriesTable, CategoryTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseCategory, String> data =
      GeneratedColumn<String>('data', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ExerciseCategory>($CategoriesTable.$converterdata);
  @override
  List<GeneratedColumn> get $columns => [id, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    context.handle(_dataMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  CategoryTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryTable(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      data: $CategoriesTable.$converterdata.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}data'])!),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static TypeConverter<ExerciseCategory, String> $converterdata = const ExerciseCategoryConverter();
}

class CategoryTable extends DataClass implements Insertable<CategoryTable> {
  final int id;
  final ExerciseCategory data;
  const CategoryTable({required this.id, required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      final converter = $CategoriesTable.$converterdata;
      map['data'] = Variable<String>(converter.toSql(data));
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      data: Value(data),
    );
  }

  factory CategoryTable.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryTable(
      id: serializer.fromJson<int>(json['id']),
      data: serializer.fromJson<ExerciseCategory>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'data': serializer.toJson<ExerciseCategory>(data),
    };
  }

  CategoryTable copyWith({int? id, ExerciseCategory? data}) => CategoryTable(
        id: id ?? this.id,
        data: data ?? this.data,
      );
  @override
  String toString() {
    return (StringBuffer('CategoryTable(')
          ..write('id: $id, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryTable && other.id == this.id && other.data == this.data);
}

class CategoriesCompanion extends UpdateCompanion<CategoryTable> {
  final Value<int> id;
  final Value<ExerciseCategory> data;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required int id,
    required ExerciseCategory data,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        data = Value(data);
  static Insertable<CategoryTable> custom({
    Expression<int>? id,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({Value<int>? id, Value<ExerciseCategory>? data, Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (data.present) {
      final converter = $CategoriesTable.$converterdata;

      map['data'] = Variable<String>(converter.toSql(data.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LanguagesTable extends Languages with TableInfo<$LanguagesTable, LanguagesTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LanguagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumnWithTypeConverter<Language, String> data = GeneratedColumn<String>(
          'data', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true)
      .withConverter<Language>($LanguagesTable.$converterdata);
  @override
  List<GeneratedColumn> get $columns => [id, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'languages';
  @override
  VerificationContext validateIntegrity(Insertable<LanguagesTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    context.handle(_dataMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  LanguagesTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LanguagesTable(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      data: $LanguagesTable.$converterdata.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}data'])!),
    );
  }

  @override
  $LanguagesTable createAlias(String alias) {
    return $LanguagesTable(attachedDatabase, alias);
  }

  static TypeConverter<Language, String> $converterdata = const LanguageConverter();
}

class LanguagesTable extends DataClass implements Insertable<LanguagesTable> {
  final int id;
  final Language data;
  const LanguagesTable({required this.id, required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      final converter = $LanguagesTable.$converterdata;
      map['data'] = Variable<String>(converter.toSql(data));
    }
    return map;
  }

  LanguagesCompanion toCompanion(bool nullToAbsent) {
    return LanguagesCompanion(
      id: Value(id),
      data: Value(data),
    );
  }

  factory LanguagesTable.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LanguagesTable(
      id: serializer.fromJson<int>(json['id']),
      data: serializer.fromJson<Language>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'data': serializer.toJson<Language>(data),
    };
  }

  LanguagesTable copyWith({int? id, Language? data}) => LanguagesTable(
        id: id ?? this.id,
        data: data ?? this.data,
      );
  @override
  String toString() {
    return (StringBuffer('LanguagesTable(')
          ..write('id: $id, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LanguagesTable && other.id == this.id && other.data == this.data);
}

class LanguagesCompanion extends UpdateCompanion<LanguagesTable> {
  final Value<int> id;
  final Value<Language> data;
  final Value<int> rowid;
  const LanguagesCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LanguagesCompanion.insert({
    required int id,
    required Language data,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        data = Value(data);
  static Insertable<LanguagesTable> custom({
    Expression<int>? id,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LanguagesCompanion copyWith({Value<int>? id, Value<Language>? data, Value<int>? rowid}) {
    return LanguagesCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (data.present) {
      final converter = $LanguagesTable.$converterdata;

      map['data'] = Variable<String>(converter.toSql(data.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LanguagesCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ExerciseDatabase extends GeneratedDatabase {
  _$ExerciseDatabase(QueryExecutor e) : super(e);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $MusclesTable muscles = $MusclesTable(this);
  late final $EquipmentsTable equipments = $EquipmentsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $LanguagesTable languages = $LanguagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [exercises, muscles, equipments, categories, languages];
}
