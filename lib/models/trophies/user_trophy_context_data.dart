/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2025 wger Team
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

part 'user_trophy_context_data.g.dart';

/// A trophy awarded to a user for achieving a specific milestone.

@JsonSerializable()
class ContextData {
  @JsonKey(required: true, name: 'log_id')
  final int logId;

  @JsonKey(required: true, fromJson: utcIso8601ToLocalDate)
  final DateTime date;

  @JsonKey(required: true, name: 'session_id')
  final int sessionId;

  @JsonKey(required: true, name: 'exercise_id')
  final int exerciseId;

  @JsonKey(required: true, name: 'repetitions_unit_id')
  final int repetitionsUnitId;

  @JsonKey(required: true)
  final num repetitions;

  @JsonKey(required: true, name: 'weight_unit_id')
  final int weightUnitId;

  @JsonKey(required: true)
  final num weight;

  @JsonKey(required: true)
  final int? iteration;

  @JsonKey(required: true, name: 'one_rep_max_estimate')
  final num oneRepMaxEstimate;

  ContextData({
    required this.logId,
    required this.date,
    required this.sessionId,
    required this.exerciseId,
    required this.repetitionsUnitId,
    required this.repetitions,
    required this.weightUnitId,
    required this.weight,
    this.iteration,
    required this.oneRepMaxEstimate,
  });

  // Boilerplate
  factory ContextData.fromJson(Map<String, dynamic> json) => _$ContextDataFromJson(json);

  Map<String, dynamic> toJson() => _$ContextDataToJson(this);
}
