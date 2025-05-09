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
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/weight_unit.dart';

part 'log.g.dart';

@JsonSerializable()
class Log {
  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true, name: 'exercise')
  late int exerciseId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late Exercise exercise;

  @JsonKey(required: true, name: 'routine')
  late int routineId;

  @JsonKey(required: true, name: 'session')
  late int? sessionId;

  @JsonKey(required: true)
  int? iteration;

  @JsonKey(required: true, name: 'slot_entry')
  int? slotEntryId;

  @JsonKey(required: false, fromJson: stringToNum)
  num? rir;

  @JsonKey(required: false, fromJson: stringToNum, name: 'rir_target')
  num? rirTarget;

  @JsonKey(required: true, fromJson: stringToNum, name: 'repetitions')
  num? repetitions;

  @JsonKey(required: true, fromJson: stringToNum, name: 'repetitions_target')
  num? repetitionsTarget;

  @JsonKey(required: true, name: 'repetitions_unit')
  late int? repetitionsUnitId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late RepetitionUnit? repetitionsUnitObj;

  @JsonKey(required: true, fromJson: stringToNum, toJson: numToString)
  late num? weight;

  @JsonKey(required: true, fromJson: stringToNum, toJson: numToString, name: 'weight_target')
  num? weightTarget;

  @JsonKey(required: true, name: 'weight_unit')
  late int? weightUnitId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late WeightUnit? weightUnitObj;

  @JsonKey(required: true, toJson: dateToYYYYMMDDHHMM)
  late DateTime date;

  Log({
    this.id,
    required this.exerciseId,
    this.iteration,
    this.slotEntryId,
    required this.routineId,
    this.repetitions,
    this.repetitionsTarget,
    this.repetitionsUnitId = REP_UNIT_REPETITIONS_ID,
    required this.rir,
    this.rirTarget,
    this.weight,
    this.weightTarget,
    this.weightUnitId = WEIGHT_UNIT_KG,
    required this.date,
  });

  Log.empty();

  Log.fromSetConfigData(SetConfigData data) {
    date = DateTime.now();
    sessionId = null;
    slotEntryId = data.slotEntryId;
    exerciseBase = data.exercise;

    weight = data.weight;
    weightTarget = data.weight;
    weightUnit = data.weightUnit;

    repetitions = data.repetitions;
    repetitionsTarget = data.repetitions;
    repetitionUnit = data.repetitionsUnit;

    rir = data.rir;
    rirTarget = data.rir;
  }

  // Boilerplate
  factory Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);

  Map<String, dynamic> toJson() => _$LogToJson(this);

  set exerciseBase(Exercise base) {
    exercise = base;
    exerciseId = base.id!;
  }

  set weightUnit(WeightUnit? weightUnit) {
    weightUnitObj = weightUnit;
    weightUnitId = weightUnit?.id;
  }

  set repetitionUnit(RepetitionUnit? repetitionUnit) {
    repetitionsUnitObj = repetitionUnit;
    repetitionsUnitId = repetitionUnit?.id;
  }

  /// Returns the text representation for a single setting, used in the gym mode
  String get singleLogRepTextNoNl {
    return repText(repetitions, repetitionsUnitObj, weight, weightUnitObj, rir)
        .replaceAll('\n', '');
  }

  /// Override the equals operator
  ///
  /// Two logs are considered equal if their content is equal. This is used e.g.
  /// in lists where we want to have unique values
  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(o) {
    return o is Log &&
        exerciseId == o.exerciseId &&
        weight == o.weight &&
        weightUnitId == o.weightUnitId &&
        repetitions == o.repetitions &&
        repetitionsUnitId == o.repetitionsUnitId &&
        rir == o.rir;
  }

  @override
  //ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode =>
      Object.hash(exerciseId, weight, weightUnitId, repetitions, repetitionsUnitId, rir);

  //@override
  //int get hashCode => super.hashCode;

  @override
  String toString() {
    return 'Log(id: $id, ex: $exerciseId, weightU: $weightUnitId, w: $weight, repU: $repetitionsUnitId, rep: $repetitions, rir: $rir)';
  }
}
