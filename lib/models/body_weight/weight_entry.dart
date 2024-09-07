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

import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'weight_entry.g.dart';

@JsonSerializable()
class WeightEntry {
  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true, fromJson: stringToNum, toJson: numToString)
  late num weight = 0;

  @JsonKey(required: true, toJson: toDate)
  late DateTime date;

  WeightEntry({this.id, weight, DateTime? date}) {
    this.date = date ?? DateTime.now();

    if (weight != null) {
      this.weight = weight;
    }
  }

  WeightEntry copyWith({int? id, int? weight, DateTime? date}) => WeightEntry(
        id: id,
        weight: weight ?? this.weight,
        date: date ?? this.date,
      );

  // Boilerplate
  factory WeightEntry.fromJson(Map<String, dynamic> json) => _$WeightEntryFromJson(json);

  Map<String, dynamic> toJson() => _$WeightEntryToJson(this);
}
