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

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'measurement_entry.g.dart';

@JsonSerializable()
class MeasurementEntry extends Equatable {
  @JsonKey(required: true)
  final String? id;

  @JsonKey(required: true)
  final String category;

  @JsonKey(required: true, toJson: dateToYYYYMMDD)
  final DateTime date;

  @JsonKey(required: true)
  final num value;

  @JsonKey(required: true, defaultValue: '')
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
  factory MeasurementEntry.fromJson(Map<String, dynamic> json) => _$MeasurementEntryFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementEntryToJson(this);

  @override
  List<Object?> get props => [id, category, date, value, notes];
}
