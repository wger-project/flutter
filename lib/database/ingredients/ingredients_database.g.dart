// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredients_database.dart';

// ignore_for_file: type=lint
class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, IngredientTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<DateTime> lastUpdate = GeneratedColumn<DateTime>(
      'last_update', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, data, lastUpdate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<IngredientTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    } else if (isInserting) {
      context.missing(_lastUpdateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  IngredientTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_update'])!,
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class IngredientTable extends DataClass implements Insertable<IngredientTable> {
  final int id;
  final String data;
  final DateTime lastUpdate;
  const IngredientTable(
      {required this.id, required this.data, required this.lastUpdate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['data'] = Variable<String>(data);
    map['last_update'] = Variable<DateTime>(lastUpdate);
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      data: Value(data),
      lastUpdate: Value(lastUpdate),
    );
  }

  factory IngredientTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientTable(
      id: serializer.fromJson<int>(json['id']),
      data: serializer.fromJson<String>(json['data']),
      lastUpdate: serializer.fromJson<DateTime>(json['lastUpdate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'data': serializer.toJson<String>(data),
      'lastUpdate': serializer.toJson<DateTime>(lastUpdate),
    };
  }

  IngredientTable copyWith({int? id, String? data, DateTime? lastUpdate}) =>
      IngredientTable(
        id: id ?? this.id,
        data: data ?? this.data,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
  @override
  String toString() {
    return (StringBuffer('IngredientTable(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('lastUpdate: $lastUpdate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data, lastUpdate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientTable &&
          other.id == this.id &&
          other.data == this.data &&
          other.lastUpdate == this.lastUpdate);
}

class IngredientsCompanion extends UpdateCompanion<IngredientTable> {
  final Value<int> id;
  final Value<String> data;
  final Value<DateTime> lastUpdate;
  final Value<int> rowid;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientsCompanion.insert({
    required int id,
    required String data,
    required DateTime lastUpdate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        data = Value(data),
        lastUpdate = Value(lastUpdate);
  static Insertable<IngredientTable> custom({
    Expression<int>? id,
    Expression<String>? data,
    Expression<DateTime>? lastUpdate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientsCompanion copyWith(
      {Value<int>? id,
      Value<String>? data,
      Value<DateTime>? lastUpdate,
      Value<int>? rowid}) {
    return IngredientsCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
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
    if (data.present) {
      map['data'] = Variable<String>(data.value);
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
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$IngredientDatabase extends GeneratedDatabase {
  _$IngredientDatabase(QueryExecutor e) : super(e);
  _$IngredientDatabaseManager get managers => _$IngredientDatabaseManager(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [ingredients];
}

typedef $$IngredientsTableInsertCompanionBuilder = IngredientsCompanion
    Function({
  required int id,
  required String data,
  required DateTime lastUpdate,
  Value<int> rowid,
});
typedef $$IngredientsTableUpdateCompanionBuilder = IngredientsCompanion
    Function({
  Value<int> id,
  Value<String> data,
  Value<DateTime> lastUpdate,
  Value<int> rowid,
});

class $$IngredientsTableTableManager extends RootTableManager<
    _$IngredientDatabase,
    $IngredientsTable,
    IngredientTable,
    $$IngredientsTableFilterComposer,
    $$IngredientsTableOrderingComposer,
    $$IngredientsTableProcessedTableManager,
    $$IngredientsTableInsertCompanionBuilder,
    $$IngredientsTableUpdateCompanionBuilder> {
  $$IngredientsTableTableManager(
      _$IngredientDatabase db, $IngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$IngredientsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$IngredientsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$IngredientsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<DateTime> lastUpdate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IngredientsCompanion(
            id: id,
            data: data,
            lastUpdate: lastUpdate,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required int id,
            required String data,
            required DateTime lastUpdate,
            Value<int> rowid = const Value.absent(),
          }) =>
              IngredientsCompanion.insert(
            id: id,
            data: data,
            lastUpdate: lastUpdate,
            rowid: rowid,
          ),
        ));
}

class $$IngredientsTableProcessedTableManager extends ProcessedTableManager<
    _$IngredientDatabase,
    $IngredientsTable,
    IngredientTable,
    $$IngredientsTableFilterComposer,
    $$IngredientsTableOrderingComposer,
    $$IngredientsTableProcessedTableManager,
    $$IngredientsTableInsertCompanionBuilder,
    $$IngredientsTableUpdateCompanionBuilder> {
  $$IngredientsTableProcessedTableManager(super.$state);
}

class $$IngredientsTableFilterComposer
    extends FilterComposer<_$IngredientDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastUpdate => $state.composableBuilder(
      column: $state.table.lastUpdate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$IngredientsTableOrderingComposer
    extends OrderingComposer<_$IngredientDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastUpdate => $state.composableBuilder(
      column: $state.table.lastUpdate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class _$IngredientDatabaseManager {
  final _$IngredientDatabase _db;
  _$IngredientDatabaseManager(this._db);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
}
