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

import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/core/search_options.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/exercise_filters.dart';

part 'exercise_filters_riverpod.g.dart';

@riverpod
class ExerciseFiltersNotifier extends _$ExerciseFiltersNotifier {
  @override
  Future<ExerciseFilters> build() async {
    final prefs = PreferenceHelper.instance;
    final searchLanguage = await prefs.getExerciseSearchLanguage();
    final searchMode = await prefs.getExerciseSearchMode();
    // Note: we don't persist selectedCategories — they reset on app restart.
    return ExerciseFilters(
      searchLanguage: searchLanguage,
      searchMode: searchMode,
    );
  }

  ExerciseFilters _current() {
    return state.asData?.value ?? const ExerciseFilters();
  }

  Future<void> chooseLanguage(SearchLanguage value) async {
    state = AsyncData(_current().copyWith(searchLanguage: value));
    await PreferenceHelper.instance.saveExerciseSearchLanguage(value);
  }

  Future<void> chooseSearchMode(ExerciseSearchMode value) async {
    state = AsyncData(_current().copyWith(searchMode: value));
    await PreferenceHelper.instance.saveExerciseSearchMode(value);
  }

  /// Adds [category] to the selection if absent, otherwise removes it.
  void toggleCategory(ExerciseCategory category) {
    final current = _current().selectedCategories;
    final next = {...current};
    if (!next.remove(category)) {
      next.add(category);
    }
    state = AsyncData(_current().copyWith(selectedCategories: next));
  }

  /// Clears the category filter so all categories are included again.
  void clearCategories() {
    state = AsyncData(_current().copyWith(selectedCategories: const {}));
  }

  Future<void> resetAll() async {
    const defaults = ExerciseFilters();
    state = const AsyncData(defaults);
    final prefs = PreferenceHelper.instance;
    await prefs.saveExerciseSearchLanguage(defaults.searchLanguage);
    await prefs.saveExerciseSearchMode(defaults.searchMode);
  }
}

/// Synchronous unwrapper — to avoid AsyncValue boilerplate
final exerciseFiltersSyncProvider = Provider<ExerciseFilters>((ref) {
  return ref.watch(exerciseFiltersProvider).asData?.value ?? const ExerciseFilters();
});
