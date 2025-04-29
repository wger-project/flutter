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
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/base_config.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/weight_unit.dart';

part 'slot_entry.g.dart';

enum ConfigType {
  weight,
  maxWeight,
  repetitions,
  maxRepetitions,
  sets,
  maxSets,
  rir,
  maxRir,
  rest,
  maxRest,
}

@JsonSerializable()
class SlotEntry {
  /// Allowed RiR values. This list must be kept in sync with RIR_OPTIONS in the
  /// wger server
  static const POSSIBLE_RIR_VALUES = ['', 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5];
  static const DEFAULT_RIR = '';

  @JsonKey(required: true, includeToJson: false)
  int? id;

  @JsonKey(required: true, name: 'slot')
  late int slotId;

  @JsonKey(required: true)
  late int order;

  @JsonKey(required: true)
  late String comment;

  @JsonKey(required: true)
  late String type;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late Exercise exerciseObj;

  @JsonKey(required: true, name: 'exercise')
  late int exerciseId;

  @JsonKey(required: true, name: 'repetition_unit')
  late int? repetitionUnitId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late RepetitionUnit? repetitionUnitObj;

  @JsonKey(required: true, name: 'repetition_rounding', fromJson: stringToNum)
  late num repetitionRounding;

  @JsonKey(required: false, name: 'repetitions_configs', includeToJson: false, defaultValue: [])
  late List<BaseConfig> repetitionsConfigs = [];

  @JsonKey(required: false, name: 'max_repetitions_configs', includeToJson: false, defaultValue: [])
  late List<BaseConfig> maxRepetitionsConfigs = [];

  @JsonKey(required: true, name: 'weight_unit')
  late int? weightUnitId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late WeightUnit? weightUnitObj;

  @JsonKey(required: true, name: 'weight_rounding', fromJson: stringToNum)
  late num weightRounding;

  @JsonKey(required: false, name: 'weight_configs', includeToJson: false, defaultValue: [])
  late List<BaseConfig> weightConfigs = [];

  @JsonKey(required: false, name: 'max_weight_configs', includeToJson: false, defaultValue: [])
  late List<BaseConfig> maxWeightConfigs = [];

  @JsonKey(required: false, name: 'set_nr_configs', includeToJson: false, defaultValue: [])
  late List<BaseConfig> nrOfSetsConfigs = [];

  @JsonKey(required: false, name: 'max_set_nr_configs', includeToJson: false, defaultValue: [])
  late List<BaseConfig> maxNrOfSetsConfigs = [];

  @JsonKey(required: false, name: 'rir_configs', includeToJson: false, defaultValue: [])
  late List<BaseConfig> rirConfigs = [];

  @JsonKey(required: false, name: 'max_rir_configs', includeToJson: false, defaultValue: [])
  late List<BaseConfig> maxRirConfigs = [];

  @JsonKey(required: false, name: 'rest_configs', includeToJson: false, defaultValue: [])
  late List<BaseConfig> restTimeConfigs = [];

  @JsonKey(required: false, name: 'max_rest_configs', includeToJson: false, defaultValue: [])
  late List<BaseConfig> maxRestTimeConfigs = [];

  @JsonKey(required: true)
  late Object? config;

  SlotEntry({
    this.id,
    required this.slotId,
    required this.order,
    required this.type,
    required this.exerciseId,
    required this.repetitionUnitId,
    required this.repetitionRounding,
    required this.weightUnitId,
    required this.weightRounding,
    required this.comment,
    this.weightConfigs = const [],
    this.maxWeightConfigs = const [],
    this.nrOfSetsConfigs = const [],
    this.maxNrOfSetsConfigs = const [],
    this.rirConfigs = const [],
    this.maxRirConfigs = const [],
    this.restTimeConfigs = const [],
    this.maxRestTimeConfigs = const [],
    this.repetitionsConfigs = const [],
    this.maxRepetitionsConfigs = const [],
    RepetitionUnit? repetitionUnit,
    WeightUnit? weightUnit,
    Exercise? exercise,
  }) {
    if (repetitionUnit != null) {
      repetitionUnitObj = repetitionUnit;
    }
    if (weightUnit != null) {
      weightUnitObj = weightUnit;
    }
    if (exercise != null) {
      exerciseObj = exercise;
    }
  }

  SlotEntry.empty();

  SlotEntry.withData({
    required this.slotId,
    String? comment,
    int? order,
    String? type,
    required Exercise exercise,
    int? weightUnitId,
    num? weightRounding,
    int? repetitionUnitId,
    num? repetitionRounding,
  }) {
    this.order = order ?? 1;
    this.comment = comment ?? '';
    config = null;
    this.type = type ?? 'normal';
    exerciseObj = exercise;
    exerciseId = exercise.id!;
    this.weightUnitId = weightUnitId ?? WEIGHT_UNIT_KG;
    this.weightRounding = weightRounding ?? 2.5;

    this.repetitionUnitId = repetitionUnitId ?? REP_UNIT_REPETITIONS_ID;
    this.repetitionRounding = repetitionRounding ?? 1;
  }

  get rir {
    return 'DELETE ME! RIR';
  }

  bool get hasProgressionRules {
    return weightConfigs.length > 1 ||
        repetitionsConfigs.length > 1 ||
        maxRepetitionsConfigs.length > 1 ||
        nrOfSetsConfigs.length > 1 ||
        maxNrOfSetsConfigs.length > 1 ||
        rirConfigs.length > 1 ||
        maxRirConfigs.length > 1 ||
        restTimeConfigs.length > 1 ||
        maxRestTimeConfigs.length > 1 ||
        maxWeightConfigs.length > 1 ||
        maxWeightConfigs.length > 1;
  }

  List<BaseConfig> getConfigsByType(ConfigType type) {
    switch (type) {
      case ConfigType.weight:
        return weightConfigs;
      case ConfigType.maxWeight:
        return maxWeightConfigs;
      case ConfigType.sets:
        return nrOfSetsConfigs;
      case ConfigType.maxSets:
        return maxNrOfSetsConfigs;
      case ConfigType.repetitions:
        return repetitionsConfigs;
      case ConfigType.maxRepetitions:
        return maxRepetitionsConfigs;
      case ConfigType.rir:
        return rirConfigs;
      case ConfigType.maxRir:
        return maxRirConfigs;
      case ConfigType.rest:
        return restTimeConfigs;
      case ConfigType.maxRest:
        return maxRestTimeConfigs;
    }
  }

  // Boilerplate
  factory SlotEntry.fromJson(Map<String, dynamic> json) => _$SlotEntryFromJson(json);

  Map<String, dynamic> toJson() => _$SlotEntryToJson(this);

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
}
