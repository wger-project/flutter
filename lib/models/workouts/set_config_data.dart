/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) wger Team
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
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/models/workouts/weight_unit.dart';

part 'set_config_data.g.dart';

@JsonSerializable()
class SetConfigData {
  @JsonKey(required: true, name: 'exercise')
  late int exerciseId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late Exercise exercise;

  @JsonKey(required: true, name: 'slot_entry_id')
  late int slotEntryId;

  @JsonKey(required: true)
  late SlotEntryType type;

  @JsonKey(required: true, name: 'text_repr')
  late String textRepr;

  String get textReprWithType => '$textRepr${type.typeLabel}';

  @JsonKey(required: true, name: 'sets')
  late num? nrOfSets;

  @JsonKey(required: true, name: 'max_sets')
  late num? maxNrOfSets;

  @JsonKey(required: true, fromJson: stringToNumNull)
  late num? weight;

  @JsonKey(required: true, name: 'max_weight', fromJson: stringToNumNull)
  late num? maxWeight;

  @JsonKey(required: true, name: 'weight_unit')
  late int? weightUnitId;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late WeightUnit? weightUnit;

  @JsonKey(required: true, name: 'weight_rounding', fromJson: stringToNumNull)
  late num? weightRounding;

  @JsonKey(required: true, name: 'repetitions', fromJson: stringToNumNull)
  late num? repetitions;

  @JsonKey(required: true, name: 'max_repetitions', fromJson: stringToNumNull)
  late num? maxRepetitions;

  @JsonKey(required: true, name: 'repetitions_unit')
  late int? repetitionsUnitId;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late RepetitionUnit? repetitionsUnit;

  @JsonKey(required: true, name: 'repetitions_rounding', fromJson: stringToNumNull)
  late num? repetitionsRounding;

  @JsonKey(required: true, fromJson: stringToNumNull)
  late num? rir;

  @JsonKey(required: true, name: 'max_rir', fromJson: stringToNumNull)
  late num? maxRir;

  @JsonKey(required: true, fromJson: stringToNumNull)
  late num? rpe;

  @JsonKey(required: true, name: 'rest', fromJson: stringToNumNull)
  late num? restTime;

  @JsonKey(required: true, name: 'max_rest', fromJson: stringToNumNull)
  late num? maxRestTime;

  @JsonKey(required: true)
  late String comment;

  SetConfigData({
    required this.exerciseId,
    required this.slotEntryId,
    this.type = SlotEntryType.normal,
    required this.nrOfSets,
    this.maxNrOfSets,
    required this.weight,
    this.maxWeight,
    this.weightUnitId = WEIGHT_UNIT_KG,
    this.weightRounding,
    required this.repetitions,
    this.maxRepetitions,
    this.repetitionsUnitId = REP_UNIT_REPETITIONS_ID,
    this.repetitionsRounding,
    required this.rir,
    this.maxRir,
    required this.rpe,
    required this.restTime,
    this.maxRestTime,
    this.comment = '',
    this.textRepr = '',
    Exercise? exercise,
    WeightUnit? weightUnit,
    RepetitionUnit? repetitionsUnit,
  }) {
    if (exercise != null) {
      this.exercise = exercise;
    }
    if (weightUnit != null) {
      this.weightUnit = weightUnit;
    }
    if (repetitionsUnit != null) {
      this.repetitionsUnit = repetitionsUnit;
    }
  }

  SetConfigData copyWith({
    int? exerciseId,
    int? slotEntryId,
    SlotEntryType? type,
    String? textRepr,
    num? nrOfSets,
    num? maxNrOfSets,
    num? weight,
    num? maxWeight,
    int? weightUnitId,
    num? weightRounding,
    num? repetitions,
    num? maxRepetitions,
    int? repetitionsUnitId,
    num? repetitionsRounding,
    num? rir,
    num? maxRir,
    num? rpe,
    num? restTime,
    num? maxRestTime,
    String? comment,
    Exercise? exercise,
    WeightUnit? weightUnit,
    RepetitionUnit? repetitionsUnit,
  }) {
    return SetConfigData(
      exerciseId: exerciseId ?? this.exerciseId,
      slotEntryId: slotEntryId ?? this.slotEntryId,
      type: type ?? this.type,
      textRepr: textRepr ?? this.textRepr,
      nrOfSets: nrOfSets ?? this.nrOfSets,
      maxNrOfSets: maxNrOfSets ?? this.maxNrOfSets,
      weight: weight ?? this.weight,
      maxWeight: maxWeight ?? this.maxWeight,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      weightRounding: weightRounding ?? this.weightRounding,
      repetitions: repetitions ?? this.repetitions,
      maxRepetitions: maxRepetitions ?? this.maxRepetitions,
      repetitionsUnitId: repetitionsUnitId ?? this.repetitionsUnitId,
      repetitionsRounding: repetitionsRounding ?? this.repetitionsRounding,
      rir: rir ?? this.rir,
      maxRir: maxRir ?? this.maxRir,
      rpe: rpe ?? this.rpe,
      restTime: restTime ?? this.restTime,
      maxRestTime: maxRestTime ?? this.maxRestTime,
      comment: comment ?? this.comment,
      exercise: exercise ?? this.exercise,
      weightUnit: weightUnit ?? this.weightUnit,
      repetitionsUnit: repetitionsUnit ?? this.repetitionsUnit,
    );
  }

  // Boilerplate
  factory SetConfigData.fromJson(Map<String, dynamic> json) => _$SetConfigDataFromJson(json);

  Map<String, dynamic> toJson() => _$SetConfigDataToJson(this);
}
