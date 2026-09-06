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
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:wger/core/uuid.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/routines/models/day_data.dart';
import 'package:wger/features/routines/models/routine.dart';
import 'package:wger/features/routines/models/set_config_data.dart';
import 'package:wger/features/routines/models/slot_entry.dart';

const DEFAULT_DURATION = Duration(hours: 5);

const PREFS_SHOW_EXERCISES = 'showExercisePrefs';
const PREFS_SHOW_TIMER = 'showTimerPrefs';
const PREFS_ALERT_COUNTDOWN = 'alertCountdownPrefs';
const PREFS_USE_COUNTDOWN_BETWEEN_SETS = 'useCountdownBetweenSetsPrefs';
const PREFS_COUNTDOWN_DURATION = 'countdownDurationSecondsPrefs';
const PREFS_LOG_SCOPE_WEEKS = 'logScopeWeeksPrefs';
const PREFS_SHOW_DISTINCT_LOGS = 'showDistinctLogsPrefs';
const PREFS_SHOW_WORKOUT_DURATION = 'showWorkoutDurationPrefs';

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
  final String uuid;

  final PageType type;

  /// Absolute page index
  final int pageIndex;

  final List<SlotPageEntry> slotPages;

  PageEntry({
    required this.type,
    required this.pageIndex,
    this.slotPages = const [],
    String? uuid,
  }) : uuid = uuid ?? uuidV4(),
       assert(
         slotPages.isEmpty || type == PageType.set,
         'SlotEntries can only be set for set pages',
       );

  PageEntry copyWith({
    String? uuid,
    PageType? type,
    int? pageIndex,
    List<SlotPageEntry>? slotPages,
  }) {
    return PageEntry(
      uuid: uuid ?? this.uuid,
      type: type ?? this.type,
      pageIndex: pageIndex ?? this.pageIndex,
      slotPages: slotPages ?? this.slotPages,
    );
  }

  List<Exercise> get exercises {
    final exerciseSet = <Exercise>{};
    for (final entry in slotPages) {
      final exercise = entry.setConfigData?.exerciseOrNull;
      if (exercise != null) {
        exerciseSet.add(exercise);
      }
    }
    return exerciseSet.toList();
  }

  /// Whether this page groups several exercises, i.e. is a superset.
  bool get isSuperset => exercises.length > 1;

  // Whether all sub-pages (e.g. log pages) are marked as done.
  bool get allLogsDone =>
      slotPages.where((entry) => entry.type == SlotPageType.log).every((entry) => entry.logDone);

  @override
  String toString() => 'PageEntry(type: $type, pageIndex: $pageIndex)';
}

class SlotPageEntry {
  final String uuid;

  final SlotPageType type;

  /// index within a set for overview (e.g. "1 of 5 sets")
  final int setIndex;

  /// Absolute page index
  final int pageIndex;

  /// Whether the log page has been marked as done
  final bool logDone;

  /// The associated SetConfigData
  final SetConfigData? setConfigData;

  /// What the user actually logged for this set, as opposed to the routine
  /// target in [setConfigData]. These live here — in the keep-alive gym state —
  /// rather than in the log page's widget State because the `PageView` disposes
  /// off-screen pages: keeping them in the widget meant every logged weight was
  /// silently replaced by the (often empty) target on the way back (FR-persist).
  final num? loggedWeight;
  final num? loggedReps;
  final num? loggedRir;

  /// The weight unit the set was logged in. Set rows stay pinned to it, so
  /// flipping the kg/lb toggle never relabels an already-logged set.
  final int? loggedWeightUnitId;

  /// Id of the persisted `Log`, once written.
  final String? logId;

  /// Set type the user picked in-session, overriding [SetConfigData.type].
  final SlotEntryType? typeOverride;

  SlotPageEntry({
    required this.type,
    required this.pageIndex,
    required this.setIndex,
    this.setConfigData,
    this.logDone = false,
    this.loggedWeight,
    this.loggedReps,
    this.loggedRir,
    this.loggedWeightUnitId,
    this.logId,
    this.typeOverride,
    String? uuid,
  }) : assert(
         type != SlotPageType.log || setConfigData != null,
         'You need to set setConfigData for SlotPageType.log',
       ),
       uuid = uuid ?? uuidV4();

