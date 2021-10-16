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

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'session.g.dart';

const IMPRESSION_MAP = {1: 'bad', 2: 'neutral', 3: 'good'};

@JsonSerializable()
class WorkoutSession {
  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true, name: 'workout')
  late int workoutId;

  @JsonKey(required: true, toJson: toDate)
  late DateTime date;

  @JsonKey(required: true, fromJson: stringToNum, toJson: numToString)
  late num impression;

  @JsonKey(required: false, defaultValue: '')
  late String notes;

  @JsonKey(required: true, name: 'time_start', toJson: timeToString, fromJson: stringToTime)
  late TimeOfDay timeStart;

  @JsonKey(required: true, name: 'time_end', toJson: timeToString, fromJson: stringToTime)
  late TimeOfDay timeEnd;

  WorkoutSession();

  WorkoutSession.withData({
    required this.id,
    required this.workoutId,
    required this.date,
    required this.impression,
    required this.notes,
    required this.timeStart,
    required this.timeEnd,
  });

  WorkoutSession.now() {
    timeStart = TimeOfDay.now();
    timeEnd = TimeOfDay.now();
  }

  // Boilerplate
  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);

  String? get impressionAsString {
    return IMPRESSION_MAP[impression];
  }
}
