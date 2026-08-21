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
import 'package:wger/database/powersync/database.dart';

part 'measurement_entry.freezed.dart';

/// The server's `source` for an entry the user wrote themselves, the only one
/// the app lets them edit or delete.
const measurementSourceUser = 'user';

/// The server's `source` for an entry it computed itself, see the calculated
/// categories. Such an entry is read-only: it is replaced whenever the data
/// behind it changes.
const measurementSourceCalculated = 'calculated';

@freezed
class MeasurementEntry with _$MeasurementEntry {
  /// Client-generated UUID, is `null` only before the first persist
  @override
  final String? id;

  @override
  final String categoryId;

  @override
  final DateTime date;

  @override
  final num value;

  @override
  final String notes;

  /// Origin of the reading; one of the server's `source` values
  /// (`user`, `google`, `apple`).
  @override
  final String source;

  /// Platform record UUID, used to deduplicate re-imports. `null` for manual
  /// entries.
  @override
  final String? externalId;

  /// Per-entry metadata (server JSONField). The `unit` key holds the unit
  /// [value] was entered in; without it the category unit applies. Raw values
  /// are meaningless without their unit, so display and calculations go
  /// through `valueIn` instead of reading [value] directly.
  @override
  final Map<String, dynamic>? extraData;

  MeasurementEntry({
    this.id,
    required this.categoryId,
    required this.date,
    required this.value,
    required this.notes,
    this.source = measurementSourceUser,
    this.externalId,
    this.extraData,
  });

  /// Maps a row of the local database. Rows synced before the 2.7 schema
  /// change lack the new columns and read as NULL; they fall back to the
  /// defaults until the full re-sync replaces them.
  MeasurementEntry.fromDb({
    required String id,
    required String categoryId,
    required DateTime date,
    required double value,
    required String notes,
    String? source,
    String? externalId,
    Map<String, dynamic>? extraData,
  }) : this(
         id: id,
         categoryId: categoryId,
         date: date,
         value: value,
         notes: notes,
         source: source ?? measurementSourceUser,
         externalId: externalId,
         extraData: extraData,
       );

  // Boilerplate
  MeasurementEntryTableCompanion toCompanion() {
    return MeasurementEntryTableCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      categoryId: Value(categoryId),
      date: Value(date),
      value: Value(value.toDouble()),
      notes: Value(notes),
      source: Value(source),
      externalId: Value(externalId),
      extraData: Value(extraData),
    );
  }
}
