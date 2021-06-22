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
import 'package:wger/models/workouts/setting.dart';

part 'set.g.dart';

@JsonSerializable()
class Set {
  static const DEFAULT_NR_SETS = 4;

  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true)
  late int sets;

  @JsonKey(required: false, name: 'exerciseday')
  late int day;

  @JsonKey(required: true)
  int? order;

  @JsonKey(ignore: true)
  List<Exercise> exercisesObj = [];

  @JsonKey(ignore: true)
  List<int> exercisesIds = [];

  @JsonKey(ignore: true)
  List<Setting> settings = [];

  /// Computed settings (instead of 4x10 this has [10, 10, 10, 10]), used for
  /// the gym mode where the individual values are used
  @JsonKey(ignore: true)
  List<Setting> settingsComputed = [];

  Set({
    required this.day,
    required this.sets,
    this.order,
  });

  Set.empty();

  Set.withData({
    this.id,
    sets,
    day,
    order,
    exercises,
    settings,
    settingsComputed,
  }) {
    this.sets = sets ?? DEFAULT_NR_SETS;
    this.order = order ?? 1;
    this.exercisesObj = exercises ?? [];
    this.exercisesIds = exercisesObj.map((e) => e.id).toList();
    this.settings = settings ?? [];
    this.settingsComputed = settingsComputed ?? [];
    if (day != null) {
      this.day = day;
    }
  }

  /// Return only one setting object per exercise, this makes rendering workout
  /// plans easier and the gym mode uses the synthetic settings anyway.
  List<Setting> get settingsFiltered {
    List<Setting> out = [];

    settings.forEach((setting) {
      final foundSettings = out.where(
        (element) => element.exerciseId == setting.exerciseId,
      );

      if (foundSettings.length == 0) {
        out.add(setting);
      }
    });
    return out;
  }

  void addExercise(Exercise exercise) {
    exercisesObj.add(exercise);
    exercisesIds.add(exercise.id);
  }

  void removeExercise(Exercise exercise) {
    exercisesObj.removeWhere((e) => e.id == exercise.id);
    exercisesIds.removeWhere((e) => e == exercise.id);
  }

  /// Returns all settings for the given exercise
  List<Setting> filterSettingsByExercise(Exercise exercise) {
    return settings.where((element) => element.exerciseId == exercise.id).toList();
  }

  /// Returns a list with all repetitions for the given exercise
  List<String> getSmartRepr(Exercise exercise) {
    List<String> out = [];

    final settingList = filterSettingsByExercise(exercise);

    if (settingList.length == 0) {
      out.add('');
    }

    if (settingList.length == 1) {
      out.add(settingList.first.singleSettingRepText.replaceAll('\n', ''));
    }

    if (settingList.length > 1) {
      for (var setting in settingList) {
        out.add(setting.singleSettingRepText.replaceAll('\n', ''));
      }
    }

    return out;
  }

  /// Returns a string with all repetitions for the given exercise
  String getSmartTextRepr(Exercise exercise) {
    return getSmartRepr(exercise).join(' – ');
  }

  // Boilerplate
  factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);
  Map<String, dynamic> toJson() => _$SetToJson(this);
}
