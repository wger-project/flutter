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

import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/routines/models/added_exercise.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/models/page_progress.dart';
import 'package:wger/features/routines/models/routine.dart';
import 'package:wger/features/routines/models/set_config_data.dart';
import 'package:wger/features/routines/models/weight_unit.dart';
import 'package:wger/features/routines/models/workout_progress.dart';
import 'package:wger/features/routines/providers/gym_log_notifier.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/routines_notifier.dart';
import 'package:wger/features/routines/providers/workout_logs_notifier.dart';
import 'package:wger/features/routines/providers/workout_logs_repository.dart';
import 'package:wger/features/routines/validators.dart';

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

    final logScopeWeeks = await prefs.getInt(PREFS_LOG_SCOPE_WEEKS);
    if (logScopeWeeks != null && logScopeWeeks != state.logScopeWeeks) {
      state = state.copyWith(logScopeWeeks: logScopeWeeks);
    }

    final showDistinctLogs = await prefs.getBool(PREFS_SHOW_DISTINCT_LOGS);
    if (showDistinctLogs != null && showDistinctLogs != state.showDistinctLogs) {
      state = state.copyWith(showDistinctLogs: showDistinctLogs);
    }

    final showWorkoutDuration = await prefs.getBool(PREFS_SHOW_WORKOUT_DURATION);
    if (showWorkoutDuration != null && showWorkoutDuration != state.showWorkoutDuration) {
      state = state.copyWith(showWorkoutDuration: showWorkoutDuration);
    }

    final stickySetValues = await prefs.getBool(PREFS_STICKY_SET_VALUES);
    if (stickySetValues != null && stickySetValues != state.stickySetValues) {
      state = state.copyWith(stickySetValues: stickySetValues);
    }

    final workoutNotification = await prefs.getBool(PREFS_WORKOUT_NOTIFICATION);
    if (workoutNotification != null && workoutNotification != state.showWorkoutNotification) {
      state = state.copyWith(showWorkoutNotification: workoutNotification);
    }

    _logger.finer(
      'Loaded saved preferences: '
      'showExercise=$showExercise '
      'showTimer=$showTimer '
      'alertOnCountdownEnd=$alertOnCountdownEnd '
      'useCountdownBetweenSets=$useCountdownBetweenSets '
      'defaultCountdownDurationSeconds=$defaultCountdownDurationSeconds'
      'logScopeWeeks=$logScopeWeeks '
      'showDistinctLogs=$showDistinctLogs '
      'showWorkoutDuration=$showWorkoutDuration '
      'workoutNotification=$workoutNotification ',
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
    if (state.logScopeWeeks != null) {
      await prefs.setInt(PREFS_LOG_SCOPE_WEEKS, state.logScopeWeeks!);
    } else {
      await prefs.remove(PREFS_LOG_SCOPE_WEEKS);
    }
    await prefs.setBool(PREFS_SHOW_DISTINCT_LOGS, state.showDistinctLogs);
    await prefs.setBool(PREFS_SHOW_WORKOUT_DURATION, state.showWorkoutDuration);
    await prefs.setBool(PREFS_STICKY_SET_VALUES, state.stickySetValues);
    await prefs.setBool(PREFS_WORKOUT_NOTIFICATION, state.showWorkoutNotification);

    _logger.finer(
      'Saved preferences: '
      'showExercise=${state.showExercisePages} '
      'showTimer=${state.showTimerPages} '
      'alertOnCountdownEnd=${state.alertOnCountdownEnd} '
      'useCountdownBetweenSets=${state.useCountdownBetweenSets} '
      'defaultCountdownDuration=${state.countdownDuration.inSeconds}'
      'logScopeWeeks=${state.logScopeWeeks} '
      'showDistinctLogs=${state.showDistinctLogs} '
      'showWorkoutDuration=${state.showWorkoutDuration} '
      'workoutNotification=${state.showWorkoutNotification} ',
    );
  }

  /// Stores the progress through the running workout, since the OS can kill a
  /// backgrounded app at any point, e.g. between two sets
  Future<void> _saveProgress() async {
    // Before initData there is no dayId to store the progress under
    if (!state.isInitialized) {
      return;
    }

    final progress = WorkoutProgress(
      dayId: state.dayId,
      iteration: state.iteration,
      currentPageKey: state.keyOfPage(state.currentPage) ?? 'start',
      workoutStart: state.workoutStart,
      validUntil: state.validUntil,
      pages: {
        for (final MapEntry(:key, :value) in state.progress.entries)
          key: StoredPageProgress(
            done: value.done,
            logId: value.loggedEntry?.id,
            timerStartedAt: value.timerStartedAt,
          ),
      },
    );

    await PreferenceHelper.asyncPref.setString(
      PREFS_WORKOUT_PROGRESS,
      json.encode(progress.toJson()),
    );
    _logger.finer('Saved $progress');
  }

  Future<void> _clearProgress() async {
    await PreferenceHelper.asyncPref.remove(PREFS_WORKOUT_PROGRESS);
    _logger.finer('Cleared stored workout progress');
  }

  /// Opens gym mode for a day and returns the page to start on. Continues the
  /// workout in memory, otherwise starts one that picks up any stored progress.
  Future<int> open(Routine routine, int dayId, int iteration) async {
    final resume = _canResume(dayId);
    final initialPage = initData(routine, dayId, iteration);
    await loadPrefs();

    if (resume && state.pages.isNotEmpty) {
      return initialPage;
    }

    calculatePages();
    return await _restoreProgress() ?? initialPage;
  }

  /// Applies the stored progress to the freshly calculated pages
  ///
  /// Returns the page to continue on, or null when there is nothing to restore.
  Future<int?> _restoreProgress() async {
    final stored = await PreferenceHelper.asyncPref.getString(PREFS_WORKOUT_PROGRESS);
    if (stored == null) {
      return null;
    }

    final WorkoutProgress saved;
    try {
      saved = WorkoutProgress.fromJson(json.decode(stored) as Map<String, dynamic>);
    } catch (e) {
      _logger.warning('Discarding unreadable stored workout progress: $e');
      await _clearProgress();
      return null;
    }

    // Only ever continue the same workout, and only while it is plausibly
    // still running
    if (saved.dayId != state.dayId ||
        saved.iteration != state.iteration ||
        saved.validUntil.isBefore(clock.now())) {
      _logger.fine('Stored workout progress does not apply any more, discarding it');
      await _clearProgress();
      return null;
    }

    // Without the logs the done sets and timers still come back, a correction
    // then inserts a new row instead of updating the old one
    final logIds = saved.pages.values.map((p) => p.logId).nonNulls.toList();
    var logs = <String?, Log>{};
    if (logIds.isNotEmpty) {
      try {
        logs = {
          for (final log in await ref.read(workoutLogRepositoryProvider).getLogsByIds(logIds))
            log.id: log,
        };
      } catch (e) {
        _logger.warning('Could not read the logs of the stored workout progress: $e');
      }
    }

    // Pages the routine no longer has (it was edited, or they were added
    // during the workout) are left out
    final slotPages = state.pages.expand((page) => page.slotPages);
    final progress = {
      for (final slotPage in slotPages)
        if (saved.pages[slotPage.key] case final stored?)
          slotPage.key: PageProgress(
            done: stored.done,
            loggedEntry: logs[stored.logId],
            timerStartedAt: stored.timerStartedAt,
          ),
    };

    state = state.copyWith(
      currentPage: state.pageIndexOf(saved.currentPageKey) ?? 0,
      workoutStart: saved.workoutStart,
      validUntil: saved.validUntil,
      progress: progress,
    );

    _logger.fine('Restored workout progress on page ${state.currentPage}');

    return state.currentPage;
  }

  /// Calculates the page entries
  void calculatePages() {
    var pageIndex = 0;

    final List<PageEntry> pages = [
      // Start page
      PageEntry(type: PageType.start, pageIndex: pageIndex, key: 'start'),
    ];

    // Pages are keyed by a slot entry (a database row) and the number of its
    // set. Counted over the whole day, so an entry in two slots can't collide.
    final setsPerEntry = <int, int>{};
    String nextSet(int slotEntryId) => '$slotEntryId:${(setsPerEntry[slotEntryId] ?? 0) + 1}';

    // Exercises added during the workout follow the page they were added after
    void addAddedPages(String afterKey) {
      for (final (i, added) in state.addedExercises.indexed) {
        if (added.afterPageKey != afterKey) {
          continue;
        }

        final addedKey = 'added:${i + 1}';
        final slotPageIndex = pageIndex;
        pages.add(
          PageEntry(
            type: PageType.set,
            pageIndex: slotPageIndex,
            key: addedKey,
            slotPages: [
              for (var nr = 1; nr <= 4; nr++)
                SlotPageEntry(
                  type: SlotPageType.log,
                  setIndex: nr - 1,
                  pageIndex: pageIndex++,
                  key: '$addedKey:log:$nr',
                  setConfigData: SetConfigData(
                    textRepr: '-/-',
                    exerciseId: added.exercise.id,
                    exercise: added.exercise,
                    slotEntryId: added.slotEntryId,
                    weightUnit: added.weightUnit,
                  ),
                ),
            ],
          ),
        );
        addAddedPages(addedKey);
      }
    }

    pageIndex++;
    for (final (slotIndex, slotData) in state.dayDataGym.slots.indexed) {
      final slotPageIndex = pageIndex;
      final slotEntries = <SlotPageEntry>[];
      int setIndex = 0;

      final firstConfig = slotData.setConfigs.firstOrNull;
      final slotKey = firstConfig == null
          ? 'slot:empty$slotIndex'
          : 'slot:${nextSet(firstConfig.slotEntryId)}';

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
              key: 'overview:${nextSet(setConfig.slotEntryId)}',
              setConfigData: setConfig,
            ),
          );
          pageIndex++;
        }
      }

      for (final config in slotData.setConfigs) {
        final setKey = nextSet(config.slotEntryId);
        setsPerEntry.update(config.slotEntryId, (nr) => nr + 1, ifAbsent: () => 1);

        // Log page
        slotEntries.add(
          SlotPageEntry(
            type: SlotPageType.log,
            setIndex: setIndex,
            pageIndex: pageIndex,
            key: 'log:$setKey',
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
              key: 'timer:$setKey',
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
          key: slotKey,
          slotPages: slotEntries,
        ),
      );
      addAddedPages(slotKey);
    }

    // Session and summary page
    pages.add(PageEntry(type: PageType.session, pageIndex: pageIndex, key: 'session'));
    pages.add(
      PageEntry(type: PageType.workoutSummary, pageIndex: pageIndex + 1, key: 'summary'),
    );

    state = state.copyWith(pages: pages);
    // print(readPageStructure());
    _logger.finer('Initialized ${state.pages.length} pages');
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

  /// Whether the workout in memory is the one for [dayId] and still valid
  bool _canResume(int dayId) =>
      state.isInitialized && dayId == state.dayId && !state.validUntil.isBefore(clock.now());

  int initData(Routine routine, int dayId, int iteration) {
    final currentPage = state.currentPage;

    final shouldReset = !_canResume(dayId);
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
      // A fresh workout also restarts the elapsed timer and the resume window
      workoutStart: shouldReset ? clock.now() : null,
      validUntil: shouldReset ? clock.now().add(DEFAULT_DURATION) : null,
      progress: shouldReset ? const {} : null,
      addedExercises: shouldReset ? const [] : null,
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
    _saveProgress();

    // Re-visiting a page that was already logged in this workout: seed the
    // form with the saved entry (keeping its id and session) so saving
    // updates the row instead of inserting a duplicate.
    final slotPage = state.getSlotEntryPageByIndex();

    // Not only from the timer widget, the notifications need the rest while
    // the app draws no frames in the background
    if (slotPage?.type == SlotPageType.timer) {
      startTimerIfNeeded(slotPage!.key);
    }

    final loggedEntry = slotPage == null ? null : state.progressOf(slotPage.key).loggedEntry;
    if (loggedEntry != null) {
      ref.read(gymLogProvider.notifier).editLog(loggedEntry);
      return;
    }

    startNewEntry();
  }

  /// Seeds the log form of the current page with a fresh entry, also to log
  /// another set on a page that was already logged.
  Future<void> startNewEntry() async {
    // Ensure that there is a log entry for the current slot entry
    final slotEntryPage = state.getSlotEntryPageByIndex();
    if (slotEntryPage == null || slotEntryPage.setConfigData == null) {
      return;
    }

    final logNotifier = ref.read(gymLogProvider.notifier)..setLog(_draftFor(slotEntryPage));
    if (!state.stickySetValues) {
      return;
    }

    // Pre-fill with the values last logged for this exercise, in this or any
    // earlier workout. Read from the DB so they survive however gym mode was
    // left, and a corrected earlier set keeps its date and doesn't win.
    final seeded = ref.read(gymLogProvider);
    final lastValues = await ref
        .read(workoutLogRepositoryProvider)
        .getLatestLogByExercise(slotEntryPage.setConfigData!.exerciseId);

    // Leave the form alone if the user already moved on or started typing
    if (lastValues != null && ref.mounted && identical(ref.read(gymLogProvider), seeded)) {
      logNotifier.copyValuesFrom(lastValues);
    }
  }

  /// The log draft a slot page starts with, prefilled with the planned values
  Log _draftFor(SlotPageEntry slotPage) => Log.fromSetConfigData(
    slotPage.setConfigData!,
    routineId: state.routine.id,
    iteration: state.iteration,
  );

  /// Ends the rest of the current timer page and moves on. No-op on other pages.
  void skipRest() {
    if (state.getSlotEntryPageByIndex()?.type != SlotPageType.timer) {
      return;
    }
    setCurrentPage(state.currentPage + 1);
  }

  /// Adds [extra] to the running countdown, counted from now if the rest is
  /// already over. No-op without a countdown (other pages, count-up rest).
  void extendRest(Duration extra) {
    final slotPage = state.getSlotEntryPageByIndex();
    final endsAt = state.restEndsAt;
    if (slotPage == null || endsAt == null) {
      return;
    }
    final now = clock.now();
    final newEnd = (endsAt.isAfter(now) ? endsAt : now).add(extra);

    // The rest is stored by its start, so the start moves along with the end
    final startedAt = newEnd.subtract(state.restDurationFor(slotPage)!);
    _updateProgress(slotPage.key, (p) => p.copyWith(timerStartedAt: startedAt));
  }

  /// Saves the log draft of the current log page, a new set or a correction,
  /// and moves on to the next page. A failed write propagates to the caller.
  Future<void> logCurrentSet() async {
    final slotPage = state.getSlotEntryPageByIndex();
    final log = ref.read(gymLogProvider);
    if (slotPage == null || slotPage.type != SlotPageType.log || log == null) {
      _logger.warning('logCurrentSet called without a log draft on a log page');
      return;
    }

    // Done before the write, so a repeated logPlannedSet is rejected meanwhile
    final wasDone = state.progressOf(slotPage.key).done;
    _updateProgress(slotPage.key, (p) => p.copyWith(done: true));
    try {
      final logs = ref.read(workoutLogProvider);
      if (log.id == null) {
        await logs.addEntry(log, dayId: state.dayId);
      } else {
        await logs.updateEntry(log);
      }
    } catch (_) {
      _updateProgress(slotPage.key, (p) => p.copyWith(done: wasDone));
      rethrow;
    }
    markSlotPageAsDone(slotPage.key, isDone: true, log: log);

    // The user may have moved on or left gym mode during the write
    if (state.currentPage == slotPage.pageIndex) {
      setCurrentPage(slotPage.pageIndex + 1);
    }
  }

  /// Logs the set of the log page [slotPageKey] without the UI, e.g. from a
  /// notification. From the rest right before it the planned values are logged,
  /// on the page itself the current draft, in both cases the values of
  /// [valuesFrom] if given. False if stale, done or incomplete.
  Future<bool> logPlannedSet(String slotPageKey, {Log? valuesFrom}) async {
    final target = state.getSlotPageByKey(slotPageKey);
    if (target == null || target.type != SlotPageType.log || state.progressOf(target.key).done) {
      return false;
    }

    final onTarget = state.currentPage == target.pageIndex;
    final onRestBefore =
        state.currentPage == target.pageIndex - 1 &&
        state.getSlotEntryPageByIndex()?.type == SlotPageType.timer;
    if (!onTarget && !onRestBefore) {
      return false;
    }

    final log = valuesFrom ?? (onTarget ? ref.read(gymLogProvider) : _draftFor(target));
    if (log == null || !isWorkoutLogComplete(repetitions: log.repetitions, weight: log.weight)) {
      return false;
    }

    if (onRestBefore) {
      setCurrentPage(target.pageIndex);
    }
    if (valuesFrom != null) {
      ref.read(gymLogProvider.notifier).copyValuesFrom(valuesFrom);
    }
    await logCurrentSet();
    return true;
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

  /// Passing null resets the scope to the current routine
  void setLogScopeWeeks(int? weeks) {
    state = state.copyWith(logScopeWeeks: weeks, clearLogScopeWeeks: weeks == null);
    _savePrefs();
  }

  void setShowDistinctLogs(bool value) {
    state = state.copyWith(showDistinctLogs: value);
    _savePrefs();
  }

  void setShowWorkoutDuration(bool value) {
    state = state.copyWith(showWorkoutDuration: value);
    _savePrefs();
  }

  void setStickySetValues(bool value) {
    state = state.copyWith(stickySetValues: value);
    _savePrefs();
  }

  void setShowWorkoutNotification(bool value) {
    state = state.copyWith(showWorkoutNotification: value);
    _savePrefs();
  }

  /// Applies [update] to the progress of the page with [key]
  void _updateProgress(String key, PageProgress Function(PageProgress) update) {
    state = state.copyWith(progress: {...state.progress, key: update(state.progressOf(key))});
    _saveProgress();
  }

  /// Starts the timer of the slot page with [key], unless it is already
  /// running.
  ///
  /// The start time lives in the gym state (not the timer widget) so the
  /// countdown continues when the page is disposed and re-created while
  /// navigating, e.g. when going back to correct a logged set during the
  /// rest period.
  void startTimerIfNeeded(String key) {
    final slotPage = state.getSlotPageByKey(key);
    if (slotPage == null) {
      _logger.warning('No slot page found for key $key');
      return;
    }
    if (state.progressOf(key).timerStartedAt != null) {
      return;
    }

    _updateProgress(key, (p) => p.copyWith(timerStartedAt: clock.now()));
    _logger.fine('Started timer for slot page $key');
  }

  /// [log] is the entry saved from this page during the current workout. It
  /// is kept in the page's progress so revisiting the page pre-fills the form
  /// with the saved values and saving updates the row instead of inserting a
  /// duplicate. Without [log], an entry saved before is kept.
  ///
  /// Saving a new entry, unlike correcting one, also (re)starts the rest timer
  /// that follows the set.
  void markSlotPageAsDone(String key, {required bool isDone, Log? log}) {
    final slotPage = state.getSlotPageByKey(key);
    if (slotPage == null) {
      _logger.warning('No slot page found for key $key');
      return;
    }

    final previousEntry = state.progressOf(key).loggedEntry;

    // A copy, so later edits in the form don't change the saved entry
    _updateProgress(
      key,
      (p) => p.copyWith(done: isDone, loggedEntry: log?.copyWith() ?? p.loggedEntry),
    );
    _logger.fine('Set done=$isDone for slot page $key');

    // Scrolling past the timer (e.g. "jump to") already started it
    final timerPage = state.getSlotEntryPageByIndex(slotPage.pageIndex + 1);
    final isNewEntry = previousEntry?.id != log?.id;
    if (isNewEntry && timerPage?.type == SlotPageType.timer) {
      _updateProgress(timerPage!.key, (p) => p.copyWith(timerStartedAt: clock.now()));
    }
  }

  /// Replaces the exercise everywhere in the workout, also where it was added
  void replaceExercises(
    String pageEntryKey, {
    required int originalExerciseId,
    required Exercise newExercise,
  }) {
    state = state.copyWith(
      routine: state.routine.replaceExercise(originalExerciseId, newExercise),
      addedExercises: [
        for (final added in state.addedExercises)
          if (added.exercise.id == originalExerciseId)
            added.copyWith(exercise: newExercise)
          else
            added,
      ],
    );
    calculatePages();
    _logger.fine('Replaced exercise $originalExerciseId with ${newExercise.id}');
  }

  void addExerciseAfterPage(
    String pageEntryKey, {
    required Exercise newExercise,
  }) {
    final page = state.pages.firstWhereOrNull((p) => p.key == pageEntryKey);
    if (page == null) {
      _logger.warning('No page found for key $pageEntryKey');
      return;
    }

    // Ad-hoc set configs bypass routine hydration, so resolve the profile
    // default weight unit (kg/lb) here; the log draft picks it up from the
    // unit object.
    final profile = ref.read(userProfileProvider).value;
    final weightUnits = ref.read(routineWeightUnitProvider).value ?? const <WeightUnit>[];
    final defaultWeightUnitId = profile?.defaultWeightUnitId ?? WEIGHT_UNIT_KG;
    final defaultWeightUnit = weightUnits.firstWhereOrNull((u) => u.id == defaultWeightUnitId);

    state = state.copyWith(
      addedExercises: [
        ...state.addedExercises,
        AddedExercise(
          afterPageKey: pageEntryKey,
          exercise: newExercise,
          slotEntryId: page.slotPages.first.setConfigData!.slotEntryId,
          weightUnit: defaultWeightUnit,
        ),
      ],
    );
    calculatePages();
  }

  /// Resets the workout start time to now, e.g. when the user taps "start"
  void startWorkout() {
    _logger.fine('Setting workout start time');
    state = state.copyWith(workoutStart: clock.now());
    _saveProgress();
  }

  void clear() {
    _logger.fine('Clearing state');
    state = state.copyWith(
      isInitialized: false,
      pages: [],
      currentPage: 0,
      progress: const {},
      addedExercises: const [],

      validUntil: clock.now().add(DEFAULT_DURATION),
      workoutStart: clock.now(),
    );
    _clearProgress();
  }
}
