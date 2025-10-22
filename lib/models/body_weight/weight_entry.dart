/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'package:drift/drift.dart' as drift;
import 'package:json_annotation/json_annotation.dart';
import 'package:powersync/sqlite3.dart' as sqlite;
import 'package:wger/helpers/json.dart';

part 'weight_entry.g.dart';

@JsonSerializable()
class WeightEntry {
  @JsonKey(required: true)
  String? id;

  @JsonKey(required: true, fromJson: stringToNum, toJson: numToString)
  late num weight = 0;

  @JsonKey(required: true)
  late DateTime date;

  WeightEntry({this.id, num? weight, DateTime? date}) {
    this.date = date ?? DateTime.now();

    if (weight != null) {
      this.weight = weight;
    }
  }

  factory WeightEntry.fromRow(sqlite.Row row) {
    return WeightEntry(
      id: row['uuid'],
      date: DateTime.parse(row['date']),
      weight: row['weight'],
    );
  }

  WeightEntry copyWith({String? id, int? weight, DateTime? date}) => WeightEntry(
    id: id,
    weight: weight ?? this.weight,
    date: date ?? this.date,
  );

  factory WeightEntry.fromData(
    Map<String, dynamic> data,
    drift.GeneratedDatabase db, {
    String? prefix,
  }) {
    final effectivePrefix = prefix ?? '';

    final rawId = data['${effectivePrefix}id'];
    final rawWeight = data['${effectivePrefix}weight'];
    final rawDate = data['${effectivePrefix}date'];

    final parsedId = rawId as String?;
    final parsedWeight = rawWeight is num
        ? rawWeight
        : (rawWeight == null ? 0 : num.tryParse(rawWeight.toString()) ?? 0);
    final parsedDate = rawDate is DateTime
        ? rawDate
        : (rawDate == null
              ? DateTime.now()
              : DateTime.tryParse(rawDate.toString()) ?? DateTime.now());

    return WeightEntry(
      id: parsedId,
      weight: parsedWeight,
      date: parsedDate,
    );
  }

  // Boilerplate
  factory WeightEntry.fromJson(Map<String, dynamic> json) => _$WeightEntryFromJson(json);

  Map<String, dynamic> toJson() => _$WeightEntryToJson(this);
}
