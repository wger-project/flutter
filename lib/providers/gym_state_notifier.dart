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
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/providers/gym_log_notifier.dart';
import 'package:wger/providers/gym_state.dart';

part 'gym_state_notifier.g.dart';

@Riverpod(keepAlive: true)
class GymStateNotifier extends _$GymStateNotifier {
  final _logger = Logger('GymStateNotifier');

  @override
  GymModeState build() {
    _logger.finer('Initializing GymStateNotifier');
    return GymModeState();
  }

  Future<void> loadPrefs() async {
    final prefs = PreferenceHelper.asyncPref;

    final showExercise = await prefs.getBool(PREFS_SHOW_EXERCISES);
    if (showExercise != null && showExercise != state.showExercisePages) {
      state = state.copyWith(showExercisePages: showExercise);
    }

    final showTimer = await prefs.getBool(PREFS_SHOW_TIMER);
    if (showTimer != null && showTimer != state.showTimerPages) {
      state = state.copyWith(showTimerPages: showTimer);
    }

    final alertOnCountdownEnd = await prefs.getBool(PREFS_ALERT_COUNTDOWN);
    if (alertOnCountdownEnd != null && alertOnCountdownEnd != state.alertOnCountdownEnd) {
      state = state.copyWith(alertOnCountdownEnd: alertOnCountdownEnd);
    }

    final useCountdownBetweenSets = await prefs.getBool(PREFS_USE_COUNTDOWN_BETWEEN_SETS);
    if (useCountdownBetweenSets != null &&
        useCountdownBetweenSets != state.useCountdownBetweenSets) {
      state = state.copyWith(useCountdownBetweenSets: useCountdownBetweenSets);
    }

    final defaultCountdownDurationSeconds = await prefs.getInt(PREFS_COUNTDOWN_DURATION);
    if (defaultCountdownDurationSeconds != null &&
        defaultCountdownDurationSeconds != state.countdownDuration.inSeconds) {
      state = state.copyWith(
        countdownDuration: defaultCountdownDurationSeconds,
      );
    }

    _logger.finer(
      'Loaded saved preferences: '
      'showExercise=$showExercise '
      'showTimer=$showTimer '
      'alertOnCountdownEnd=$alertOnCountdownEnd '
      'useCountdownBetweenSets=$useCountdownBetweenSets '
      'defaultCountdownDurationSeconds=$defaultCountdownDurationSeconds',
    );
  }

  Future<void> _savePrefs() async {
    final prefs = PreferenceHelper.asyncPref;
    await prefs.setBool(PREFS_SHOW_EXERCISES, state.showExercisePages);
    await prefs.setBool(PREFS_SHOW_TIMER, state.showTimerPages);
    await prefs.setBool(PREFS_ALERT_COUNTDOWN, state.alertOnCountdownEnd);
    await prefs.setBool(PREFS_USE_COUNTDOWN_BETWEEN_SETS, state.useCountdownBetweenSets);
    await prefs.setInt(
      PREFS_COUNTDOWN_DURATION,
      state.countdownDuration.inSeconds,
    );
    _logger.finer(
      'Saved preferences: '
      'showExercise=${state.showExercisePages} '
      'showTimer=${state.showTimerPages} '
      'alertOnCountdownEnd=${state.alertOnCountdownEnd} '
      'useCountdownBetweenSets=${state.useCountdownBetweenSets} '
      'defaultCountdownDuration=${state.countdownDuration.inSeconds}',
    );
  }

