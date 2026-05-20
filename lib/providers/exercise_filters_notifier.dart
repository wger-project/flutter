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

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercise_filter_state.dart';
import 'package:wger/providers/exercises_notifier.dart';

part 'exercise_filters_notifier.g.dart';

/// Holds the *UI-side* state for the exercises catalogue screen:
/// search term, selected categories/equipment, and the resulting
/// [filteredExercises] list.
@Riverpod(keepAlive: true)
class ExerciseListFiltersNotifier extends _$ExerciseListFiltersNotifier {
  final _logger = Logger('ExerciseListFiltersNotifier');

  @override
  ExerciseFilterState build() {
    _logger.finer('Building ExerciseListFiltersNotifier');
    ref.keepAlive();

    final exercisesAsync = ref.watch(exercisesProvider);
    final equipmentAsync = ref.watch(exerciseEquipmentProvider);
    final categoriesAsync = ref.watch(exerciseCategoriesProvider);

    if (exercisesAsync.isLoading || equipmentAsync.isLoading || categoriesAsync.isLoading) {
      return ExerciseFilterState(isLoading: true);
    }

    final error = exercisesAsync.error ?? equipmentAsync.error ?? categoriesAsync.error;
    if (error != null) {
      _logger.warning('Error building ExerciseListFiltersNotifier: $error');
      return ExerciseFilterState(isLoading: false);
    }

    // If we arrive here, all data is loaded. The exercises stream
    // wraps the list inside an `ExerciseState`; unpack `.exercises`
    // here so the rest of the filter logic stays untouched.
    final exercises = exercisesAsync.asData!.value.exercises;
    final equipment = equipmentAsync.asData!.value;
    final categories = categoriesAsync.asData!.value;
    _logger.finer(
      'All data loaded: '
      '${exercises.length} exercises, '
      '${equipment.length} equipment, '
      '${categories.length} categories',
    );

    final filters = _initializeFilters(
      ExerciseFilterState().filters,
      equipment,
      categories,
    );
    final filteredExercises = _applyFilters(exercises, filters);
    return ExerciseFilterState(
      exercises: exercises,
      filters: filters,
      filteredExercises: filteredExercises,
      isLoading: false,
    );
  }

  Filters _initializeFilters(
    Filters currentFilters,
    List<Equipment> equipment,
    List<ExerciseCategory> categories,
  ) {
    var filters = currentFilters;

    if (filters.equipment.items.isEmpty && equipment.isNotEmpty) {
      final Map<Equipment, bool> items = {for (var e in equipment) e: false};
      filters = filters.copyWith(equipment: filters.equipment.copyWith(items: items));
    }

    if (filters.exerciseCategories.items.isEmpty && categories.isNotEmpty) {
      final Map<ExerciseCategory, bool> items = {for (var c in categories) c: false};
      filters = filters.copyWith(
        exerciseCategories: filters.exerciseCategories.copyWith(items: items),
      );
    }

    return filters;
  }

  void setFilters(Filters filters, [String languageCode = LANGUAGE_SHORT_ENGLISH]) {
    final filtered = _applyFilters(state.exercises, filters, languageCode: languageCode);
    state = state.copyWith(filters: filters, filteredExercises: filtered);
  }

  List<Exercise> _applyFilters(
    List<Exercise> all,
    Filters filters, {
    String languageCode = LANGUAGE_SHORT_ENGLISH,
  }) {
    if (filters.isNothingMarked && (filters.searchTerm.length <= 1)) {
      return all;
    }

    var items = all;
    if (filters.searchTerm.length > 1) {
      final term = filters.searchTerm.toLowerCase();
      items = items.where((e) {
        // TODO: FullTextSearch?
        final title = e.getTranslation(languageCode).name.toLowerCase();
        return title.contains(term);
      }).toList();
    }

    final selectedCats = filters.exerciseCategories.selected;
    final selectedEquip = filters.equipment.selected;

    return items.where((exercise) {
      final inCategory = selectedCats.isEmpty || selectedCats.contains(exercise.category);
      final hasEquipment =
          selectedEquip.isEmpty || selectedEquip.any((eq) => exercise.equipment.contains(eq));
      return inCategory && hasEquipment;
    }).toList();
  }
}
