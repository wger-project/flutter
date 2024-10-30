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

  @JsonKey(required: true)
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<SlotEntry> entries = [];

  /// Computed settings (instead of 4x10 this has [10, 10, 10, 10]), used for
  /// the gym mode where the individual values are used
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<SlotEntry> settingsComputed = [];

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
    sets,
    day,
    comment,
    order,
    exercises,
    settings,
    settingsComputed,
  }) {
    this.order = order ?? 1;
    this.comment = comment ?? '';
    exercisesObj = exercises ?? [];
    exercisesIds = exercisesObj.map((e) => e.id!).toList();
    this.entries = settings ?? [];
    this.settingsComputed = settingsComputed ?? [];
    if (day != null) {
      this.day = day;
    }
  }

  /// Return only one setting object per exercise, this makes rendering workout
  /// plans easier and the gym mode uses the synthetic settings anyway.
  List<SlotEntry> get settingsFiltered {
    final List<SlotEntry> out = [];

    for (final setting in entries) {
      final foundSettings = out.where(
        (element) => element.exerciseId == setting.exerciseId,
      );

      if (foundSettings.isEmpty) {
        out.add(setting);
      }
    }
    return out;
  }

  void addExerciseBase(Exercise base) {
    exercisesObj.add(base);
    exercisesIds.add(base.id!);
  }

  void removeExercise(Exercise base) {
    exercisesObj.removeWhere((e) => e.id == base.id);
    exercisesIds.removeWhere((e) => e == base.id);
  }

  /// Returns all settings for the given exercise
  List<SlotEntry> filterSettingsByExercise(Exercise exerciseBase) {
    return entries.where((element) => element.exerciseId == exerciseBase.id).toList();
  }

  /// Returns a list with all repetitions for the given exercise
  List<String> getSmartRepr(Exercise exerciseBase) {
    final List<String> out = [];

    final settingList = filterSettingsByExercise(exerciseBase);

    if (settingList.isEmpty) {
      out.add('');
    }

    if (settingList.length == 1) {
      out.add(settingList.first.singleSettingRepText.replaceAll('\n', ''));
    }

    if (settingList.length > 1) {
      for (final setting in settingList) {
        out.add(setting.singleSettingRepText.replaceAll('\n', ''));
      }
    }

    return out;
  }

  /// Returns a string with all repetitions for the given exercise
  String getSmartTextRepr(Exercise exerciseBase) {
    return getSmartRepr(exerciseBase).join(' – ');
  }

  // Boilerplate
  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);

  Map<String, dynamic> toJson() => _$SlotToJson(this);
}