  /// Calculates the page entries
  void calculatePages() {
    var pageIndex = 0;

    final List<PageEntry> pages = [
      // Start page
      PageEntry(type: PageType.start, pageIndex: pageIndex),
    ];

    pageIndex++;
    for (final slotData in state.dayDataGym.slots) {
      final slotPageIndex = pageIndex;
      final slotEntries = <SlotPageEntry>[];
      int setIndex = 0;

      // exercise overview page
      if (state.showExercisePages) {
        // Add one overview page per exercise in the slot (e.g. for supersets)
        for (final exerciseId in slotData.exerciseIds) {
          final setConfig = slotData.setConfigs.firstWhereOrNull((c) => c.exerciseId == exerciseId);
          if (setConfig == null) {
            _logger.warning('Exercise with ID $exerciseId not found in slotData!!');
            continue;
          }

          slotEntries.add(
            SlotPageEntry(
              type: SlotPageType.exerciseOverview,
              setIndex: setIndex,
              pageIndex: pageIndex,
              setConfigData: setConfig,
            ),
          );
          pageIndex++;
        }
      }

      for (final config in slotData.setConfigs) {
        // Log page
        slotEntries.add(
          SlotPageEntry(
            type: SlotPageType.log,
            setIndex: setIndex,
            pageIndex: pageIndex,
            setConfigData: config,
          ),
        );
        pageIndex++;
        setIndex++;

        // Timer page
        if (state.showTimerPages) {
          slotEntries.add(
            SlotPageEntry(
              type: SlotPageType.timer,
              setIndex: setIndex,
              pageIndex: pageIndex,
              setConfigData: config,
            ),
          );
          pageIndex++;
        }
      }

      pages.add(
        PageEntry(
          type: PageType.set,
          pageIndex: slotPageIndex,
          slotPages: slotEntries,
        ),
      );
    }

    // Session and summary page
    pages.add(PageEntry(type: PageType.session, pageIndex: pageIndex));
    pages.add(PageEntry(type: PageType.workoutSummary, pageIndex: pageIndex + 1));

    state = state.copyWith(pages: pages);
    // print(readPageStructure());
    _logger.finer('Initialized ${state.pages.length} pages');
  }

  // Recalculates the indices of all pages
  void recalculateIndices() {
    var pageIndex = 0;
    final updatedPages = <PageEntry>[];

    for (final page in state.pages) {
      final slotPageIndex = pageIndex;
      var setIndex = 0;
      final updatedSlotPages = <SlotPageEntry>[];

      for (final slotPage in page.slotPages) {
        updatedSlotPages.add(
          slotPage.copyWith(
            pageIndex: pageIndex,
            setIndex: setIndex,
          ),
        );
        setIndex++;
        pageIndex++;
      }

      if (page.type != PageType.set) {
        pageIndex++;
      }

      updatedPages.add(
        page.copyWith(
          pageIndex: slotPageIndex,
          slotPages: updatedSlotPages,
        ),
      );
    }

    state = state.copyWith(pages: updatedPages);
    // _logger.fine(readPageStructure());
    _logger.fine('Recalculated page indices');
  }

  /// Reads the current page structure for debugging purposes
  String readPageStructure() {
    final List<String> out = [];
    out.add('GymModeState structure:');
    for (final page in state.pages) {
      out.add('Page ${page.pageIndex}: ${page.type}');
      for (final slotPage in page.slotPages) {
        out.add(
          '  SlotPage ${slotPage.pageIndex.toString().padLeft(2, ' ')} (set index ${slotPage.setIndex}): ${slotPage.type}',
        );
      }
    }

    return out.join('\n');
  }

