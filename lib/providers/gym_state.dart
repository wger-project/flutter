import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/models/exercises/exercise.dart';

const GYM_PAGE_KEY = 'gym_current_page';

final StateNotifierProvider<GymStateNotifier, GymState> gymStateProvider =
    StateNotifierProvider<GymStateNotifier, GymState>((ref) {
  return GymStateNotifier();
});

class GymState {
  final Map<Exercise, int> exercisePages;
  final bool showExercisePages;
  final int currentPage;
  final int? dayId;

  const GymState({
    this.exercisePages = const {},
    this.showExercisePages = true,
    this.currentPage = 0,
    this.dayId = null,
  });

  GymState copyWith({
    Map<Exercise, int>? exercisePages,
    bool? showExercisePages,
    int? currentPage,
    int? dayId,
  }) {
    return GymState(
      exercisePages: exercisePages ?? this.exercisePages,
      showExercisePages: showExercisePages ?? this.showExercisePages,
      currentPage: currentPage ?? this.currentPage,
      dayId: dayId ?? this.dayId,
    );
  }
}

class GymStateNotifier extends StateNotifier<GymState> {
  final _prefs = SharedPreferences.getInstance();

  GymStateNotifier() : super(const GymState()) {
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final SharedPreferences prefs = await _prefs;
    final int savedPage = prefs.getInt(GYM_PAGE_KEY) ?? 0;
    state = state.copyWith(currentPage: savedPage);
  }

  Future<void> setCurrentPage(int page) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt(GYM_PAGE_KEY, page);
    state = state.copyWith(currentPage: page);
  }

  void toggleExercisePages() {
    state = state.copyWith(showExercisePages: !state.showExercisePages);
  }

  void setExercisePages(Map<Exercise, int> exercisePages) {
    state = state.copyWith(exercisePages: exercisePages);
  }

  void clear() {
    state = state.copyWith(
      exercisePages: {},
      currentPage: 0,
      dayId: null,
    );
  }
}
