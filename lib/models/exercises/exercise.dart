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
import 'package:wger/models/exercises/exercise_api.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/exercises/video.dart';

part 'exercise.g.dart';

@JsonSerializable(explicitToJson: true)
class Exercise extends Equatable {
  @JsonKey(required: true)
  late final int? id;

  @JsonKey(required: true)
  late final String? uuid;

  @JsonKey(required: true, name: 'variations')
  late final int? variationId;

  @JsonKey(required: true, name: 'created')
  late final DateTime? created;

  @JsonKey(required: true, name: 'last_update')
  late final DateTime? lastUpdate;

  @JsonKey(required: true, name: 'last_update_global')
  late final DateTime? lastUpdateGlobal;

  @JsonKey(required: true, name: 'category')
  late int categoryId;

  @JsonKey(includeFromJson: true, includeToJson: true, name: 'categories')
  ExerciseCategory? category;

  @JsonKey(required: true, name: 'muscles')
  List<int> musclesIds = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Muscle> muscles = [];

  @JsonKey(required: true, name: 'muscles_secondary')
  List<int> musclesSecondaryIds = [];

  @JsonKey(includeFromJson: false, includeToJson: true)
  List<Muscle> musclesSecondary = [];

  @JsonKey(required: true, name: 'equipment')
  List<int> equipmentIds = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Equipment> equipment = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ExerciseImage> images = [];

  @JsonKey(includeFromJson: true, includeToJson: false)
  List<Translation> translations = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Video> videos = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String> authors = [];

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String> authorsGlobal = [];

  Exercise({
    this.id,
    this.uuid,
    this.created,
    this.lastUpdate,
    this.lastUpdateGlobal,
    this.variationId,
    List<Muscle>? muscles,
    List<Muscle>? musclesSecondary,
    List<Equipment>? equipment,
    List<ExerciseImage>? images,
    List<Translation>? translations,
    ExerciseCategory? category,
    List<Video>? videos,
    List<String>? authors,
    List<String>? authorsGlobal,
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

    if (translations != null) {
      this.translations = translations;
    }

    if (videos != null) {
      this.videos = videos;
    }
    this.authors = authors ?? [];
    this.authorsGlobal = authorsGlobal ?? [];
  }

  Exercise.fromApiDataString(String baseData, List<Language> languages)
      : this.fromApiData(ExerciseApiData.fromString(baseData), languages);

  Exercise.fromApiDataJson(Map<String, dynamic> baseData, List<Language> languages)
      : this.fromApiData(ExerciseApiData.fromJson(baseData), languages);

  Exercise.fromApiData(ExerciseApiData baseData, List<Language> languages) {
    id = baseData.id;
    uuid = baseData.uuid;
    categoryId = baseData.category.id;
    category = baseData.category;

    created = baseData.created;
    lastUpdate = baseData.lastUpdate;
    lastUpdateGlobal = baseData.lastUpdateGlobal;

    musclesSecondary = baseData.muscles;
    muscles = baseData.muscles;
    equipment = baseData.equipment;
    category = baseData.category;
    translations = baseData.translations.map((e) {
      e.language = languages.firstWhere((l) => l.id == e.languageId);
      return e;
    }).toList();
    videos = baseData.videos;
    images = baseData.images;

    authors = baseData.authors;
    authorsGlobal = baseData.authorsGlobal;

    variationId = baseData.variationId;
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
        orElse: () => translations.first,
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
  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

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
