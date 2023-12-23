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

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/exercises/video.dart';

part 'base.g.dart';

@JsonSerializable(explicitToJson: true)
class ExerciseBase extends Equatable {
  @JsonKey(required: true)
  final int? id;

  @JsonKey(required: true)
  final String? uuid;

  @JsonKey(required: true, name: 'variations')
  final int? variationId;

  @JsonKey(required: true, name: 'created')
  final DateTime? created;

  @JsonKey(required: true, name: 'last_update')
  final DateTime? lastUpdate;

  @JsonKey(required: true, name: 'category')
  late int categoryId;

  @JsonKey(includeFromJson: true, includeToJson: true, name: 'categories')
  ExerciseCategory? category;

  @JsonKey(required: true, name: 'muscles')
  List<int> musclesIds = [];

  @JsonKey(includeFromJson: false, includeToJson: true, name: 'muscless')
  List<Muscle> muscles = [];

  @JsonKey(required: true, name: 'muscles_secondary')
  List<int> musclesSecondaryIds = [];

  @JsonKey(includeFromJson: false, includeToJson: true)
  List<Muscle> musclesSecondary = [];

  @JsonKey(required: true, name: 'equipment')
  List<int> equipmentIds = [];

  @JsonKey(includeFromJson: false, includeToJson: true, name: 'equipments')
  List<Equipment> equipment = [];

  @JsonKey(includeFromJson: false, includeToJson: true)
  List<ExerciseImage> images = [];

  @JsonKey(includeFromJson: true, includeToJson: true)
  List<Translation> translations = [];

  @JsonKey(includeFromJson: false, includeToJson: true)
  List<Video> videos = [];

  ExerciseBase({
    this.id,
    this.uuid,
    this.created,
    this.lastUpdate,
    this.variationId,
    List<Muscle>? muscles,
    List<Muscle>? musclesSecondary,
    List<Equipment>? equipment,
    List<ExerciseImage>? images,
    List<Translation>? exercises,
    ExerciseCategory? category,
    List<Video>? videos,
  }) {
    this.images = images ?? [];
    this.equipment = equipment ?? [];
    if (category != null) {
      this.category = category;
      categoryId = category.id;
    }

    if (muscles != null) {
      this.muscles = muscles;
      musclesIds = muscles.map((e) => e.id).toList();
    }

    if (musclesSecondary != null) {
      this.musclesSecondary = musclesSecondary;
      musclesSecondaryIds = musclesSecondary.map((e) => e.id).toList();
    }

    if (equipment != null) {
      this.equipment = equipment;
      equipmentIds = equipment.map((e) => e.id).toList();
    }

    if (exercises == null) {
      print("Exercises are NULL");
    }

    if (exercises != null) {
      translations = exercises;
    }

    if (videos != null) {
      this.videos = videos;
    }
  }

  /// Returns exercises for the given language
  ///
  /// If no translation is found, English will be returned
  ///
  /// Note: we return the first translation as a fallback if we don't find a
  ///       translation in English. This is something that should never happen,
  ///       but we can't make sure that no local installation hasn't deleted
  ///       the entry in English.
  Translation getExercise(String language) {
    // If the language is in the form en-US, take the language code only
    final languageCode = language.split('-')[0];

    return translations.firstWhere(
      (e) => e.languageObj.shortName == languageCode,
      orElse: () => translations.firstWhere(
        (e) => e.languageObj.shortName == LANGUAGE_SHORT_ENGLISH,
        orElse: () => Translation(name: "name", description: "description"),
      ),
    );
  }

  ExerciseImage? get getMainImage {
    try {
      return images.firstWhere((image) => image.isMain);
    } on StateError {
      return null;
    }
  }

  set setCategory(ExerciseCategory category) {
    categoryId = category.id;
    this.category = category;
  }

  // Boilerplate
  factory ExerciseBase.fromJson(Map<String, dynamic> json) => _$ExerciseBaseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseBaseToJson(this);

  @override
  List<Object?> get props => [
        id,
        uuid,
        created,
        lastUpdate,
        category,
        equipment,
        muscles,
        musclesSecondary,
      ];
}
