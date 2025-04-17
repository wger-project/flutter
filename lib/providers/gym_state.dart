import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/models/exercises/exercise.dart';

const DEFAULT_DURATION = Duration(hours: 5);

final StateNotifierProvider<GymStateNotifier, GymState> gymStateProvider =
    StateNotifierProvider<GymStateNotifier, GymState>((ref) {
  return GymStateNotifier();
});

class GymState {
  final Map<Exercise, int> exercisePages;
  final bool showExercisePages;
  final int currentPage;
  final int? dayId;
  late TimeOfDay startTime;
  late DateTime validUntil;

  GymState(
      {this.exercisePages = const {},
      this.showExercisePages = true,
      this.currentPage = 0,
      this.dayId,
      DateTime? validUntil,
      TimeOfDay? startTime}) {
    this.validUntil = validUntil ?? DateTime.now().add(DEFAULT_DURATION);
    this.startTime = startTime ?? TimeOfDay.now();
  }

  GymState copyWith({
    Map<Exercise, int>? exercisePages,
    bool? showExercisePages,
    int? currentPage,
    int? dayId,
    DateTime? validUntil,
    TimeOfDay? startTime,
  }) {
    return GymState(
      exercisePages: exercisePages ?? this.exercisePages,
      showExercisePages: showExercisePages ?? this.showExercisePages,
      currentPage: currentPage ?? this.currentPage,
      dayId: dayId ?? this.dayId,
      validUntil: validUntil ?? this.validUntil.add(DEFAULT_DURATION),
      startTime: startTime ?? this.startTime,
    );
  }

  @override
  String toString() {
    return 'GymState('
        'currentPage: $currentPage, '
        'showExercisePages: $showExercisePages, '
        'exercisePages: ${exercisePages.length} exercises, '
        'dayId: $dayId, '
        'validUntil: $validUntil '
        'startTime: $startTime, '
        ')';
  }
}

class GymStateNotifier extends StateNotifier<GymState> {
  final _logger = Logger('GymStateNotifier');

  GymStateNotifier() : super(GymState());

  void setCurrentPage(int page) {
    // _logger.fine('Setting page from ${state.currentPage} to $page');
    state = state.copyWith(currentPage: page);
  }

  void toggleExercisePages() {
    state = state.copyWith(showExercisePages: !state.showExercisePages);
  }

  void setDayId(int dayId) {
    // _logger.fine('Setting day id from ${state.dayId} to $dayId');
    state = state.copyWith(dayId: dayId);
  }

  void setExercisePages(Map<Exercise, int> exercisePages) {
    // _logger.fine('Setting exercise pages - ${exercisePages.length} exercises');
    state = state.copyWith(exercisePages: exercisePages);
    // _logger.fine(
    //     'Exercise pages set - ${exercisePages.entries.map((e) => '${e.key.id}: ${e.value}').join(', ')}');
  }

  void clear() {
    _logger.fine('Clearing state');
    state = state.copyWith(
      exercisePages: {},
      currentPage: 0,
      dayId: null,
      validUntil: DateTime.now().add(DEFAULT_DURATION),
      startTime: TimeOfDay.now(),
    );
  }
}
