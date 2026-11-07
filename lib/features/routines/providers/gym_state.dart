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

import 'package:clock/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/routines/models/added_exercise.dart';
import 'package:wger/features/routines/models/day_data.dart';
import 'package:wger/features/routines/models/page_progress.dart';
import 'package:wger/features/routines/models/routine.dart';
import 'package:wger/features/routines/models/set_config_data.dart';

const DEFAULT_DURATION = Duration(hours: 5);

const PREFS_SHOW_EXERCISES = 'showExercisePrefs';
const PREFS_SHOW_TIMER = 'showTimerPrefs';
const PREFS_ALERT_COUNTDOWN = 'alertCountdownPrefs';
const PREFS_USE_COUNTDOWN_BETWEEN_SETS = 'useCountdownBetweenSetsPrefs';
const PREFS_COUNTDOWN_DURATION = 'countdownDurationSecondsPrefs';
const PREFS_LOG_SCOPE_WEEKS = 'logScopeWeeksPrefs';
const PREFS_SHOW_DISTINCT_LOGS = 'showDistinctLogsPrefs';
const PREFS_SHOW_WORKOUT_DURATION = 'showWorkoutDurationPrefs';
const PREFS_WORKOUT_NOTIFICATION = 'workoutNotificationPrefs';
const PREFS_STICKY_SET_VALUES = 'stickySetValuesPrefs';

/// In seconds
const DEFAULT_COUNTDOWN_DURATION = 180;
const MIN_COUNTDOWN_DURATION = 10;
const MAX_COUNTDOWN_DURATION = 1800;

enum PageType {
  start,
  set,
  session,
  workoutSummary,
}

enum SlotPageType {
  exerciseOverview,
  log,
  timer,
}

class PageEntry {
  /// Identifies the page across recalculations, derived from the routine
  final String key;

  final PageType type;

  /// Absolute page index
  final int pageIndex;

  final List<SlotPageEntry> slotPages;

  PageEntry({
    required this.type,
    required this.pageIndex,
    required this.key,
    this.slotPages = const [],
  }) : assert(
         slotPages.isEmpty || type == PageType.set,
         'SlotEntries can only be set for set pages',
       );

  PageEntry copyWith({
    String? key,
    PageType? type,
    int? pageIndex,
    List<SlotPageEntry>? slotPages,
  }) {
    return PageEntry(
      key: key ?? this.key,
      type: type ?? this.type,
      pageIndex: pageIndex ?? this.pageIndex,
      slotPages: slotPages ?? this.slotPages,
    );
  }

  List<Exercise> get exercises {
    final exerciseSet = <Exercise>{};
    for (final entry in slotPages) {
      exerciseSet.add(entry.setConfigData!.exercise);
    }
    return exerciseSet.toList();
  }

  @override
  String toString() => 'PageEntry(key: $key, type: $type, pageIndex: $pageIndex)';
}

class SlotPageEntry {
  /// Identifies the page across recalculations, derived from the routine
  final String key;

  final SlotPageType type;

  /// index within a set for overview (e.g. "1 of 5 sets")
  final int setIndex;

  /// Absolute page index
  final int pageIndex;

  /// The associated SetConfigData
  final SetConfigData? setConfigData;

  SlotPageEntry({
    required this.type,
    required this.pageIndex,
    required this.setIndex,
    required this.key,
    this.setConfigData,
  }) : assert(
         type != SlotPageType.log || setConfigData != null,
         'You need to set setConfigData for SlotPageType.log',
       );

  SlotPageEntry copyWith({
    String? key,
    SlotPageType? type,
    int? exerciseId,
    int? setIndex,
    int? pageIndex,
    SetConfigData? setConfigData,
  }) {
    return SlotPageEntry(
      key: key ?? this.key,
      type: type ?? this.type,
      setIndex: setIndex ?? this.setIndex,
      pageIndex: pageIndex ?? this.pageIndex,
      setConfigData: setConfigData ?? this.setConfigData,
    );
  }

  @override
  String toString() =>
      'SlotPageEntry('
      'key: $key, '
      'type: $type, '
      'setIndex: $setIndex, '
      'pageIndex: $pageIndex'
      ')';
}

class GymModeState {
  // Navigation data
  final bool isInitialized;

  final List<PageEntry> pages;
  final int currentPage;

  /// Moment the workout was started, with full seconds precision. Set when
  /// gym mode is opened and reset when the user taps "start".
  final DateTime workoutStart;
  final DateTime validUntil;

