/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/log.dart';

part 'workout_plan.g.dart';

@JsonSerializable()
class WorkoutPlan {
  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true, name: 'creation_date')
  DateTime creationDate;

  @JsonKey(required: true, name: 'comment')
  String description;

  @JsonKey(ignore: true)
  List<Day> days = [];

  @JsonKey(ignore: true)
  List<Log> logs = [];

  WorkoutPlan({
    this.id,
    required this.creationDate,
    required this.description,
    List<Day>? days,
    List<Log>? logs,
  }) {
    this.days = days ?? [];
    this.logs = logs ?? [];
  }

  // Boilerplate
  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => _$WorkoutPlanFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutPlanToJson(this);

  /// Filters the workout logs by exercise and sorts them by date
  List<Log> filterLogsByExercise(Exercise exercise) {
    var out = logs.where((element) => element.exerciseId == exercise.id).toList();
    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  /// Massages the log data to more easily present on the log overview
  ///
  LinkedHashMap<DateTime, Map<String, dynamic>> get logData {
    var out = LinkedHashMap<DateTime, Map<String, dynamic>>();
    for (var log in logs) {
      final exercise = log.exerciseObj;
      final date = log.date;

      if (!out.containsKey(date)) {
        out[date] = {
          'session': null,
          'exercises': LinkedHashMap<Exercise, List<Log>>(),
        };
      }

      if (!out[date]!['exercises']!.containsKey(exercise)) {
        out[date]!['exercises']![exercise] = <Log>[];
      }

      out[date]!['exercises']![exercise].add(log);
    }

    return out;
  }
}