  int initData(Routine routine, int dayId, int iteration) {
    final validUntil = state.validUntil;
    final currentPage = state.currentPage;

    final shouldReset =
        (!state.isInitialized || state.isInitialized && dayId != state.dayId) ||
        validUntil.isBefore(DateTime.now());
    if (shouldReset) {
      _logger.fine('Day ID mismatch or expired validUntil date. Resetting to page 0.');
    }
    final initialPage = shouldReset ? 0 : currentPage;

    // set dayId and initial page
    state = state.copyWith(
      isInitialized: true,
      dayId: dayId,
      routine: routine,
      iteration: iteration,
      currentPage: initialPage,
    );

    // Calculate the pages.
    // Note that this is only done if we need to reset, otherwise we keep the
    // existing state like the exercises that have already been done
    if (shouldReset) {
      calculatePages();
    }

    _logger.fine('Initialized GymModeState, initialPage=$initialPage');
    return initialPage;
  }

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);

    // Ensure that there is a log entry for the current slot entry
    final slotEntryPage = state.getSlotEntryPageByIndex();
    if (slotEntryPage == null || slotEntryPage.setConfigData == null) {
      return;
    }

    final log = Log.fromSetConfigData(slotEntryPage.setConfigData!);
    log.routineId = state.routine.id!;
    log.iteration = state.iteration;
    ref.read(gymLogProvider.notifier).setLog(log);
  }

  void setShowExercisePages(bool value) {
    state = state.copyWith(showExercisePages: value);
    calculatePages();
    _savePrefs();
  }

  void setShowTimerPages(bool value) {
    state = state.copyWith(showTimerPages: value);
    calculatePages();
    _savePrefs();
  }

  void setAlertOnCountdownEnd(bool value) {
    state = state.copyWith(alertOnCountdownEnd: value);
    _savePrefs();
  }

  void setUseCountdownBetweenSets(bool value) {
    state = state.copyWith(useCountdownBetweenSets: value);
    _savePrefs();
  }

  void setCountdownDuration(int duration) {
    state = state.copyWith(countdownDuration: duration);
    _savePrefs();
  }

  void markSlotPageAsDone(String uuid, {required bool isDone}) {
    final slotPage = state.getSlotPageByUUID(uuid);
    if (slotPage == null) {
      _logger.warning('No slot page found for UUID $uuid');
      return;
    }

    final updatedSlotPage = slotPage.copyWith(logDone: isDone);

    final updatedPages = state.pages.map((page) {
      if (page.type != PageType.set) {
        return page;
      }

      final updatedSlotPages = page.slotPages.map((sp) {
        if (sp.uuid == uuid) {
          return updatedSlotPage;
        }
        return sp;
      }).toList();

      return page.copyWith(slotPages: updatedSlotPages);
    }).toList();

    state = state.copyWith(pages: updatedPages);
    _logger.fine('Set logDone=$isDone for slot page UUID $uuid');
  }

  void replaceExercises(
    String pageEntryUUID, {
    required int originalExerciseId,
    required Exercise newExercise,
  }) {
    final updatedPages = state.pages.map((page) {
      if (page.type != PageType.set) {
        return page;
      }

      if (page.uuid != pageEntryUUID) {
        return page;
      }

      final updatedSlotPages = page.slotPages.map((slotPage) {
        if (slotPage.setConfigData != null &&
            slotPage.setConfigData!.exercise.id == originalExerciseId) {
          final updatedSetConfigData = slotPage.setConfigData!.copyWith(
            exerciseId: newExercise.id,
            exercise: newExercise,
          );
          return slotPage.copyWith(setConfigData: updatedSetConfigData);
        }
        return slotPage;
      }).toList();

      return page.copyWith(slotPages: updatedSlotPages);
    }).toList();

    // replace and update new immutable routine instance
    final updatedRoutine = state.routine.replaceExercise(originalExerciseId, newExercise);
    state = state.copyWith(
      pages: updatedPages,
      routine: updatedRoutine,
    );
    _logger.fine('Replaced exercise $originalExerciseId with ${newExercise.id}');
  }

  void addExerciseAfterPage(
    String pageEntryUUID, {
    required Exercise newExercise,
  }) {
    final List<PageEntry> pages = [];
    for (final page in state.pages) {
      pages.add(page);

      if (page.uuid == pageEntryUUID) {
        final setConfigData = page.slotPages.first.setConfigData!;

        final List<SlotPageEntry> newSlotPages = [];
        for (var i = 1; i <= 4; i++) {
          newSlotPages.add(
            SlotPageEntry(
              type: SlotPageType.log,
              pageIndex: 1,
              setIndex: 0,
              setConfigData: SetConfigData(
                textRepr: '-/-',
                exerciseId: newExercise.id,
                exercise: newExercise,
                slotEntryId: setConfigData.slotEntryId,
              ),
            ),
          );
        }

        final newPage = PageEntry(type: PageType.set, pageIndex: 1, slotPages: newSlotPages);

        pages.add(newPage);
      }
    }

    state = state.copyWith(
      pages: pages,
    );

    recalculateIndices();
  }

  void clear() {
    _logger.fine('Clearing state');
    state = state.copyWith(
      isInitialized: false,
      pages: [],
      currentPage: 0,

      validUntil: clock.now().add(DEFAULT_DURATION),
      startTime: null,
    );
  }
}
