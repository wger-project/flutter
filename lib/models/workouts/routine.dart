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

import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/log.dart';

part 'routine.g.dart';

@JsonSerializable()
class Routine {
  static const MIN_LENGTH_DESCRIPTION = 0;
  static const MAX_LENGTH_DESCRIPTION = 1000;

  static const MIN_LENGTH_NAME = 3;
  static const MAX_LENGTH_NAME = 25;

  /// In weeks
  static const MIN_DURATION = 2;

  /// In weeks
  static const MAX_DURATION = 16;

  @JsonKey(required: true, includeToJson: false)
  int? id;

  @JsonKey(required: true)
  late DateTime created;

  @JsonKey(required: true, name: 'name')
  late String name;

  @JsonKey(required: true, name: 'description')
  late String description;

  @JsonKey(required: true, name: 'fit_in_week')
  late bool fitInWeek;

  @JsonKey(required: true, toJson: dateToYYYYMMDD)
  late DateTime start;

  @JsonKey(required: true, toJson: dateToYYYYMMDD)
  late DateTime end;

  @JsonKey(includeFromJson: true, required: false, includeToJson: false)
  List<Day> days = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<DayData> dayData = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<DayData> dayDataGym = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<DayData> dayDataCurrentIteration = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<DayData> dayDataCurrentIterationGym = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Log> logs = [];

  Routine({
    this.id,
    required this.created,
    required this.name,
    required this.start,
    required this.end,
    this.fitInWeek = false,
    String? description,
    List<Day>? days,
    List<Log>? logs,
  }) {
    this.days = days ?? [];
    this.logs = logs ?? [];
    this.description = description ?? '';
  }

  Routine.empty() {
    name = '';
    description = '';
    created = DateTime.now();
    start = DateTime.now();
    end = DateTime.now();
    fitInWeek = false;
  }

  // Boilerplate
  factory Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);

  Map<String, dynamic> toJson() => _$RoutineToJson(this);

  /// Filters the workout logs by exercise and sorts them by date
  ///
  /// Optionally, filters list so that only unique logs are returned. "Unique"
  /// means here that the values are the same, i.e. logs with the same weight,
  /// reps, etc. are considered equal. Workout ID, Log ID and date are not
  /// considered.
  List<Log> filterLogsByExercise(Exercise exercise, {bool unique = false}) {
    var out = logs.where((element) => element.exerciseId == exercise.id).toList();

    if (unique) {
      out = out.toSet().toList();
    }

    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  /// Massages the log data to more easily present on the log overview
  ///
  Map<DateTime, Map<String, dynamic>> get logData {
    final out = <DateTime, Map<String, dynamic>>{};
    for (final log in logs) {
      final exercise = log.exercise;
      final date = log.date;

      if (!out.containsKey(date)) {
        out[date] = {
          'session': null,
          'exercises': <Exercise, List<Log>>{},
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
