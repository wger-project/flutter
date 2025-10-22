// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WeightEntryTableTable weightEntryTable = $WeightEntryTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [weightEntryTable];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

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
    extends Composer<_$AppDatabase, $WeightEntryTableTable> {
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
    extends Composer<_$AppDatabase, $WeightEntryTableTable> {
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
    extends Composer<_$AppDatabase, $WeightEntryTableTable> {
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
          _$AppDatabase,
          $WeightEntryTableTable,
          WeightEntry,
          $$WeightEntryTableTableFilterComposer,
          $$WeightEntryTableTableOrderingComposer,
          $$WeightEntryTableTableAnnotationComposer,
          $$WeightEntryTableTableCreateCompanionBuilder,
          $$WeightEntryTableTableUpdateCompanionBuilder,
          (
            WeightEntry,
            BaseReferences<_$AppDatabase, $WeightEntryTableTable, WeightEntry>,
          ),
          WeightEntry,
          PrefetchHooks Function()
        > {
  $$WeightEntryTableTableTableManager(
    _$AppDatabase db,
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
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightEntryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightEntryTableTable,
      WeightEntry,
      $$WeightEntryTableTableFilterComposer,
      $$WeightEntryTableTableOrderingComposer,
      $$WeightEntryTableTableAnnotationComposer,
      $$WeightEntryTableTableCreateCompanionBuilder,
      $$WeightEntryTableTableUpdateCompanionBuilder,
      (
        WeightEntry,
        BaseReferences<_$AppDatabase, $WeightEntryTableTable, WeightEntry>,
      ),
      WeightEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WeightEntryTableTableTableManager get weightEntryTable =>
      $$WeightEntryTableTableTableManager(_db, _db.weightEntryTable);
}
