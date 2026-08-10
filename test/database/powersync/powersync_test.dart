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

import 'package:drift/drift.dart' show DriftSqlType, Table, TableInfo;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/database/powersync/powersync.dart';
import 'package:wger/powersync/schema.dart';

/// PowerSync manages the JSON view tables itself, but the raw tables are
/// materialised from hand-written DDL. Nothing fails loudly when that DDL and
/// the Drift definitions drift apart: the column is simply not there, and
/// every read of it comes back empty.
void main() {
  /// Deliberately without `createMigrator().createAll()`: the raw tables have
  /// to come from the DDL under test. On a database that already carries
  /// Drift's own schema the `CREATE TABLE IF NOT EXISTS` would be a no-op and
  /// the comparison would check Drift against itself.
  late DriftPowersyncDatabase db;

  setUp(() => db = DriftPowersyncDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  TableInfo<Table, Object?> driftTable(String name) =>
      db.allTables.firstWhere((table) => table.actualTableName == name);

  /// Column name to SQLite type, as the DDL actually creates them.
  Future<Map<String, String>> createdColumns(String table) async {
    await db.customStatement(rawTableStatements[table]!);
    final rows = await db.customSelect('PRAGMA table_info($table)').get();

    return {
      for (final row in rows) row.read<String>('name'): row.read<String>('type'),
    };
  }

  test('every raw table in the schema has a statement', () {
    expect(
      rawTableStatements.keys.toSet(),
      schema.rawTables.map((table) => table.name).toSet(),
    );
  });

  test('the created columns match the Drift definitions', () async {
    for (final table in rawTableStatements.keys) {
      expect(
        (await createdColumns(table)).keys.toSet(),
        driftTable(table).$columns.map((column) => column.name).toSet(),
        reason: 'the raw table $table does not carry every Drift column',
      );
    }
  });

  test('the created columns use the affinity of their Drift type', () async {
    // `store_date_time_values_as_text` is on, so a Drift DateTimeColumn has to
    // be created as TEXT here as well
    const expectedAffinity = {
      DriftSqlType.string: 'TEXT',
      DriftSqlType.int: 'INTEGER',
      DriftSqlType.dateTime: 'TEXT',
    };

    for (final table in rawTableStatements.keys) {
      final created = await createdColumns(table);

      for (final column in driftTable(table).$columns) {
        final expected = expectedAffinity[column.type];
        expect(
          expected,
          isNotNull,
          reason: 'no affinity defined for ${column.type} ($table.${column.name})',
        );
        expect(
          created[column.name],
          expected,
          reason:
              '$table.${column.name} is created as ${created[column.name]}, '
              'but Drift reads it as ${column.type}',
        );
      }
    }
  });
}
