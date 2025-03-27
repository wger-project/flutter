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
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/slot_data.dart';

part 'day_data.g.dart';

@JsonSerializable()
class DayData {
  @JsonKey(required: true)
  late int iteration;

  @JsonKey(required: true)
  late DateTime date;

  @JsonKey(required: true)
  late String? label;

  @JsonKey(required: false)
  late Day? day;

  @JsonKey(required: false)
  late List<SlotData> slots;

  DayData({
    required this.iteration,
    required this.date,
    this.label = '',
    required this.day,
    this.slots = const [],
  });

  // Boilerplate
  factory DayData.fromJson(Map<String, dynamic> json) => _$DayDataFromJson(json);

  Map<String, dynamic> toJson() => _$DayDataToJson(this);
}
