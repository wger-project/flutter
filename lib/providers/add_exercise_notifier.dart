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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/core/language.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise_submission_images.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/add_exercise_repository.dart';
import 'package:wger/providers/add_exercise_state.dart';

part 'add_exercise_notifier.g.dart';

@Riverpod(keepAlive: true)
class AddExerciseNotifier extends _$AddExerciseNotifier {
  late AddExerciseRepository _repo;

  @override
  AddExerciseState build() {
    _repo = ref.read(addExerciseRepositoryProvider);
    return const AddExerciseState();
  }

  void setAuthor(String value) => state = state.copyWith(author: value);
  void setExerciseNameEn(String? value) => state = state.copyWith(exerciseNameEn: value);
  void setExerciseNameTrans(String? value) => state = state.copyWith(exerciseNameTrans: value);
  void setDescriptionEn(String? value) => state = state.copyWith(descriptionEn: value);
  void setDescriptionTrans(String? value) => state = state.copyWith(descriptionTrans: value);
  void setLanguageEn(Language? value) => state = state.copyWith(languageEn: value);
  void setLanguageTranslation(Language? value) =>
      state = state.copyWith(languageTranslation: value);
  void setAlternateNamesEn(List<String> value) => state = state.copyWith(alternateNamesEn: value);
  void setAlternateNamesTrans(List<String> value) =>
      state = state.copyWith(alternateNamesTrans: value);
  void setCategory(ExerciseCategory? value) => state = state.copyWith(category: value);
  void setEquipment(List<Equipment> value) => state = state.copyWith(equipment: value);
  void setPrimaryMuscles(List<Muscle> value) => state = state.copyWith(primaryMuscles: value);
  void setSecondaryMuscles(List<Muscle> value) => state = state.copyWith(secondaryMuscles: value);

  void setVariationGroup(String? value) =>
      state = state.copyWith(variationGroup: value, variationConnectToExercise: null);

  void setVariationConnectToExercise(int? value) =>
      state = state.copyWith(variationConnectToExercise: value, variationGroup: null);

  void addExerciseImages(List<ExerciseSubmissionImage> images) {
    state = state.copyWith(exerciseImages: [...state.exerciseImages, ...images]);
  }

  void removeImage(String path) {
    state = state.copyWith(
      exerciseImages: state.exerciseImages.where((e) => e.imageFile.path != path).toList(),
    );
  }

  void clear() {
    state = const AddExerciseState();
  }

  /// Submits the exercise and uploads any attached images. Clears the form on
  /// success. Returns the id of the newly created exercise.
  Future<int> postExerciseToServer() async {
    final exerciseId = await _repo.submit(state.exerciseApiObject);
    for (final image in state.exerciseImages) {
      await _repo.uploadImage(
        exerciseId: exerciseId,
        image: image,
        author: state.author,
      );
    }
    clear();
    return exerciseId;
  }

  Future<bool> validateLanguage(String input, String languageCode) {
    return _repo.validateLanguage(input, languageCode);
  }
}
