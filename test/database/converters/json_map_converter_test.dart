/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/database/converters/json_map_converter.dart';
import 'package:wger/database/powersync/database.dart';

import '../../helpers/in_memory_drift.dart';

void main() {
  const converter = JsonMapConverter();

  group('JsonMapConverter', () {
    test('decodes a JSON object', () {
      expect(converter.fromSql('{"unit": "lb", "device": "Scale"}'), {
        'unit': 'lb',
        'device': 'Scale',
      });
    });

    test('anything that is not a JSON object reads as an empty map', () {
      expect(converter.fromSql(''), <String, dynamic>{});
      expect(converter.fromSql('{not json'), <String, dynamic>{});
      expect(converter.fromSql('[1, 2]'), <String, dynamic>{});
      expect(converter.fromSql('"kg"'), <String, dynamic>{});
      expect(converter.fromSql('42'), <String, dynamic>{});
    });
  });

  group('extra_data through the Drift database', () {
    late DriftPowersyncDatabase db;

    setUp(() async {
      db = await openTestDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    test('a written map survives the roundtrip', () async {
      await db
          .into(db.measurementEntryTable)
          .insert(
            MeasurementEntryTableCompanion(
              id: const Value('e-1'),
              categoryId: const Value('c-1'),
              date: Value(DateTime.utc(2026, 1, 1)),
              value: const Value(80.5),
              notes: const Value(''),
              extraData: const Value({'unit': 'lb', 'source_unit': 'lb'}),
            ),
          );

      final row = await db.select(db.measurementEntryTable).getSingle();
      expect(row.extraData, {'unit': 'lb', 'source_unit': 'lb'});
    });

    test('text written by PowerSync is decoded on read', () async {
      // PowerSync syncs JSON columns as raw text, bypassing the converter
      await db.customStatement(
        'INSERT INTO measurements_measurement '
        '(id, category_id, date, value, notes, source, extra_data) '
        "VALUES ('e-2', 'c-1', '2026-01-01T00:00:00.000Z', 80.5, '', 'user', '{\"unit\": \"kg\"}')",
      );

      final row = await db.select(db.measurementEntryTable).getSingle();
      expect(row.extraData, {'unit': 'kg'});
    });
  });
}
