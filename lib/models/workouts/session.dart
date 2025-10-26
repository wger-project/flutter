/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/workouts/log.dart';

part 'session.g.dart';

const IMPRESSION_MAP = {1: 'bad', 2: 'neutral', 3: 'good'};

@JsonSerializable()
class WorkoutSession {
  @JsonKey(required: true)
  String? id;

  @JsonKey(required: true, name: 'routine')
  late int? routineId;

  @JsonKey(required: true, name: 'day')
  int? dayId;

  @JsonKey(required: true, toJson: dateToYYYYMMDD)
  late DateTime date;

  @JsonKey(required: true, fromJson: int.parse, toJson: numToString)
  late int impression;

  @JsonKey(required: false, defaultValue: '')
  late String notes;

  @JsonKey(required: true, name: 'time_start', toJson: timeToString, fromJson: stringToTimeNull)
  late TimeOfDay? timeStart;

  @JsonKey(required: true, name: 'time_end', toJson: timeToString, fromJson: stringToTimeNull)
  late TimeOfDay? timeEnd;

  @JsonKey(required: false, includeToJson: false, defaultValue: [])
  List<Log> logs = [];

  WorkoutSession({
    this.id,
    this.dayId,
    required this.routineId,
    this.impression = 2,
    this.notes = '',
    this.timeStart,
    this.timeEnd,
    this.logs = const <Log>[],
    DateTime? date,
  }) {
    this.date = date ?? DateTime.now();
  }

  WorkoutSessionTableCompanion toCompanion({bool includeId = false}) {
    return WorkoutSessionTableCompanion(
      id: includeId && id != null ? drift.Value(id!) : const drift.Value.absent(),
      routineId: routineId != null ? drift.Value(routineId) : const drift.Value.absent(),
      dayId: dayId != null ? drift.Value(dayId) : const drift.Value.absent(),
      date: drift.Value(date.toUtc()),
      notes: drift.Value(notes),
      impression: drift.Value(impression),
      timeStart: timeStart != null ? drift.Value(timeStart) : const drift.Value.absent(),
      timeEnd: timeEnd != null ? drift.Value(timeEnd) : const drift.Value.absent(),
    );
  }

  // Boilerplate
  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSessionToJson(this);

  String get impressionAsString {
    return IMPRESSION_MAP[impression]!;
  }
}
