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

part 'base_config.g.dart';

@JsonSerializable()
class BaseConfig {
  @JsonKey(required: true, includeToJson: false)
  late int? id;

  @JsonKey(required: true, name: 'slot_entry')
  late int slotEntryId;

  @JsonKey(required: true)
  late int iteration;

  // @JsonKey(required: true)
  // late String trigger;

  @JsonKey(required: true, fromJson: stringOrIntToNum)
  late num value;

  @JsonKey(required: true)
  late String operation;

  @JsonKey(required: true)
  late String step;

  @JsonKey(required: true, name: 'need_log_to_apply')
  late bool needLogToApply;

  @JsonKey(required: true, name: 'repeat')
  late bool repeat;

  @JsonKey(required: true, name: 'requirements')
  late dynamic requirements;

  BaseConfig({
    required this.id,
    required this.slotEntryId,
    required this.iteration,
    this.repeat = false,
    required this.value,
    this.operation = 'r',
    this.step = 'abs',
    this.needLogToApply = false,
    this.requirements = null,
  });

  BaseConfig.firstIteration(this.value, this.slotEntryId) {
    iteration = 1;
    operation = 'r';
    step = 'abs';
    needLogToApply = false;
    requirements = null;
    repeat = false;
  }

  // Boilerplate
  factory BaseConfig.fromJson(Map<String, dynamic> json) => _$BaseConfigFromJson(json);

  Map<String, dynamic> toJson() => _$BaseConfigToJson(this);
}
