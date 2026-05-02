import 'package:wger/models/core/search_options.dart';
import 'package:wger/models/exercises/category.dart';

enum ExerciseSearchMode {
  exact,
  fulltext,
}

const Object _sentinel = Object();

class ExerciseFilters {
  final SearchLanguage searchLanguage;
  final ExerciseSearchMode searchMode;
  final ExerciseCategory? selectedCategory;

  const ExerciseFilters({
    this.searchLanguage = SearchLanguage.currentAndEnglish,
    this.searchMode = ExerciseSearchMode.fulltext,
    this.selectedCategory,
  });

  ExerciseFilters copyWith({
    SearchLanguage? searchLanguage,
    ExerciseSearchMode? searchMode,
    Object? selectedCategory = _sentinel,
  }) {
    return ExerciseFilters(
      searchLanguage: searchLanguage ?? this.searchLanguage,
      searchMode: searchMode ?? this.searchMode,
      selectedCategory: identical(selectedCategory, _sentinel)
          ? this.selectedCategory
          : selectedCategory as ExerciseCategory?,
    );
  }
}
