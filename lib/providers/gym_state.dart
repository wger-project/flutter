import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day_data.dart';

part 'gym_state.g.dart';

const DEFAULT_DURATION = Duration(hours: 5);

class GymState {
  final Map<Exercise, int> exercisePages;
  final bool showExercisePages;
  final bool showTimerPages;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int? dayId;
  final TimeOfDay startTime;
  final DateTime validUntil;

  GymState({
    this.exercisePages = const {},
    this.showExercisePages = true,
    this.showTimerPages = true,
    this.currentPage = 0,
    this.totalPages = 1,
    this.totalElements = 1,
    this.dayId,
    DateTime? validUntil,
    TimeOfDay? startTime,
  }) : validUntil = validUntil ?? clock.now().add(DEFAULT_DURATION),
       startTime = startTime ?? TimeOfDay.fromDateTime(clock.now());

  GymState copyWith({
    Map<Exercise, int>? exercisePages,
    bool? showExercisePages,
    bool? showTimerPages,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    int? dayId,
    DateTime? validUntil,
    TimeOfDay? startTime,
  }) {
    return GymState(
      exercisePages: exercisePages ?? this.exercisePages,
      showExercisePages: showExercisePages ?? this.showExercisePages,
      showTimerPages: showTimerPages ?? this.showTimerPages,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      dayId: dayId ?? this.dayId,
      validUntil: validUntil ?? this.validUntil,
      startTime: startTime ?? this.startTime,
    );
  }

  @override
  String toString() {
    return 'GymState('
        'currentPage: $currentPage, '
        'totalPages: $totalPages, '
        'totalElements: $totalElements, '
        'exercisePages: ${exercisePages.length} exercises, '
        'dayId: $dayId, '
        'validUntil: $validUntil '
        'startTime: $startTime, '
        'showExercisePages: $showExercisePages, '
        'showTimerPages: $showTimerPages, '
        ')';
  }
}

@Riverpod(keepAlive: true)
class GymStateNotifier extends _$GymStateNotifier {
  final _logger = Logger('GymStateNotifier');

  @override
  GymState build() {
    _logger.finer('Initializing GymStateNotifier with default state');
    return GymState();
  }

  void computePagesForDay(DayData dayData, Exercise Function(int) findExerciseById) {
    var totalElements = 1;
    var totalPages = 1;
    final Map<Exercise, int> exercisePages = {};

    for (final slot in dayData.slots) {
      totalElements += slot.setConfigs.length;
      // exercise overview page
      if (state.showExercisePages) {
        totalPages += 1;
      }

      for (final config in slot.setConfigs) {
        // log + timer per set
        if (state.showTimerPages) {
          totalPages += (config.nrOfSets! * 2).toInt();
        } else {
          totalPages += config.nrOfSets!.toInt();
        }
      }
    }

    var currentPage = 1;
    for (final slot in dayData.slots) {
      var firstPage = true;
      for (final config in slot.setConfigs) {
        final exercise = findExerciseById(config.exerciseId);
        if (firstPage) {
          exercisePages[exercise] = currentPage;
          currentPage++;
        }
        currentPage += 2;
        firstPage = false;
      }
    }

    _logger.finer('Total pages: $totalPages');
    _logger.finer('Total elements: $totalElements');

    state = state.copyWith(
      exercisePages: exercisePages,
      totalPages: totalPages,
      totalElements: totalElements,
    );
  }

  Future<int> initForDay(
    DayData dayData, {
    required Exercise Function(int) findExerciseById,
  }) async {
    final newDayId = dayData.day!.id!;
    final validUntil = state.validUntil;
    final currentPage = state.currentPage;
    final savedDayId = state.dayId;

    final shouldReset = newDayId != savedDayId || validUntil.isBefore(DateTime.now());
    if (shouldReset) {
      _logger.fine('Day ID mismatch or expired validUntil date. Resetting to page 0.');
    }
    final initialPage = shouldReset ? 0 : currentPage;

    // compute pages (pure, uses callback for exercise lookup)
    computePagesForDay(dayData, findExerciseById);

    // set dayId and initial page
    state = state.copyWith(
      dayId: newDayId,
      currentPage: initialPage,
    );

    return initialPage;
  }

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void setShowExercisePages(bool value) {
    state = state.copyWith(showExercisePages: value);
  }

  void setShowTimerPages(bool value) {
    state = state.copyWith(showTimerPages: value);
  }

  void setDayId(int dayId) {
    state = state.copyWith(dayId: dayId);
  }

  void setExercisePages(Map<Exercise, int> exercisePages) {
    state = state.copyWith(exercisePages: exercisePages);
  }

  void clear() {
    _logger.fine('Clearing state');
    state = GymState();
  }
}