  // User settings
  final bool showExercisePages;
  final bool showTimerPages;

  /// Alert at the end of a rest: a vibration in gym mode, an OS notification
  /// with the app in the background
  final bool alertOnCountdownEnd;
  final bool useCountdownBetweenSets;
  final Duration countdownDuration;
  final int? logScopeWeeks;
  final bool showDistinctLogs;
  final bool showWorkoutDuration;

  /// Ongoing notification with the rest and the next set (Android)
  final bool showWorkoutNotification;

  /// Whether the log form of a set is pre-filled with the values last
  /// logged for the same exercise, in this or an earlier workout, instead
  /// of the planned ones. Disabled by default.
  final bool stickySetValues;

  /// What happened on the pages so far, by page key. Kept apart from the pages
  /// so that recalculating them doesn't lose it.
  final Map<String, PageProgress> progress;

  /// Exercises added during the workout, in the order they were added
  final List<AddedExercise> addedExercises;

  // Routine data
  late final int dayId;
  late final int iteration;
  late final Routine routine;

  GymModeState({
    this.isInitialized = false,
    this.pages = const [],
    this.currentPage = 0,

    this.showExercisePages = true,
    this.showTimerPages = true,
    this.alertOnCountdownEnd = true,
    this.useCountdownBetweenSets = false,
    this.countdownDuration = const Duration(seconds: DEFAULT_COUNTDOWN_DURATION),
    this.logScopeWeeks,
    this.showDistinctLogs = true,
    this.showWorkoutDuration = true,
    this.showWorkoutNotification = true,
    this.stickySetValues = false,
    this.progress = const {},
    this.addedExercises = const [],
    int? dayId,
    int? iteration,
    Routine? routine,

    DateTime? validUntil,
    DateTime? workoutStart,
  }) : validUntil = validUntil ?? clock.now().add(DEFAULT_DURATION),
       workoutStart = workoutStart ?? clock.now() {
    if (dayId != null) {
      this.dayId = dayId;
    }

    if (iteration != null) {
      this.iteration = iteration;
    }

    if (routine != null) {
      this.routine = routine;
    }
  }

  GymModeState copyWith({
    // Navigation data
    bool? isInitialized,
    List<PageEntry>? pages,
    int? currentPage,

    // Routine data
    int? dayId,
    int? iteration,
    DateTime? validUntil,
    DateTime? workoutStart,
    Routine? routine,

    // User settings
    bool? showExercisePages,
    bool? showTimerPages,
    bool? alertOnCountdownEnd,
    bool? useCountdownBetweenSets,
    int? countdownDuration,
    int? logScopeWeeks,
    bool clearLogScopeWeeks = false,
    bool? showDistinctLogs,
    bool? showWorkoutDuration,
    bool? showWorkoutNotification,
    bool? stickySetValues,
    Map<String, PageProgress>? progress,
    List<AddedExercise>? addedExercises,
  }) {
    return GymModeState(
      isInitialized: isInitialized ?? this.isInitialized,
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,

      dayId: dayId ?? this.dayId,
      iteration: iteration ?? this.iteration,
      validUntil: validUntil ?? this.validUntil,
      workoutStart: workoutStart ?? this.workoutStart,
      routine: routine ?? this.routine,

      showExercisePages: showExercisePages ?? this.showExercisePages,
      showTimerPages: showTimerPages ?? this.showTimerPages,
      alertOnCountdownEnd: alertOnCountdownEnd ?? this.alertOnCountdownEnd,
      useCountdownBetweenSets: useCountdownBetweenSets ?? this.useCountdownBetweenSets,
      countdownDuration: Duration(
        seconds: countdownDuration ?? this.countdownDuration.inSeconds,
      ),
      logScopeWeeks: clearLogScopeWeeks ? null : (logScopeWeeks ?? this.logScopeWeeks),
      showDistinctLogs: showDistinctLogs ?? this.showDistinctLogs,
      showWorkoutDuration: showWorkoutDuration ?? this.showWorkoutDuration,
      showWorkoutNotification: showWorkoutNotification ?? this.showWorkoutNotification,
      stickySetValues: stickySetValues ?? this.stickySetValues,
      progress: progress ?? this.progress,
      addedExercises: addedExercises ?? this.addedExercises,
    );
  }

  PageProgress progressOf(String key) => progress[key] ?? const PageProgress();

