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

import 'package:drift/drift.dart';

/// Persists a Django `DateField` (a calendar day, no time, no zone) as a
/// `YYYY-MM-DD` string, the format the backend stores and syncs back. Without
/// it drift would write the local day as a full ISO timestamp, so a row written
/// here and the same row after a server round-trip would no longer compare
/// equal. Reading takes the leading day, so timestamps written before this
/// converter still map to the correct date.
///
/// Use only on columns backed by a Django `DateField`. For `DateTimeField`
/// columns use `UtcDateTimeConverter` instead.
class DateOnlyTextConverter extends TypeConverter<DateTime, String> {
  const DateOnlyTextConverter();

  @override
  DateTime fromSql(String fromDb) {
    final day = DateTime.parse(fromDb.substring(0, 10));
    return DateTime.utc(day.year, day.month, day.day);
  }

  @override
  String toSql(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
