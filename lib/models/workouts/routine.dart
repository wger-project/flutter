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
import 'package:wger/helpers/misc.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/session_api.dart';

part 'routine.g.dart';

@JsonSerializable()
class Routine {
  static const MIN_LENGTH_DESCRIPTION = 0;
  static const MAX_LENGTH_DESCRIPTION = 1000;

  static const MIN_LENGTH_NAME = 3;
  static const MAX_LENGTH_NAME = 25;

  /// In weeks
  static const MIN_DURATION = 2;
  static const MAX_DURATION = 16;
  static const DEFAULT_DURATION = 12;

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

  @JsonKey(required: false, includeToJson: false, defaultValue: [])
  List<WorkoutSessionApi> sessions = [];

  Routine({
    this.id,
    DateTime? created,
    required this.name,
    DateTime? start,
    DateTime? end,
    this.fitInWeek = false,
    String? description,
    this.days = const [],
    this.dayData = const [],
    this.dayDataGym = const [],
    this.sessions = const [],
  }) {
    this.created = created ?? DateTime.now();
    this.start = start ?? DateTime.now();
    this.end = end ?? DateTime.now().add(const Duration(days: DEFAULT_DURATION * 7));
    this.description = description ?? '';
  }

  Routine.empty() {
    name = '';
    description = '';
    created = DateTime.now();
    start = DateTime.now();
    end = DateTime.now().add(const Duration(days: DEFAULT_DURATION * 7));
    fitInWeek = true;
  }

  // Boilerplate
  factory Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);

  Map<String, dynamic> toJson() => _$RoutineToJson(this);

  List<Log> get logs {
    final out = <Log>[];
    for (final session in sessions) {
      out.addAll(session.logs);
    }
    return out;
  }

  int? getIteration({DateTime? date}) {
    date ??= DateTime.now();

    for (final data in dayData) {
      if (data.date.isSameDayAs(date)) {
        return data.iteration;
      }
    }
    return null;
  }

  List<DayData> get dayDataCurrentIteration {
    final iteration = getIteration(date: DateTime.now()) ?? 1;
    return dayData.where((data) => data.iteration == iteration).toList();
  }

  List<DayData> get dayDataCurrentIterationGym {
    final iteration = getIteration(date: DateTime.now()) ?? 1;
    return dayDataGym.where((data) => data.iteration == iteration).toList();
  }

  /// Filters the workout logs by exercise and sorts them by date
  ///
  /// Optionally, filters list so that only unique logs are returned. "Unique"
  /// means here that the values are the same, i.e. logs with the same weight,
  /// reps, etc. are considered equal. Workout ID, Log ID and date are not
  /// considered.
  List<Log> filterLogsByExercise(int exerciseId, {bool unique = false}) {
    var out = logs.where((log) => log.exerciseId == exerciseId).toList();

    if (unique) {
      out = out.toSet().toList();
    }

    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  /// Groups logs by repetition
  Map<num, List<Log>> groupLogsByRepetition({
    List<Log>? logs,
    filterNullWeights = false,
    filterNullReps = false,
  }) {
    final workoutLogs = logs ?? this.logs;
    final Map<num, List<Log>> groupedLogs = {};

    for (final log in workoutLogs) {
      if (log.repetitions == null ||
          (filterNullWeights && log.weight == null) ||
          (filterNullReps && log.repetitions == null)) {
        continue;
      }

      if (!groupedLogs.containsKey(log.repetitions)) {
        groupedLogs[log.repetitions!] = [];
      }

      groupedLogs[log.repetitions]!.add(log);
    }

    return groupedLogs;
  }

  /// Massages the log data to more easily present on the log overview
  ///
  Map<DateTime, Map<String, dynamic>> get logData {
    final out = <DateTime, Map<String, dynamic>>{};
    for (final sessionData in sessions) {
      final date = sessionData.session.date;
      if (!out.containsKey(date)) {
        out[date] = {
          'session': sessionData.session,
          'exercises': <Exercise, List<Log>>{},
        };
      }

      for (final log in sessionData.logs) {
        final exercise = log.exercise;
        if (!out[date]!['exercises']!.containsKey(exercise)) {
          out[date]!['exercises']![exercise] = <Log>[];
        }
        out[date]!['exercises']![exercise].add(log);
      }
    }
    return out;
  }
}
