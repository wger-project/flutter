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

part 'setting.g.dart';

@JsonSerializable()
class Setting {
  /// Allowed RiR values. This list must be kept in sync with RIR_OPTIONS in the
  /// wger server
  static const POSSIBLE_RIR_VALUES = ['', '0', '0.5', '1', '1.5', '2', '2.5', '3', '3.5', '4'];
  static const DEFAULT_RIR = '';

  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true, name: 'set')
  late int setId;

  @JsonKey(required: true)
  late int order;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late Exercise exerciseObj;

  @JsonKey(required: true, name: 'exercise_base')
  late int exerciseId;

  @JsonKey(required: true, name: 'repetition_unit')
  late int repetitionUnitId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late RepetitionUnit repetitionUnitObj;

  @JsonKey(required: true)
  int? reps;

  @JsonKey(required: true, fromJson: stringToNum, toJson: numToString)
  num? weight;

  @JsonKey(required: true, name: 'weight_unit')
  late int weightUnitId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late WeightUnit weightUnitObj;

  /// Personal notes about this setting. Currently not used
  @JsonKey(required: true)
  late String comment = '';

  /// Reps in Reserve
  @JsonKey(required: true)
  String? rir = '';

  Setting({
    this.id,
    required this.setId,
    required this.order,
    required this.exerciseId,
    required this.repetitionUnitId,
    required this.reps,
    required this.weightUnitId,
    required this.comment,
    required this.rir,
  });

  Setting.empty();

  // Boilerplate
  factory Setting.fromJson(Map<String, dynamic> json) => _$SettingFromJson(json);

  Map<String, dynamic> toJson() => _$SettingToJson(this);

  set exercise(Exercise exercise) {
    exerciseObj = exercise;
    exerciseId = exercise.id!;
  }

  set weightUnit(WeightUnit weightUnit) {
    weightUnitObj = weightUnit;
    weightUnitId = weightUnit.id;
  }

  set repetitionUnit(RepetitionUnit repetitionUnit) {
    repetitionUnitObj = repetitionUnit;
    repetitionUnitId = repetitionUnit.id;
  }

  void setRir(String newRir) {
    if (POSSIBLE_RIR_VALUES.contains(newRir)) {
      rir = newRir;
    } else {
      throw Exception('RiR value not allowed: $newRir');
    }
  }

  /// Returns the text representation for a single setting, used in the gym mode
  String get singleSettingRepText {
    return repText(reps, repetitionUnitObj, weight, weightUnitObj, rir);
  }
}
