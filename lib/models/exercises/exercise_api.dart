/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/exercises/video.dart';

part 'exercise_api.freezed.dart';
part 'exercise_api.g.dart';

/// Model for an exercise as returned from the exerciseinfo endpoint
///
/// Basically this is just used as a convenience to create "real" exercise
/// objects and nothing more
@freezed
sealed class ExerciseApiData with _$ExerciseApiData {
  factory ExerciseApiData({
    required int id,
    required String uuid,
    // ignore: invalid_annotation_target
    @Default(null) @JsonKey(name: 'variations') int? variationId,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'created') required DateTime created,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'last_update') required DateTime lastUpdate,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'last_update_global') required DateTime lastUpdateGlobal,
    required ExerciseCategory category,
    required List<Muscle> muscles,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'muscles_secondary') required List<Muscle> musclesSecondary,
    // ignore: invalid_annotation_target
    required List<Equipment> equipment,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'translations', defaultValue: []) required List<Translation> translations,
    required List<ExerciseImage> images,
    required List<Video> videos,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'author_history') required List<String> authors,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'total_authors_history') required List<String> authorsGlobal,
  }) = _ExerciseBaseData;

  factory ExerciseApiData.fromString(String input) => _$ExerciseApiDataFromJson(json.decode(input));

  factory ExerciseApiData.fromJson(Map<String, dynamic> json) => _$ExerciseApiDataFromJson(json);
}
