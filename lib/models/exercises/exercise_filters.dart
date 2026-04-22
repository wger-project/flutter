import 'package:wger/models/exercises/category.dart';

enum ExerciseSearchLanguage {
  current,
  currentAndEnglish,
  all,
}

enum ExerciseSearchMode {
  exact,
  fulltext,
}

class ExerciseFilters {
  final ExerciseSearchLanguage searchLanguage;
  final ExerciseSearchMode searchMode;
  final ExerciseCategory? selectedCategory;

  const ExerciseFilters({
    this.searchLanguage = ExerciseSearchLanguage.currentAndEnglish,
    this.searchMode = ExerciseSearchMode.fulltext,
     this.selectedCategory,
  });

  ExerciseFilters copyWith({
    ExerciseSearchLanguage? searchLanguage,
    ExerciseSearchMode? searchMode,
    ExerciseCategory? selectedCategory,
    bool clearCategory = false, // flag to explicitly set category to null
  }) {
    return ExerciseFilters(
      searchLanguage: searchLanguage ?? this.searchLanguage,
      searchMode: searchMode ?? this.searchMode,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }
}
