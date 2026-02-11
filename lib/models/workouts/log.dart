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

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/i18n.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/weight_unit.dart';

part 'log.g.dart';

enum LogTargetStatus {
  lessThanTarget,
  atTarget,
  moreThanTarget,
  notSet,
}

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
  int? sessionId;

  @JsonKey(required: true)
  int? iteration;

  @JsonKey(required: true, name: 'slot_entry')
  int? slotEntryId;

  @JsonKey(required: false, fromJson: stringToNumNull)
  num? rir;

  @JsonKey(required: false, fromJson: stringToNumNull, name: 'rir_target')
  num? rirTarget;

  @JsonKey(required: true, fromJson: stringToNumNull, name: 'repetitions')
  num? repetitions;

  @JsonKey(required: true, fromJson: stringToNumNull, name: 'repetitions_target')
  num? repetitionsTarget;

  @JsonKey(required: true, name: 'repetitions_unit')
  int? repetitionsUnitId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  RepetitionUnit? repetitionsUnitObj;

  @JsonKey(required: true, fromJson: stringToNumNull, toJson: numToString)
  num? weight;

  @JsonKey(required: true, fromJson: stringToNumNull, toJson: numToString, name: 'weight_target')
  num? weightTarget;

  @JsonKey(required: true, name: 'weight_unit')
  int? weightUnitId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  WeightUnit? weightUnitObj;

  @JsonKey(required: true, fromJson: utcIso8601ToLocalDate, toJson: dateToUtcIso8601)
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
    this.repetitionsUnitObj,
    this.rir,
    this.rirTarget,
    this.weight,
    this.weightTarget,
    this.weightUnitId = WEIGHT_UNIT_KG,
    this.weightUnitObj,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Log.fromSetConfigData(SetConfigData setConfig) {
    date = DateTime.now();
    sessionId = null;

    slotEntryId = setConfig.slotEntryId;
    exerciseBase = setConfig.exercise;

    weight = setConfig.weight;
    weightTarget = setConfig.weight;
    weightUnit = setConfig.weightUnit;

    repetitions = setConfig.repetitions;
    repetitionsTarget = setConfig.repetitions;
    repetitionUnit = setConfig.repetitionsUnit;

    rir = setConfig.rir;
    rirTarget = setConfig.rir;
  }

  Log copyWith({
    int? id,
    int? exerciseId,
    int? routineId,
    int? sessionId,
    int? iteration,
    int? slotEntryId,
    num? rir,
    num? rirTarget,
    num? repetitions,
    num? repetitionsTarget,
    int? repetitionsUnitId,
    RepetitionUnit? repetitionsUnitObj,
    num? weight,
    num? weightTarget,
    int? weightUnitId,
    WeightUnit? weightUnitObj,
    DateTime? date,
  }) {
    final out = Log(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      iteration: iteration ?? this.iteration,
      slotEntryId: slotEntryId ?? this.slotEntryId,
      routineId: routineId ?? this.routineId,
      repetitions: repetitions ?? this.repetitions,
      repetitionsTarget: repetitionsTarget ?? this.repetitionsTarget,
      repetitionsUnitId: repetitionsUnitId ?? this.repetitionsUnitId,
      repetitionsUnitObj: repetitionsUnitObj ?? this.repetitionsUnitObj,
      rir: rir ?? this.rir,
      rirTarget: rirTarget ?? this.rirTarget,
      weight: weight ?? this.weight,
      weightTarget: weightTarget ?? this.weightTarget,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      weightUnitObj: weightUnitObj ?? this.weightUnitObj,
      date: date ?? this.date,
    );

    if (sessionId != null) {
      out.sessionId = sessionId;
    }

    if (repetitionsUnitObj != null) {
      out.repetitionsUnitObj = repetitionsUnitObj;
      out.repetitionsUnitId = repetitionsUnitObj.id;
    }

    if (weightUnitObj != null) {
      out.weightUnitObj = weightUnitObj;
      out.weightUnitId = weightUnitObj.id;
    }
    out.exerciseBase = exercise;

    return out;
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

  /// Returns the text representation for a single setting, removes new lines
  String repTextNoNl(BuildContext context) {
    return repText(context).replaceAll('\n', '');
  }

  /// Returns the text representation for a single setting
  String repText(BuildContext context) {
    final List<String> out = [];

    if (repetitions != null) {
      out.add(formatNum(repetitions!).toString());

      // The default repetition unit is 'reps', which we don't show unless there
      // is no weight defined so that we don't just output something like "8" but
      // rather "8 repetitions". If there is weight we want to output "8 x 50kg",
      // since the repetitions are implied. If other units are used, we always
      // print them
      if (repetitionsUnitObj != null && repetitionsUnitObj!.id != REP_UNIT_REPETITIONS_ID ||
          weight == 0 ||
          weight == null) {
        out.add(getServerStringTranslation(repetitionsUnitObj!.name, context));
      }
    }

    if (weight != null && weight != 0) {
      out.add('×');
      out.add(formatNum(weight!).toString());
      out.add(weightUnitObj!.name);
    }

    if (rir != null) {
      out.add('\n($rir RiR)');
    }

    return out.join(' ');
  }

  /// Calculates the volume for this log entry
  num volume({bool metric = true}) {
    final unitId = metric ? WEIGHT_UNIT_KG : WEIGHT_UNIT_LB;

    if (weight != null &&
        weightUnitId == unitId &&
        repetitions != null &&
        repetitionsUnitId == REP_UNIT_REPETITIONS_ID) {
      return weight! * repetitions!;
    }
    return 0;
  }

  LogTargetStatus get targetStatus {
    if (weightTarget == null && repetitionsTarget == null && rirTarget == null) {
      return LogTargetStatus.notSet;
    }

    final weightOk = weightTarget == null || (weight != null && weight! >= weightTarget!);
    final repsOk =
        repetitionsTarget == null || (repetitions != null && repetitions! >= repetitionsTarget!);
    final rirOk = rirTarget == null || (rir != null && rir! <= rirTarget!);

    if (weightOk && repsOk && rirOk) {
      return LogTargetStatus.atTarget;
    }

    final weightMore = weightTarget != null && weight != null && weight! > weightTarget!;
    final repsMore =
        repetitionsTarget != null && repetitions != null && repetitions! > repetitionsTarget!;
    final rirLess = rirTarget != null && rir != null && rir! < rirTarget!;

    if (weightMore || repsMore || rirLess) {
      return LogTargetStatus.moreThanTarget;
    }

    return LogTargetStatus.lessThanTarget;
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
