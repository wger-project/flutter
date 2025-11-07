/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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

import 'dart:async';

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercise_data.dart';
import 'package:wger/providers/exercise_state.dart';
import 'package:wger/providers/wger_base_riverpod.dart';

part 'exercise_state_notifier.g.dart';

@riverpod
Future<void> exerciseStateReady(Ref ref) {
  return Future.wait([
    ref.watch(exercisesProvider.future),
    ref.watch(exerciseEquipmentProvider.future),
    ref.watch(exerciseCategoriesProvider.future),
  ]);
}

@Riverpod(keepAlive: true)
final class ExerciseStateNotifier extends _$ExerciseStateNotifier {
  final _logger = Logger('ExerciseStateNotifier');

  static const exerciseInfoUrlPath = 'exerciseinfo';

  @override
  ExerciseState build() {
    _logger.finer('Building ExerciseStateNotifier');
    ref.keepAlive();

    final exercisesAsync = ref.watch(exercisesProvider);
    final equipmentAsync = ref.watch(exerciseEquipmentProvider);
    final categoriesAsync = ref.watch(exerciseCategoriesProvider);

    if (exercisesAsync.isLoading || equipmentAsync.isLoading || categoriesAsync.isLoading) {
      return ExerciseState(isLoading: true);
    }

    final error = exercisesAsync.error ?? equipmentAsync.error ?? categoriesAsync.error;
    if (error != null) {
      _logger.warning('Error building ExerciseStateNotifier: $error');
      return ExerciseState(isLoading: false);
    }

    // If we arrive here, all data is loaded
    final exercises = exercisesAsync.asData!.value;
    final equipment = equipmentAsync.asData!.value;
    final categories = categoriesAsync.asData!.value;
    _logger.finer(
      'All data loaded: '
      '${exercises.length} exercises, '
      '${equipment.length} equipment, '
      '${categories.length} categories',
    );

    final newState = ExerciseState(
      exercises: exercises,
      equipment: equipment,
      categories: categories,
      isLoading: false,
    );

    final filters = _initializeFilters(newState.filters, equipment, categories);
    final filteredExercises = _applyFilters(exercises, filters);
    return newState.copyWith(
      filters: filters,
      filteredExercises: filteredExercises,
    );
  }

  Filters _initializeFilters(
    Filters currentFilters,
    List<Equipment> equipment,
    List<ExerciseCategory> categories,
  ) {
    var filters = currentFilters;
    var updated = false;

    if (filters.equipment.items.isEmpty && equipment.isNotEmpty) {
      final Map<Equipment, bool> items = {for (var e in equipment) e: false};
      filters = filters.copyWith(equipment: filters.equipment.copyWith(items: items));
      updated = true;
    }

    if (filters.exerciseCategories.items.isEmpty && categories.isNotEmpty) {
      final Map<ExerciseCategory, bool> items = {for (var c in categories) c: false};
      filters = filters.copyWith(
        exerciseCategories: filters.exerciseCategories.copyWith(items: items),
      );
      updated = true;
    }

    if (updated) {
      filters.markUpdated();
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
        final title = (e.getTranslation(languageCode).name ?? '').toLowerCase();
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

  List<Exercise> get allExercises {
    return state.exercises;
  }

  Exercise getById(int id) {
    return state.exercises.firstWhere((e) => e.id == id);
  }

  Map<int, List<Exercise>> get exerciseByVariation {
    final Map<int, List<Exercise>> variations = {};

    for (final exercise in state.exercises.where((e) => e.variationId != null)) {
      if (!variations.containsKey(exercise.variationId)) {
        variations[exercise.variationId!] = [];
      }

      variations[exercise.variationId]!.add(exercise);
    }

    return variations;
  }

  /// Find exercises by variation IDs
  ///
  /// exerciseIdToExclude: the ID of the exercise to exclude from the list of
  /// returned exercises. Since this is typically called by one exercise, we are
  /// not interested in seeing that same exercise returned in the list of variations.
  /// If this parameter is not passed, all exercises are returned.
  List<Exercise> findExercisesByVariationId(int? variationId, {int? exerciseIdToExclude}) {
    if (variationId == null) {
      return [];
    }

    var out = state.exercises.where((base) => base.variationId == variationId).toList();

    if (exerciseIdToExclude != null) {
      out = out.where((e) => e.id != exerciseIdToExclude).toList();
    }
    return out;
  }

  Future<List<Exercise>> searchExercise(
    String term, {
    bool useOnlineSearch = true,
    String languageCode = 'en',
    bool searchEnglish = false,
  }) async {
    if (term.isEmpty) {
      return [];
    }

    final searchMethod = useOnlineSearch ? searchExerciseOnline : searchExerciseLocal;
    return searchMethod(
      term,
      languageCode: languageCode,
      searchEnglish: searchEnglish,
    );
  }

  Future<List<Exercise>> searchExerciseOnline(
    String term, {
    String languageCode = 'en',
    bool searchEnglish = false,
  }) async {
    final wgerBase = ref.read(wgerBaseProvider);
    _logger.info('Online search for exercises: $term');

    if (term.length <= 1) {
      return [];
    }

    final languages = [languageCode];
    if (searchEnglish && languageCode != LANGUAGE_SHORT_ENGLISH) {
      languages.add(LANGUAGE_SHORT_ENGLISH);
    }

    // Send the request
    final result = await wgerBase.fetch(
      wgerBase.makeUrl(
        exerciseInfoUrlPath,
        query: {
          'name__search': term,
          'language__code': languages.join(','),
          'limit': API_RESULTS_PAGE_SIZE,
        },
      ),
    );

    // Load the exercises
    final ids = (result['results'] as List).map<int>((data) => data['id'] as int).toList();

    // TODO: fix this! Why is the ref of stateProvider always disposed?
    return state.exercises.where((e) => ids.contains(e.id)).toList();
  }

  Future<List<Exercise>> searchExerciseLocal(
    String term, {
    String languageCode = 'en',
    bool searchEnglish = false,
  }) async {
    _logger.fine('Local search for exercises: $term');

    final languages = [languageCode];
    if (searchEnglish && languageCode != 'en') {
      languages.add('en');
    }

    final List<Exercise> out = [];

    for (final e in state.exercises) {
      var matched = false;
      for (final lang in languages) {
        final title = (e.getTranslation(lang).name ?? '').toLowerCase();
        if (title.contains(term.toLowerCase())) {
          matched = true;
          break;
        }
      }
      if (matched) {
        out.add(e);
      }
    }
    return out;
  }
}
