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

import 'package:flutter/foundation.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/core/search_options.dart';
import 'package:wger/models/exercises/category.dart';

enum ExerciseSearchMode {
  exact,
  fulltext,
}

class ExerciseFilters {
  final SearchLanguage searchLanguage;
  final ExerciseSearchMode searchMode;

  /// Categories the user has narrowed the search to.
  ///
  /// An empty set means "no category filter" (i.e. all categories are
  /// included).
  final Set<ExerciseCategory> selectedCategories;

  const ExerciseFilters({
    this.searchLanguage = SearchLanguage.currentAndEnglish,
    this.searchMode = ExerciseSearchMode.fulltext,
    this.selectedCategories = const {},
  });

  /// Locale-aware default filter set.
  ///
  /// In an English locale "current + English" collapses to "current" — there
  /// is no extra fallback to add. Everywhere else, falling back to English is
  /// the default. All other fields take the constructor defaults.
  factory ExerciseFilters.defaultFor(String localeCode) => ExerciseFilters(
    searchLanguage: localeCode == LANGUAGE_SHORT_ENGLISH
        ? SearchLanguage.current
        : SearchLanguage.currentAndEnglish,
  );

  ExerciseFilters copyWith({
    SearchLanguage? searchLanguage,
    ExerciseSearchMode? searchMode,
    Set<ExerciseCategory>? selectedCategories,
  }) {
    return ExerciseFilters(
      searchLanguage: searchLanguage ?? this.searchLanguage,
      searchMode: searchMode ?? this.searchMode,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }

  /// Number of fields that deviate from the locale-aware defaults.
  ///
  /// Used to surface "filters are active" feedback in the UI (e.g. as a badge
  /// on the filter icon).
  int activeFilterCount(String currentLocaleCode) {
    final defaults = ExerciseFilters.defaultFor(currentLocaleCode);
    var count = 0;
    if (searchLanguage != defaults.searchLanguage) {
      count++;
    }
    if (searchMode != defaults.searchMode) {
      count++;
    }
    if (!setEquals(selectedCategories, defaults.selectedCategories)) {
      count++;
    }
    return count;
  }
}