  /// Whether every set of [page] has been logged
  bool allLogsDone(PageEntry page) => page.slotPages
      .where((entry) => entry.type == SlotPageType.log)
      .every((entry) => progressOf(entry.key).done);

  /// The start of the workout as a [TimeOfDay], e.g. for the session form
  TimeOfDay get startTime => TimeOfDay.fromDateTime(workoutStart);

  /// Countdown length of a timer page, or null if the rest counts up
  Duration? restDurationFor(SlotPageEntry slotPage) {
    final restTime = slotPage.setConfigData?.restTime;
    if (restTime != null) {
      return Duration(seconds: restTime.toInt());
    }
    return useCountdownBetweenSets ? countdownDuration : null;
  }

  /// When the rest on the current timer page started, null on other pages
  DateTime? get restStartedAt {
    final slotPage = getSlotEntryPageByIndex();
    return slotPage?.type == SlotPageType.timer ? progressOf(slotPage!.key).timerStartedAt : null;
  }

  /// When the countdown on the current timer page ends, null if it counts up
  DateTime? get restEndsAt {
    final startedAt = restStartedAt;
    if (startedAt == null) {
      return null;
    }
    final duration = restDurationFor(getSlotEntryPageByIndex()!);
    return duration == null ? null : startedAt.add(duration);
  }

  int get totalPages {
    // Main pages (start, session, etc.)
    var count = pages.where((p) => p.type != PageType.set).length;

    // Add all other sub pages (sets, timer, etc.)
    count += pages.fold(0, (prev, e) => prev + e.slotPages.length);

    return count;
  }

  DayData get dayDataGym =>
      routine.dayDataGym.where((e) => e.iteration == iteration && e.day?.id == dayId).first;

  DayData get dayDataDisplay => routine.dayData.firstWhere(
    (e) => e.iteration == iteration && e.day?.id == dayId,
  );

  PageEntry? getPageByIndex([int? pageIndex]) {
    final index = pageIndex ?? currentPage;

    for (final page in pages) {
      for (final slotPage in page.slotPages) {
        if (slotPage.pageIndex == index) {
          return page;
        }
      }
    }
    return null;
  }

  SlotPageEntry? getSlotEntryPageByIndex([int? pageIndex]) {
    final index = pageIndex ?? currentPage;

    for (final slotPage in pages.expand((p) => p.slotPages)) {
      if (slotPage.pageIndex == index) {
        return slotPage;
      }
    }
    return null;
  }

  /// Key of the page shown at [pageIndex]
  String? keyOfPage(int pageIndex) {
    for (final page in pages) {
      if (page.type != PageType.set && page.pageIndex == pageIndex) {
        return page.key;
      }
      for (final slotPage in page.slotPages) {
        if (slotPage.pageIndex == pageIndex) {
          return slotPage.key;
        }
      }
    }
    return null;
  }

  /// Index of the page with [key], the reverse of [keyOfPage]
  int? pageIndexOf(String key) {
    for (final page in pages) {
      if (page.type != PageType.set && page.key == key) {
        return page.pageIndex;
      }
    }
    return getSlotPageByKey(key)?.pageIndex;
  }

  SlotPageEntry? getSlotPageByKey(String key) {
    for (final slotPage in pages.expand((p) => p.slotPages)) {
      if (slotPage.key == key) {
        return slotPage;
      }
    }
    return null;
  }

  /// Returns the next log page after the slot page at [pageIndex], i.e. the
  /// set that will be performed once the current rest timer ends.
  ///
  /// This deliberately returns the next *set*, which may belong to the same
  /// exercise (e.g. when progressing weights within an exercise) or to the
  /// next one. Returns null when the workout has no further sets.
  SlotPageEntry? getNextLogPage(int pageIndex) {
    for (final slotPage in pages.expand((p) => p.slotPages)) {
      if (slotPage.pageIndex > pageIndex && slotPage.type == SlotPageType.log) {
        return slotPage;
      }
    }
    return null;
  }

  double get ratioCompleted {
    if (totalPages == 0) {
      return 0.0;
    }

    // Note: add 1 to currentPage to make it 1-based
    return (currentPage + 1) / totalPages;
  }

  @override
  String toString() {
    return 'GymState('
        'currentPage: $currentPage, '
        'restStartedAt: $restStartedAt, '
        'restEndsAt: $restEndsAt, '
        'validUntil: $validUntil '
        'workoutStart: $workoutStart, '
        'showExercisePages: $showExercisePages, '
        'showTimerPages: $showTimerPages, '
        ')';
  }
}