  /// Pass [overwriteLogged] to take the `logged*` / [logId] arguments verbatim,
  /// nulls included. Without it the usual `?? this.x` fallbacks apply, which
  /// makes clearing a value — or logging a set with a blank weight — impossible.
  SlotPageEntry copyWith({
    String? uuid,
    SlotPageType? type,
    int? exerciseId,
    int? setIndex,
    int? pageIndex,
    SetConfigData? setConfigData,
    bool? logDone,
    num? loggedWeight,
    num? loggedReps,
    num? loggedRir,
    int? loggedWeightUnitId,
    String? logId,
    SlotEntryType? typeOverride,
    bool overwriteLogged = false,
  }) {
    return SlotPageEntry(
      uuid: uuid ?? this.uuid,
      type: type ?? this.type,
      setIndex: setIndex ?? this.setIndex,
      pageIndex: pageIndex ?? this.pageIndex,
      setConfigData: setConfigData ?? this.setConfigData,
      logDone: logDone ?? this.logDone,
      loggedWeight: overwriteLogged ? loggedWeight : (loggedWeight ?? this.loggedWeight),
      loggedReps: overwriteLogged ? loggedReps : (loggedReps ?? this.loggedReps),
      loggedRir: overwriteLogged ? loggedRir : (loggedRir ?? this.loggedRir),
      loggedWeightUnitId: overwriteLogged
          ? loggedWeightUnitId
          : (loggedWeightUnitId ?? this.loggedWeightUnitId),
      logId: overwriteLogged ? logId : (logId ?? this.logId),
      typeOverride: typeOverride ?? this.typeOverride,
    );
  }

  @override
  String toString() =>
      'SlotPageEntry('
      'uuid: $uuid, '
      'type: $type, '
      'setIndex: $setIndex, '
      'pageIndex: $pageIndex, '
      'logDone: $logDone'
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
  final bool alertOnCountdownEnd;
  final bool useCountdownBetweenSets;
  final Duration countdownDuration;
  final int? logScopeWeeks;
  final bool showDistinctLogs;
  final bool showWorkoutDuration;

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
    );
  }

  /// The start of the workout as a [TimeOfDay], e.g. for the session form
  TimeOfDay get startTime => TimeOfDay.fromDateTime(workoutStart);

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

  /// Maps a model [pageIndex] to its index within the gym-mode `PageView`.
  ///
  /// The model assigns a [pageIndex] to every slot page (including
  /// exercise-overview and rest-timer pages), but the `PageView` renders only
  /// the start page, **one page per exercise** (set [PageEntry]), and the
  /// session + summary pages. This translation keeps navigation (queue jumps,
  /// auto-advance, finish) landing on the correct rendered page.
  int renderIndexFor(int pageIndex) {
    final setPages = pages.where((p) => p.type == PageType.set).toList();
    final session = pages.firstWhereOrNull((p) => p.type == PageType.session);

    for (var i = 0; i < setPages.length; i++) {
      final start = setPages[i].pageIndex;
      final end = (i + 1 < setPages.length)
          ? setPages[i + 1].pageIndex
          : (session?.pageIndex ?? (1 << 30));
      if (pageIndex >= start && pageIndex < end) {
        return i + 1; // index 0 is the start page
      }
    }

    // Past the last exercise: the session page comes first, then the summary.
    if (session != null && pageIndex > session.pageIndex) {
      return setPages.length + 2; // summary
    }
    return setPages.length + 1; // session
  }

  /// The set [PageEntry] rendered at PageView index [renderIndex], or null if
  /// that index is the start, session or summary page (which have no exercise
  /// queue / header chrome). See [renderIndexFor] for the index mapping.
  PageEntry? setPageForRenderIndex(int renderIndex) {
    final setPages = pages.where((p) => p.type == PageType.set).toList();
    if (renderIndex >= 1 && renderIndex <= setPages.length) {
      return setPages[renderIndex - 1];
    }
    return null;
  }

  SlotPageEntry? getSlotPageByUUID(String uuid) {
    for (final slotPage in pages.expand((p) => p.slotPages)) {
      if (slotPage.uuid == uuid) {
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
        'validUntil: $validUntil '
        'workoutStart: $workoutStart, '
        'showExercisePages: $showExercisePages, '
        'showTimerPages: $showTimerPages, '
        ')';
  }
}
