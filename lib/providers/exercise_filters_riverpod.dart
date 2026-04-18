import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/shared_preferences.dart';
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
    // Note: we don't persist selectedCategory — it resets on app restart.
    return ExerciseFilters(
      searchLanguage: searchLanguage,
      searchMode: searchMode,
    );
  }

  ExerciseFilters _current() {
    return state.asData?.value ?? const ExerciseFilters();
  }

  Future<void> chooseLanguage(ExerciseSearchLanguage value) async {
    state = AsyncData(_current().copyWith(searchLanguage: value));
    await PreferenceHelper.instance.saveExerciseSearchLanguage(value);
  }

  Future<void> chooseSearchMode(ExerciseSearchMode value) async {
    state = AsyncData(_current().copyWith(searchMode: value));
    await PreferenceHelper.instance.saveExerciseSearchMode(value);
  }

  void selectCategory(ExerciseCategory? category) {
    // Category selection is synchronous and not persisted
    if (category == null) {
      state = AsyncData(_current().copyWith(clearCategory: true));
    } else {
      state = AsyncData(_current().copyWith(selectedCategory: category));
    }
  }
}

/// Synchronous unwrapper — widgets use this to avoid AsyncValue boilerplate
final exerciseFiltersSyncProvider = Provider<ExerciseFilters>((ref) {
  return ref.watch(exerciseFiltersProvider).asData?.value ?? const ExerciseFilters();
});
