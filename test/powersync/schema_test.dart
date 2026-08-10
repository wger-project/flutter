/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:powersync/powersync.dart' as ps;
import 'package:wger/database/powersync/database.dart';
import 'package:wger/powersync/schema.dart';

import '../helpers/in_memory_drift.dart';

/// The PowerSync column type a Drift column of [type] has to be declared as.
///
/// A mismatch does not fail loudly: the generated view returns the value in
/// the declared type, so a `ps.Column.text` behind a Drift `BoolColumn` yields
/// `'0'`, and `'0' != 0` is true in Dart, which silently flips every read.
// Drift hides the common supertype of its column types, so this takes an
// Object and matches on the exported constants.
ps.ColumnType expectedPowerSyncType(Object type) => switch (type) {
  drift.DriftSqlType.string => ps.ColumnType.text,
  drift.DriftSqlType.bool ||
  drift.DriftSqlType.int ||
  drift.DriftSqlType.bigInt => ps.ColumnType.integer,
  drift.DriftSqlType.double => ps.ColumnType.real,
  // `store_date_time_values_as_text` is on (build.yaml)
  drift.DriftSqlType.dateTime => ps.ColumnType.text,
  _ => throw ArgumentError('No PowerSync mapping defined for $type'),
};

void main() {
  late DriftPowersyncDatabase db;
  late Map<String, drift.TableInfo<drift.Table, Object?>> driftTables;

  setUp(() async {
    db = await openTestDatabase();
    driftTables = {for (final table in db.allTables) table.actualTableName: table};
  });

  tearDown(() => db.close());

  test('the schema is not empty', () {
    // Guards the loops below against silently iterating nothing
    expect(schema.tables, isNotEmpty);
    expect(driftTables, isNotEmpty);
  });

  test('every synced table has a Drift counterpart', () {
    for (final table in schema.tables) {
      expect(driftTables, contains(table.name));
    }
  });

  test('every column is declared with the type of its Drift column', () {
    for (final table in schema.tables) {
      final driftColumns = {
        for (final column in driftTables[table.name]!.$columns) column.name: column,
      };

      for (final column in table.columns) {
        final driftColumn = driftColumns[column.name];
        expect(
          driftColumn,
          isNotNull,
          reason: '${table.name}.${column.name} has no Drift column',
        );
        expect(
          column.type,
          expectedPowerSyncType(driftColumn!.type),
          reason:
              '${table.name}.${column.name} is declared as ${column.type.name}, '
              'but Drift reads it as ${driftColumn.type}',
        );
      }
    }
  });

  test('every Drift column is part of the synced schema', () {
    for (final table in schema.tables) {
      // PowerSync stores the row id outside the payload, so it is never
      // declared as a column
      final expected = driftTables[table.name]!.$columns
          .map((column) => column.name)
          .where((name) => name != 'id')
          .toSet();

      expect(
        table.columns.map((column) => column.name).toSet(),
        expected,
        reason: 'the view for ${table.name} would not carry every Drift column',
      );
    }
  });
}
