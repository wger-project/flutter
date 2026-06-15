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
import 'package:wger/models/core/language.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise_submission.dart';
import 'package:wger/models/exercises/exercise_submission_images.dart';
import 'package:wger/models/exercises/muscle.dart';

part 'add_exercise_state.freezed.dart';

/// Transient form state for the "contribute a new exercise" flow.
@freezed
sealed class AddExerciseState with _$AddExerciseState {
  const AddExerciseState._();

  const factory AddExerciseState({
    @Default('') String author,
    String? exerciseNameEn,
    String? exerciseNameTrans,
    String? descriptionEn,
    String? descriptionTrans,
    String? variationGroup,
    int? variationConnectToExercise,
    Language? languageEn,
    Language? languageTranslation,
    @Default([]) List<String> alternateNamesEn,
    @Default([]) List<String> alternateNamesTrans,
    ExerciseCategory? category,
    @Default([]) List<Equipment> equipment,
    @Default([]) List<Muscle> primaryMuscles,
    @Default([]) List<Muscle> secondaryMuscles,
    @Default([]) List<ExerciseSubmissionImage> exerciseImages,
  }) = _AddExerciseState;

  bool get newVariation => variationConnectToExercise != null;

  /// Builds the API submission payload from the current form state.
  ExerciseSubmissionApi get exerciseApiObject {
    return ExerciseSubmissionApi(
      author: author,
      variationGroup: variationGroup,
      variationConnectTo: variationConnectToExercise,
      category: category!.id,
      muscles: primaryMuscles.map((e) => e.id).toList(),
      musclesSecondary: secondaryMuscles.map((e) => e.id).toList(),
      equipment: equipment.map((e) => e.id).toList(),
      translations: [
        ExerciseTranslationSubmissionApi(
          author: author,
          language: languageEn!.id,
          name: exerciseNameEn!,
          descriptionSource: descriptionEn!,
          aliases: alternateNamesEn
              .where((element) => element.isNotEmpty)
              .map((e) => ExerciseAliasSubmissionApi(alias: e))
              .toList(),
        ),
        if (languageTranslation != null)
          ExerciseTranslationSubmissionApi(
            author: author,
            language: languageTranslation!.id,
            name: exerciseNameTrans!,
            descriptionSource: descriptionTrans!,
            aliases: alternateNamesTrans
                .where((element) => element.isNotEmpty)
                .map((e) => ExerciseAliasSubmissionApi(alias: e))
                .toList(),
          ),
      ],
    );
  }
}
