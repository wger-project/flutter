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
import 'package:wger/helpers/json.dart';
import 'package:wger/models/exercises/exercise.dart';

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
  late String type;

  @JsonKey(required: true, name: 'sets')
  late num? nrOfSets;

  @JsonKey(required: true, fromJson: stringToNumNull)
  late num? weight;

  @JsonKey(required: true, name: 'max_weight', fromJson: stringToNumNull)
  late num? maxWeight;

  @JsonKey(required: true, name: 'weight_unit')
  late int? weightUnitId;

  @JsonKey(required: true, name: 'weight_rounding', fromJson: stringToNumNull)
  late num? weightRounding;

  @JsonKey(required: true, fromJson: stringToNumNull)
  late num? reps;

  @JsonKey(required: true, name: 'max_reps', fromJson: stringToNumNull)
  late num? maxReps;

  @JsonKey(required: true, name: 'reps_unit')
  late int? repsUnitId;

  @JsonKey(required: true, name: 'reps_rounding', fromJson: stringToNumNull)
  late num? repsRounding;

  @JsonKey(required: true)
  late String? rir;

  @JsonKey(required: true)
  late String? rpe;

  @JsonKey(required: true, name: 'rest', fromJson: stringToNum)
  late num? restTime;

  @JsonKey(required: true, name: 'max_rest', fromJson: stringToNum)
  late num? maxRestTime;

  @JsonKey(required: true)
  late String comment;

  SetConfigData({
    required this.exerciseId,
    required this.slotEntryId,
    required this.type,
    required this.weight,
    required this.weightUnitId,
    required this.weightRounding,
    required this.reps,
    required this.maxReps,
    required this.repsUnitId,
    required this.repsRounding,
    required this.rir,
    required this.rpe,
    required this.restTime,
    required this.maxRestTime,
    required this.comment,
  });

  // Boilerplate
  factory SetConfigData.fromJson(Map<String, dynamic> json) => _$SetConfigDataFromJson(json);

  Map<String, dynamic> toJson() => _$SetConfigDataToJson(this);
}
