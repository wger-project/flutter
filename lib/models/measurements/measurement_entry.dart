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
import 'package:wger/database/powersync/database.dart';

class MeasurementEntry extends Equatable {
  final String id;

  final String category;

  final DateTime date;

  final num value;

  final String notes;

  const MeasurementEntry({
    required this.id,
    required this.category,
    required this.date,
    required this.value,
    required this.notes,
  });

  MeasurementEntry copyWith({
    String? id,
    String? category,
    DateTime? date,
    num? value,
    String? notes,
  }) => MeasurementEntry(
    id: id ?? this.id,
    category: category ?? this.category,
    date: date ?? this.date,
    value: value ?? this.value,
    notes: notes ?? this.notes,
  );

  // Boilerplate
  MeasurementEntryTableCompanion toCompanion({bool includeId = false}) {
    return MeasurementEntryTableCompanion(
      id: Value(id),
      category: Value(category),
      date: Value(date),
      value: Value(value.toDouble()),
      notes: Value(notes),
    );
  }

  @override
  List<Object?> get props => [id, category, date, value, notes];
}
