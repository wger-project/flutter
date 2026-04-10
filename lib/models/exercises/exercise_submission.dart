/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_submission.freezed.dart';
part 'exercise_submission.g.dart';

// ignore_for_file: invalid_annotation_target

///
/// Models for the data model used when submitting an exercise to the API
///

/// Alias part of an exercise submission
@freezed
sealed class ExerciseAliasSubmissionApi with _$ExerciseAliasSubmissionApi {
  const factory ExerciseAliasSubmissionApi({required String alias}) = _ExerciseAliasSubmissionApi;

  factory ExerciseAliasSubmissionApi.fromJson(Map<String, dynamic> json) =>
      _$ExerciseAliasSubmissionApiFromJson(json);
}

/// Comment part of an exercise submission
@freezed
sealed class ExerciseCommentSubmissionApi with _$ExerciseCommentSubmissionApi {
  const factory ExerciseCommentSubmissionApi({required String alias}) =
      _ExerciseCommentSubmissionApi;

  factory ExerciseCommentSubmissionApi.fromJson(Map<String, dynamic> json) =>
      _$ExerciseCommentSubmissionApiFromJson(json);
}

/// Translation part of an exercise submission
@freezed
sealed class ExerciseTranslationSubmissionApi with _$ExerciseTranslationSubmissionApi {
  const factory ExerciseTranslationSubmissionApi({
    required String name,

    @JsonKey(name: 'description_source') required String description,

    required int language,

    @JsonKey(name: 'license_author') required String author,

    @Default([]) List<ExerciseAliasSubmissionApi> aliases,

    @Default([]) List<ExerciseCommentSubmissionApi> comments,
  }) = _ExerciseTranslationSubmissionApi;

  factory ExerciseTranslationSubmissionApi.fromJson(Map<String, dynamic> json) =>
      _$ExerciseTranslationSubmissionApiFromJson(json);
}

/// "Main" part of an exercise submission
@freezed
sealed class ExerciseSubmissionApi with _$ExerciseSubmissionApi {
  const factory ExerciseSubmissionApi({
    required int category,

    required List<int> muscles,

    @JsonKey(name: 'muscles_secondary') required List<int> musclesSecondary,

    required List<int> equipment,

    @JsonKey(name: 'license_author') required String author,

    @JsonKey(includeToJson: true) int? variation,

    @JsonKey(includeToJson: true, name: 'variations_connect_to') int? variationConnectTo,

    required List<ExerciseTranslationSubmissionApi> translations,
  }) = _ExerciseSubmissionApi;

  factory ExerciseSubmissionApi.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSubmissionApiFromJson(json);
}
