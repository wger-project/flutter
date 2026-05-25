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
import 'package:flutter/material.dart';
import 'package:wger/helpers/uuid.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/set_config_data.dart';

const DEFAULT_DURATION = Duration(hours: 5);

const PREFS_SHOW_EXERCISES = 'showExercisePrefs';
const PREFS_SHOW_TIMER = 'showTimerPrefs';
const PREFS_ALERT_COUNTDOWN = 'alertCountdownPrefs';
const PREFS_USE_COUNTDOWN_BETWEEN_SETS = 'useCountdownBetweenSetsPrefs';
const PREFS_COUNTDOWN_DURATION = 'countdownDurationSecondsPrefs';

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
      exerciseSet.add(entry.setConfigData!.exercise);
    }
    return exerciseSet.toList();
  }

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

  SlotPageEntry({
    required this.type,
    required this.pageIndex,
    required this.setIndex,
    this.setConfigData,
    this.logDone = false,
    String? uuid,
  }) : assert(
         type != SlotPageType.log || setConfigData != null,
         'You need to set setConfigData for SlotPageType.log',
       ),
       uuid = uuid ?? uuidV4();

  SlotPageEntry copyWith({
    String? uuid,
    SlotPageType? type,
    int? exerciseId,
    int? setIndex,
    int? pageIndex,
    SetConfigData? setConfigData,
    bool? logDone,
  }) {
    return SlotPageEntry(
      uuid: uuid ?? this.uuid,
      type: type ?? this.type,
      setIndex: setIndex ?? this.setIndex,
      pageIndex: pageIndex ?? this.pageIndex,
      setConfigData: setConfigData ?? this.setConfigData,
      logDone: logDone ?? this.logDone,
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

  final TimeOfDay startTime;
  final DateTime validUntil;

  // User settings
  final bool showExercisePages;
  final bool showTimerPages;
  final bool alertOnCountdownEnd;
  final bool useCountdownBetweenSets;
  final Duration countdownDuration;

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

    int? dayId,
    int? iteration,
    Routine? routine,

    DateTime? validUntil,
    TimeOfDay? startTime,
  }) : validUntil = validUntil ?? clock.now().add(DEFAULT_DURATION),
       startTime = startTime ?? TimeOfDay.fromDateTime(clock.now()) {
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
    TimeOfDay? startTime,
    Routine? routine,

    // User settings
    bool? showExercisePages,
    bool? showTimerPages,
    bool? alertOnCountdownEnd,
    bool? useCountdownBetweenSets,
    int? countdownDuration,
  }) {
    return GymModeState(
      isInitialized: isInitialized ?? this.isInitialized,
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,

      dayId: dayId ?? this.dayId,
      iteration: iteration ?? this.iteration,
      validUntil: validUntil ?? this.validUntil,
      startTime: startTime ?? this.startTime,
      routine: routine ?? this.routine,

      showExercisePages: showExercisePages ?? this.showExercisePages,
      showTimerPages: showTimerPages ?? this.showTimerPages,
      alertOnCountdownEnd: alertOnCountdownEnd ?? this.alertOnCountdownEnd,
      useCountdownBetweenSets: useCountdownBetweenSets ?? this.useCountdownBetweenSets,
      countdownDuration: Duration(
        seconds: countdownDuration ?? this.countdownDuration.inSeconds,
      ),
    );
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
        'startTime: $startTime, '
        'showExercisePages: $showExercisePages, '
        'showTimerPages: $showTimerPages, '
        ')';
  }
}
