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
import 'package:wger/helpers/misc.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/weight_unit.dart';

part 'log.g.dart';

@JsonSerializable()
class Log {
  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true, name: 'exercise')
  late int exerciseId;

  @JsonKey(ignore: true)
  late Exercise exerciseObj;

  @JsonKey(required: true, name: 'workout')
  late int workoutPlan;

  @JsonKey(required: true)
  late int reps;

  @JsonKey(required: false)
  String? rir;

  @JsonKey(required: true, name: 'repetition_unit')
  late int repetitionUnitId;

  @JsonKey(ignore: true)
  late RepetitionUnit repetitionUnitObj;

  @JsonKey(required: true, fromJson: stringToNum, toJson: numToString)
  late num weight;

  @JsonKey(required: true, name: 'weight_unit')
  late int weightUnitId;

  @JsonKey(ignore: true)
  late WeightUnit weightUnitObj;

  @JsonKey(required: true, toJson: toDate)
  late DateTime date;

  //@JsonKey(required: true)
  //String comment;

  Log({
    this.id,
    required this.exerciseId,
    required this.workoutPlan,
    required this.reps,
    required this.rir,
    required this.repetitionUnitId,
    required this.weight,
    required this.weightUnitId,
    required this.date,
  });

  Log.empty();

  // Boilerplate
  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);
  Map<String, dynamic> toJson() => _$LogToJson(this);

  set exercise(Exercise exercise) {
    this.exerciseObj = exercise;
    this.exerciseId = exercise.id;
  }

  set weightUnit(WeightUnit weightUnit) {
    this.weightUnitObj = weightUnit;
    this.weightUnitId = weightUnit.id;
  }

  set repetitionUnit(RepetitionUnit repetitionUnit) {
    this.repetitionUnitObj = repetitionUnit;
    this.repetitionUnitId = repetitionUnit.id;
  }

  void setRir(String rir) {
    this.rir = rir;
  }

  /// Returns the text representation for a single setting, used in the gym mode
  String get singleLogRepText {
    return repText(reps, repetitionUnitObj, weight, weightUnitObj, rir);
  }
}
