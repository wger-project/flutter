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
import 'package:equatable/equatable.dart';
import 'package:wger/core/exceptions/no_such_entry_exception.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

class MeasurementCategory extends Equatable {
  final String id;

  final String name;

  final String unit;

  final List<MeasurementEntry> entries;

  const MeasurementCategory({
    required this.id,
    required this.name,
    required this.unit,
    this.entries = const [],
  });

  MeasurementCategory copyWith({
    String? id,
    String? name,
    String? unit,
    List<MeasurementEntry>? entries,
  }) {
    return MeasurementCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      entries: entries ?? this.entries,
    );
  }

  MeasurementEntry findEntryById(String entryId) {
    return entries.firstWhere(
      (entry) => entry.id == entryId,
      orElse: () => throw const NoSuchEntryException(),
    );
  }

  // Boilerplate
  MeasurementCategoryTableCompanion toCompanion({bool includeId = false}) {
    return MeasurementCategoryTableCompanion(
      id: Value(id),
      name: Value(name),
      unit: Value(unit),
    );
  }

  @override
  List<Object?> get props => [id, name, unit, entries];
}
