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

@Riverpod(keepAlive: true)
final class ExerciseStateNotifier extends _$ExerciseStateNotifier {
  final _logger = Logger('ExerciseStateNotifier');

  static const exerciseInfoUrlPath = 'exerciseinfo';

  @override
  ExerciseState build() {
    _logger.finer('Building ExerciseStateNotifier');

    ref.keepAlive();
    state = ExerciseState(isLoading: true);

    // Load exercises
    ref.listen<AsyncValue<List<Exercise>>>(
      exerciseProvider,
      (previous, next) {
        if (next.isLoading) {
          state = state.copyWith(isLoading: true);
          return;
        }

        if (next.hasError) {
          _logger.warning('Error in exercise stream: ${next.error}');
          state = state.copyWith(isLoading: false);
          return;
        }

        final fresh = next.asData!.value;
        final filtered = _applyFilters(fresh, state.filters);
        state = state.copyWith(exercises: fresh, filteredExercises: filtered, isLoading: false);
      },
      fireImmediately: true,
    );

    // Load equipment
    ref.listen<AsyncValue<List<Equipment>>>(
      exerciseEquipmentProvider,
      (previous, next) {
        if (next.hasValue) {
          state = state.copyWith(equipment: next.asData!.value);
          _ensureFiltersInitialized();
        }
      },
      fireImmediately: true,
    );

    // Load categories
    ref.listen<AsyncValue<List<ExerciseCategory>>>(
      exerciseCategoryProvider,
      (previous, next) {
        if (next.hasValue) {
          state = state.copyWith(categories: next.asData!.value);
          _ensureFiltersInitialized();
        }
      },
      fireImmediately: true,
    );

    return state;
  }

  void _ensureFiltersInitialized() {
    var filters = state.filters;
    var updated = false;

    if (filters.equipment.items.isEmpty && state.equipment.isNotEmpty) {
      final equipmentMap = {for (final e in state.equipment) e: false};
      filters = filters.copyWith(
        equipment: FilterCategory<Equipment>(title: 'Equipment', items: equipmentMap),
      );
      updated = true;
    }

    if (filters.exerciseCategories.items.isEmpty && state.categories.isNotEmpty) {
      final categoryMap = {for (final c in state.categories) c: false};
      filters = filters.copyWith(
        exerciseCategories: FilterCategory<ExerciseCategory>(title: 'Category', items: categoryMap),
      );
      updated = true;
    }

    if (updated) {
      setFilters(filters, LANGUAGE_SHORT_ENGLISH);
    }
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

  Exercise? getById(int id) {
    try {
      return state.exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
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

    return (result['results'] as List)
        .map((data) => Exercise.fromApiDataJson(data as Map<String, dynamic>, []))
        .toList();
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
