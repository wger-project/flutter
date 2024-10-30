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
import 'package:wger/models/workouts/base_config.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/weight_unit.dart';

part 'slot_entry.g.dart';

@JsonSerializable()
class SlotEntry {
  /// Allowed RiR values. This list must be kept in sync with RIR_OPTIONS in the
  /// wger server
  static const POSSIBLE_RIR_VALUES = ['', '0', '0.5', '1', '1.5', '2', '2.5', '3', '3.5', '4'];
  static const DEFAULT_RIR = '';

  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true, name: 'slot')
  late int slotId;

  @JsonKey(required: true)
  late int order;

  @JsonKey(required: true)
  late String type;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late Exercise exerciseObj;

  @JsonKey(required: true, name: 'exercise')
  late int exerciseId;

  @JsonKey(required: true, name: 'repetition_unit')
  late int repetitionUnitId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late RepetitionUnit repetitionUnitObj;

  @JsonKey(required: true, name: 'repetition_rounding')
  late num repetitionRounding;

  @JsonKey(required: true, name: 'reps_configs')
  late List<BaseConfig> repsConfig;

  @JsonKey(required: true, name: 'max_reps_configs')
  late List<BaseConfig> maxRepsConfig;

  @JsonKey(required: true, name: 'weight_unit')
  late int weightUnitId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late WeightUnit weightUnitObj;

  @JsonKey(required: true, name: 'weight_rounding')
  late num weightRounding;

  @JsonKey(required: true, name: 'weight_configs')
  late List<BaseConfig> weightConfigs;

  @JsonKey(required: true, name: 'max_weight_configs')
  late List<BaseConfig> maxWeightConfigs;

  @JsonKey(required: true, name: 'set_nr_configs')
  late List<BaseConfig> setNrConfigs;

  @JsonKey(required: true, name: 'rir_configs')
  late List<BaseConfig> rirConfigs;

  @JsonKey(required: true, name: 'rest_configs')
  late List<BaseConfig> restTimeConfigs;

  @JsonKey(required: true, name: 'max_rest_configs')
  late List<BaseConfig> maxRestTimeConfigs;

  @JsonKey(required: true)
  late String comment = '';

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
  });

  SlotEntry.empty();

  get rir {
    return 'DELETE ME! RIR';
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

  String get singleSettingRepText {
    return 'DELETE singleSettingRepText!';
  }
}
