/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'package:wger/features/measurements/models/measurement_category.dart';

/// Maps a [ChartType] to and from the SQLite string format.
///
/// The column is nullable while the model field is not: NULL is the server's
/// "no override", which is [ChartType.auto] here. Rows that were synced before
/// the column existed read NULL as well and arrive at the same default.
class MeasurementChartTypeConverter extends TypeConverter<ChartType, String?> {
  const MeasurementChartTypeConverter();

  @override
  ChartType fromSql(String? fromDb) => ChartType.fromWire(fromDb);

  @override
  String? toSql(ChartType value) => value.wireValue;
}
