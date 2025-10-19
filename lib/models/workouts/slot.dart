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
import 'package:wger/models/workouts/slot_entry.dart';

part 'slot.g.dart';

@JsonSerializable()
class Slot {
  static const DEFAULT_NR_SETS = 4;

  @JsonKey(required: true, includeToJson: false)
  int? id;

  @JsonKey(required: false)
  late int day;

  @JsonKey(required: true)
  late int order;

  @JsonKey(required: true, defaultValue: '')
  late String comment;

  @JsonKey(required: true)
  late Object? config;

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Exercise> exercisesObj = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<int> exercisesIds = [];

  @JsonKey(required: false, includeFromJson: true, defaultValue: [], includeToJson: false)
  List<SlotEntry> entries = [];

  Slot({
    required this.id,
    required this.day,
    required this.comment,
    required this.order,
    required this.config,
  });

  Slot.empty();

  Slot.withData({
    this.id,
    int? day,
    String? comment,
    int? order,
    List<Exercise>? exercises,
    List<SlotEntry>? entries,
  }) {
    this.order = order ?? 1;
    this.comment = comment ?? '';
    config = null;
    exercisesObj = exercises ?? [];
    exercisesIds = exercisesObj.map((e) => e.id!).toList();
    entries = entries ?? [];
    if (day != null) {
      this.day = day;
    }
  }

  void addExerciseBase(Exercise base) {
    exercisesObj.add(base);
    exercisesIds.add(base.id!);
  }

  void removeExercise(Exercise base) {
    exercisesObj.removeWhere((e) => e.id == base.id);
    exercisesIds.removeWhere((e) => e == base.id);
  }

  bool get isSuperset {
    return exercisesObj.length > 1;
  }

  // Boilerplate
  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);

  Map<String, dynamic> toJson() => _$SlotToJson(this);
}
