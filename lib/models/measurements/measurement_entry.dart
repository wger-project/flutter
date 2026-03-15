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

import 'package:drift/drift.dart' hide JsonKey;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:powersync/powersync.dart' show uuid;
import 'package:wger/database/powersync/database.dart';

part 'measurement_entry.freezed.dart';

@freezed
class MeasurementEntry with _$MeasurementEntry {
  @override
  final String id;

  @override
  final String categoryId;

  @override
  final DateTime date;

  @override
  final num value;

  @override
  final String notes;

  MeasurementEntry({
    String? id,
    required this.categoryId,
    required this.date,
    required this.value,
    required this.notes,
  }) : id = id ?? uuid.v7();

  // Boilerplate
  MeasurementEntryTableCompanion toCompanion({bool includeId = false}) {
    return MeasurementEntryTableCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      date: Value(date),
      value: Value(value.toDouble()),
      notes: Value(notes),
    );
  }
}
