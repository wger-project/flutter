/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:drift/drift.dart';
import 'package:powersync/powersync.dart' as ps;
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

@UseRowClass(MeasurementCategory)
class MeasurementCategoryTable extends Table {
  @override
  String get tableName => 'measurements_category';

  IntColumn get id => integer()();
  TextColumn get uuid => text().clientDefault(() => ps.uuid.v4())();

  TextColumn get name => text()();
  TextColumn get unit => text()();
}

const PowersyncMeasurementCategoryTable = ps.Table(
  'measurements_category',
  [
    ps.Column.text('uuid'),
    ps.Column.text('name'),
    ps.Column.text('unit'),
  ],
);

@UseRowClass(MeasurementEntry)
class MeasurementEntryTable extends Table {
  @override
  String get tableName => 'measurements_measurement';

  IntColumn get id => integer().named('id')();
  TextColumn get uuid => text().clientDefault(() => ps.uuid.v4())();
  IntColumn get categoryId =>
      integer().named('category_id').references(MeasurementCategoryTable, #id)();

  DateTimeColumn get date => dateTime()();
  RealColumn get value => real()();
  TextColumn get notes => text()();
}

const PowersyncMeasurementEntryTable = ps.Table(
  'measurements_measurement',
  [
    ps.Column.text('uuid'),
    ps.Column.integer('category_id'),
    ps.Column.text('date'),
    ps.Column.real('value'),
    ps.Column.text('notes'),
  ],
  indexes: [
    ps.Index('category_idx', [ps.IndexedColumn('category_id')]),
  ],
);
