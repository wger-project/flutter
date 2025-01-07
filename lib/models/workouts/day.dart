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
import 'package:wger/models/workouts/slot.dart';

part 'day.g.dart';

@JsonSerializable()
class Day {
  static const MIN_LENGTH_NAME = 3;
  static const MAX_LENGTH_NAME = 20;
  static const MAX_LENGTH_DESCRIPTION = 1000;

  @JsonKey(required: true, includeToJson: false)
  int? id;

  @JsonKey(required: true, name: 'routine')
  late int routineId;

  @JsonKey(required: true)
  late String name;

  @JsonKey(required: true)
  late String description;

  @JsonKey(required: true, name: 'is_rest')
  late bool isRest;

  @JsonKey(required: true, name: 'need_logs_to_advance')
  late bool needLogsToAdvance;

  @JsonKey(required: true)
  late String type;

  @JsonKey(required: true)
  late num order;

  @JsonKey(required: true)
  late Object? config;

  @JsonKey(required: false, defaultValue: [], includeFromJson: true, includeToJson: false)
  List<Slot> slots = [];

  Day({
    this.id,
    required this.routineId,
    required this.name,
    required this.description,
    this.isRest = false,
    this.needLogsToAdvance = false,
    this.type = 'custom',
    this.order = 0,
    this.config = null,
    this.slots = const [],
  });

  Day.empty() {
    name = 'new day';
    description = '';
    type = 'custom';
    isRest = false;
    needLogsToAdvance = false;
    order = 0;
    config = {};
    slots = [];
  }

  // Boilerplate
  factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);

  Map<String, dynamic> toJson() => _$DayToJson(this);
}
