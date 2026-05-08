/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/date.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/session.dart';

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

  @JsonKey(required: true, fromJson: utcIso8601ToLocalDate, toJson: dateToUtcIso8601)
  late DateTime created;

  @JsonKey(required: true, name: 'name')
  late String name;

  @JsonKey(required: true, name: 'description')
  late String description;

  @JsonKey(required: true, name: 'fit_in_week')
  late bool fitInWeek;

  // The two template flags are server-managed and the Flutter app does not
  // expose UI to toggle them, but PowerSync syncs them so the in-memory
  // state stays consistent with the backend (and round-trips correctly
  // on PATCH writes via [toCompanion]).
  @JsonKey(name: 'is_template', defaultValue: false)
  late bool isTemplate;

  @JsonKey(name: 'is_public', defaultValue: false)
  late bool isPublic;

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

  @JsonKey(required: false, includeToJson: false, includeFromJson: false)
  List<WorkoutSession> sessions = [];

  Routine({
    this.id,
    DateTime? created,
    required this.name,
    DateTime? start,
    DateTime? end,
    this.fitInWeek = false,
    this.isTemplate = false,
    this.isPublic = false,
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
    isTemplate = false;
    isPublic = false;
  }

  // Boilerplate
  factory Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);

  Map<String, dynamic> toJson() => _$RoutineToJson(this);

  Routine copyWith({
    int? id,
    DateTime? created,
    String? name,
    String? description,
    bool? fitInWeek,
    bool? isTemplate,
    bool? isPublic,
    DateTime? start,
    DateTime? end,
    List<Day>? days,
    List<DayData>? dayData,
    List<DayData>? dayDataGym,
    List<WorkoutSession>? sessions,
  }) {
    return Routine(
      id: id ?? this.id,
      created: created ?? this.created,
      name: name ?? this.name,
      description: description ?? this.description,
      fitInWeek: fitInWeek ?? this.fitInWeek,
      isTemplate: isTemplate ?? this.isTemplate,
      isPublic: isPublic ?? this.isPublic,
      start: start ?? this.start,
      end: end ?? this.end,
      days: days ?? this.days,
      dayData: dayData ?? this.dayData,
      dayDataGym: dayDataGym ?? this.dayDataGym,
      sessions: sessions ?? this.sessions,
    );
  }

  RoutineTableCompanion toCompanion() {
    final routineId = id;
    if (routineId == null) {
      throw StateError('Cannot persist routine without id (creation goes via REST)');
    }
    return RoutineTableCompanion(
      id: drift.Value(routineId),
      name: drift.Value(name),
      description: drift.Value(description),
      created: drift.Value(created.toUtc()),
      // `start`/`end` are `DateField` server-side
      start: drift.Value(DateTime.utc(start.year, start.month, start.day)),
      end: drift.Value(DateTime.utc(end.year, end.month, end.day)),
      isTemplate: drift.Value(isTemplate),
      isPublic: drift.Value(isPublic),
      fitInWeek: drift.Value(fitInWeek),
    );
  }

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

  /// Filter out dayData entries with null days as well as duplicated days from
  /// the "fixed weekly schedule" toggle.
  List<DayData> get dayDataCurrentIterationFiltered {
    final sorted = List<DayData>.from(
      dayDataCurrentIteration.where((dd) => dd.day != null),
    )..sort((a, b) => a.day!.order.compareTo(b.day!.order));

    // Filter out entries where the day is the same as the previous one. This
    // is necessary because if the user has the "Fixed weekly schedule" option
    // enabled, there would be multiple entries for the same day.
    final unique = <DayData>[];
    for (final dd in sorted) {
      if (unique.isEmpty || unique.last.day!.id != dd.day!.id) {
        unique.add(dd);
      } else {
        // If the day id is the same as the previous, replace the previous
        // entry with the current one so the last occurrence is kept.
        unique[unique.length - 1] = dd;
      }
    }

    return unique;
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

  Routine replaceExercise(int oldExerciseId, Exercise newExercise) {
    final updatedRoutine = this.copyWith(
      sessions: List<WorkoutSession>.from(this.sessions),
      dayData: List<DayData>.from(this.dayData),
      dayDataGym: List<DayData>.from(this.dayDataGym),
    );

    for (final session in updatedRoutine.sessions) {
      for (final log in session.logs) {
        if (log.exerciseId == oldExerciseId) {
          log.exerciseId = newExercise.id;
          log.exercise = newExercise;
        }
      }
    }

    for (final day in updatedRoutine.dayData) {
      for (final slot in day.slots) {
        for (final config in slot.setConfigs) {
          if (config.exerciseId == oldExerciseId) {
            config.exerciseId = newExercise.id;
            config.exercise = newExercise;
          }
        }
      }
    }

    for (final day in updatedRoutine.dayDataGym) {
      for (final slot in day.slots) {
        for (final config in slot.setConfigs) {
          if (config.exerciseId == oldExerciseId) {
            config.exerciseId = newExercise.id;
            config.exercise = newExercise;
          }
        }
      }
    }
    return updatedRoutine;
  }
}
