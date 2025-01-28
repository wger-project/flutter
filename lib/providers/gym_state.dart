import 'package:flutter/cupertino.dart';
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
  @override
  String toString() {
    return 'GymState(currentPage: $currentPage, showExercisePages: $showExercisePages, exercisePages: ${exercisePages.length} exercises, dayId: $dayId)';
  }
}

class GymStateNotifier extends StateNotifier<GymState> {
  final _prefs = SharedPreferences.getInstance();

  GymStateNotifier() : super(const GymState()) {
    debugPrint('GymStateNotifier: Initializing');
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    debugPrint('GymStateNotifier: Loading saved state');
    final SharedPreferences prefs = await _prefs;
    final int savedPage = prefs.getInt(GYM_PAGE_KEY) ?? 0;
    debugPrint('GymStateNotifier: Loaded saved page: $savedPage');
    state = state.copyWith(currentPage: savedPage);
  }

  Future<void> setCurrentPage(int page) async {
    debugPrint('GymStateNotifier: Setting page from ${state.currentPage} to $page');
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt(GYM_PAGE_KEY, page);
    state = state.copyWith(currentPage: page);
    debugPrint('GymStateNotifier: New state - $state');
  }

  void toggleExercisePages() {
    state = state.copyWith(showExercisePages: !state.showExercisePages);
  }
  void setDayId(int dayId) {
    state = state.copyWith(dayId: dayId);
  }
  void setExercisePages(Map<Exercise, int> exercisePages) {
    debugPrint('GymStateNotifier: Setting exercise pages - ${exercisePages.length} exercises');
    state = state.copyWith(exercisePages: exercisePages);
    debugPrint('GymStateNotifier: Exercise pages set - ${exercisePages.entries.map((e) => '${e.key.id}: ${e.value}').join(', ')}');
    debugPrint('GymStateNotifier: New state - $state');
  }

  Future<void> clear() async {
    debugPrint('GymStateNotifier: Clearing state');
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(GYM_PAGE_KEY);
    state = state.copyWith(
      exercisePages: {},
      currentPage: 0,
      dayId: null,
    );
    debugPrint('GymStateNotifier: State cleared - $state');
  }
}
