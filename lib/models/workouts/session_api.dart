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
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/session.dart';

part 'session_api.g.dart';

@JsonSerializable()
class WorkoutSessionApi {
  @JsonKey(required: true, name: 'session')
  late WorkoutSession session;

  @JsonKey(required: false, includeToJson: false, defaultValue: [])
  List<Log> logs = [];

  WorkoutSessionApi({required this.session, this.logs = const []});

  /// Returns all different exercises in the session
  ///
  /// This is used to display the exercises in the session
  List<Exercise> get exercises {
    final Set<Exercise> exerciseSet = {};
    for (final log in logs) {
      exerciseSet.add(log.exercise);
    }
    return exerciseSet.toList();
  }

  /// Get total volume of the session for metric and imperial units
  /// (i.e. sets that have "repetitions" as units and weight in kg or lbs).
  /// Other combinations such as "seconds" are ignored.
  Map<String, num> get volume {
    final volumeMetric = logs.fold<double>(0, (sum, log) => sum + log.volume(metric: true));
    final volumeImperial = logs.fold<double>(0, (sum, log) => sum + log.volume(metric: false));

    return {'metric': volumeMetric, 'imperial': volumeImperial};
  }

  // Boilerplate
  factory WorkoutSessionApi.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionApiFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSessionApiToJson(this);
}
