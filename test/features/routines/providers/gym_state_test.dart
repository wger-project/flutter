/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020, 2025 wger Team
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/account/models/user_profile.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/routines/models/day.dart';
import 'package:wger/features/routines/models/day_data.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/models/routine.dart';
import 'package:wger/features/routines/models/set_config_data.dart';
import 'package:wger/features/routines/models/slot_data.dart';
import 'package:wger/features/routines/providers/gym_log_notifier.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/providers/routines_notifier.dart';

import '../../../../test_data/exercises.dart';
import '../../../../test_data/routines.dart';
import '../helpers/routine_form_test_overrides.dart';

void main() {
  late GymStateNotifier notifier;
  late ProviderContainer container;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

    container = ProviderContainer.test();
    notifier = container.read(gymStateProvider.notifier);
    notifier.state = notifier.state.copyWith(
      showExercisePages: true,
      showTimerPages: true,
      dayId: 1,
      iteration: 1,
      routine: getTestRoutine(),
    );
    notifier.calculatePages();
  });

  group('GymStateNotifier.markSlotPageAsDone', () {
    test('Correctly changes the flag', () {
      // Arrange
      final slotPage = notifier.state.pages[1].slotPages[1];
      expect(slotPage.type, SlotPageType.log);
      expect(
        notifier.state.pages.every((p) => p.slotPages.every((s) => !s.logDone)),
        true,
        reason: 'All slot pages are initially not done',
      );

      // Act
      notifier.markSlotPageAsDone(slotPage.uuid, isDone: true);

      // Assert
      for (final page in notifier.state.pages.where((p) => p.type == PageType.set)) {
        for (final slot in page.slotPages.where((s) => s.type == SlotPageType.log)) {
          if (slot.uuid == slotPage.uuid) {
            expect(slot.logDone, true);
          } else {
            expect(slot.logDone, false);
          }
        }
      }
    });
  });

  group('GymStateNotifier.recalculateIndices', () {
    test('Correctly recalculates indices if new pages are added', () {
      // Arrange
      final newPages = [
        ...notifier.state.pages.sublist(0, 2),
        PageEntry(
          type: PageType.set,
          pageIndex: 1111,
          uuid: 'new-page-1',
        ),
        PageEntry(
          type: PageType.set,
          pageIndex: 9,
          uuid: 'new-page-2',
        ),
        ...notifier.state.pages.sublist(2),
        PageEntry(
          type: PageType.set,
          pageIndex: 0,
          uuid: 'new-page-3',
          slotPages: [
            SlotPageEntry(
              type: SlotPageType.timer,
              pageIndex: 10,
              setIndex: 9,
              uuid: 'new-slot-1',
            ),
            SlotPageEntry(
              type: SlotPageType.timer,
              pageIndex: 10,
              setIndex: 6,
              uuid: 'new-slot-2',
            ),
            SlotPageEntry(
              type: SlotPageType.timer,
              pageIndex: 100,
              setIndex: 100,
              uuid: 'new-slot-3',
            ),
          ],
        ),
      ];
      notifier.state = notifier.state.copyWith(pages: newPages);

      // Act
      notifier.recalculateIndices();

      // Assert
      final pages = notifier.state.pages;
      expect(pages[0].pageIndex, 0);
      expect(pages[1].pageIndex, 1);

      // These three have the same pageIndex because the new ones don't have any slot
      // pages (this should not happen in practice)
      expect(pages[2].pageIndex, 8);
      expect(pages[3].pageIndex, 8);
      expect(pages[4].pageIndex, 8);

      expect(pages[5].pageIndex, 15);
      expect(pages[6].pageIndex, 16);
      expect(pages[7].pageIndex, 17);

      // Preserve the order of new pages
      expect(pages[7].uuid, 'new-page-3');

      // Slot pages have correct indices, the original order is preserved
      final slotPages = pages[7].slotPages;
      expect(slotPages[0].uuid, 'new-slot-1');
      expect(slotPages[0].pageIndex, 17);
      expect(slotPages[0].setIndex, 0);
      expect(slotPages[1].uuid, 'new-slot-2');
      expect(slotPages[1].pageIndex, 18);
      expect(slotPages[1].setIndex, 1);
      expect(slotPages[2].uuid, 'new-slot-3');
      expect(slotPages[2].pageIndex, 19);
      expect(slotPages[2].setIndex, 2);
    });
  });

  group('GymStateNotifier.replaceExercises', () {
    test('Correctly swaps an exercise', () {
      // Arrange
      final page = notifier.state.pages[1];
      final slotPage = page.slotPages[1];
      expect(slotPage.type, SlotPageType.log);
      expect(
        notifier.state.pages.every((p) => p.exercises.every((e) => e.id != testSquats.id)),
        isTrue,
        reason: 'the new exercise is not part of the routine yet',
      );

      // Act
      notifier.replaceExercises(page.uuid, originalExerciseId: 1, newExercise: testSquats);

      // Assert: every slot page of that page carries the new exercise, and the
      // routine itself was rebuilt too (the log draft reads from it)
      final updated = notifier.state.pages[1];
      expect(
        updated.slotPages
            .where((s) => s.setConfigData != null)
            .map((s) => s.setConfigData!.exercise.id),
        everyElement(testSquats.id),
      );
      expect(updated.exercises.map((e) => e.id), everyElement(testSquats.id));
      expect(
        notifier.state.routine.dayDataGym
            .expand((d) => d.slots)
            .expand((s) => s.setConfigs)
            .every((c) => c.exerciseId != 1),
        isTrue,
        reason: 'the replaced exercise is gone from the routine',
      );
    });
  });

  group('GymStateNotifier.addExerciseAfterPage', () {
    test('Stamps the profile default weight unit on the ad-hoc set configs', () async {
      // Ad-hoc exercises bypass routine hydration, so the notifier itself
      // resolves the profile default: lb (id 2) for an imperial user.
      final profileRepo = MockUserProfileRepository();
      when(
        profileRepo.watchDrift(),
      ).thenAnswer((_) => Stream.value(UserProfile(id: 1, weightUnitStr: 'lb')));

      final imperialContainer = ProviderContainer.test(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(profileRepo),
          routineWeightUnitProvider.overrideWith((ref) => Stream.value(testWeightUnits)),
        ],
      );
      // Let both streams emit before the notifier reads them (in the app the
      // dashboard keeps them alive long before gym mode starts).
      imperialContainer.listen(userProfileProvider, (_, _) {});
      imperialContainer.listen(routineWeightUnitProvider, (_, _) {});
      await pumpEventQueue();

      final imperialNotifier = imperialContainer.read(gymStateProvider.notifier);
      imperialNotifier.state = imperialNotifier.state.copyWith(
        showExercisePages: true,
        showTimerPages: true,
        dayId: 1,
        iteration: 1,
        routine: getTestRoutine(),
      );
      imperialNotifier.calculatePages();
      final setPage = imperialNotifier.state.pages.firstWhere((p) => p.type == PageType.set);

      imperialNotifier.addExerciseAfterPage(setPage.uuid, newExercise: testSquats);

      // recalculateIndices copies the page objects, so look the page up by uuid.
      final pages = imperialNotifier.state.pages;
      final newPage = pages[pages.indexWhere((p) => p.uuid == setPage.uuid) + 1];
      expect(newPage.slotPages, isNotEmpty);
      for (final slotPage in newPage.slotPages) {
        // testWeightUnit2 has id 2 == WEIGHT_UNIT_LB.
        expect(slotPage.setConfigData!.weightUnit, testWeightUnit2);
        expect(slotPage.setConfigData!.weightUnitId, isNull);
      }
    });
  });

  group('GymStateNotifier.calculatePages, supersets', () {
    // A superset slot holds several exercises that are trained alternating.
    // calculatePages then has to emit one overview page per exercise instead
    // of the single one a normal slot gets.

    SetConfigData configFor(int exerciseId, Exercise exercise) => SetConfigData(
      exerciseId: exerciseId,
      exercise: exercise,
      slotEntryId: exerciseId,
      nrOfSets: 1,
      repetitions: 8,
      repetitionsUnit: testRepetitionUnits.first,
      weight: 40,
      weightUnit: testWeightUnits.first,
      restTime: 60,
      textRepr: '8x40kg',
    );

    /// A routine whose only slot supersets [exerciseIds].
    Routine supersetRoutine(List<int> exerciseIds, {List<SetConfigData>? setConfigs}) {
      final exercises = getTestExercises();
      final day = Day(id: 1, routineId: 1, name: 'Superset day');

      return getTestRoutine()
        ..dayDataGym = [
          DayData(
            iteration: 1,
            date: DateTime(2024, 11, 1),
            day: day,
            slots: [
              SlotData(
                isSuperset: true,
                exerciseIds: exerciseIds,
                setConfigs:
                    setConfigs ?? [for (final id in exerciseIds) configFor(id, exercises[id - 1])],
              ),
            ],
          ),
        ];
    }

    test('emits one overview page per exercise of the slot', () {
      notifier.state = notifier.state.copyWith(
        showExercisePages: true,
        showTimerPages: false,
        dayId: 1,
        iteration: 1,
        routine: supersetRoutine([1, 2]),
      );

      notifier.calculatePages();

      final slotPages = notifier.state.pages[1].slotPages;
      final overviews = slotPages.where((p) => p.type == SlotPageType.exerciseOverview);
      expect(overviews, hasLength(2));
      expect(
        overviews.map((p) => p.setConfigData!.exerciseId),
        [1, 2],
        reason: 'each exercise of the superset gets its own overview page',
      );
      expect(slotPages.where((p) => p.type == SlotPageType.log), hasLength(2));
    });

    test('page indices stay consecutive across the superset', () {
      notifier.state = notifier.state.copyWith(
        showExercisePages: true,
        showTimerPages: false,
        dayId: 1,
        iteration: 1,
        routine: supersetRoutine([1, 2]),
      );

      notifier.calculatePages();

      final indices = notifier.state.pages[1].slotPages.map((p) => p.pageIndex);
      expect(indices, [1, 2, 3, 4]);
    });

    test('an exercise without a set config is skipped instead of crashing', () {
      // The exercise list and the set configs come from separate parts of the
      // API response, so they can disagree while a routine is being edited
      final exercises = getTestExercises();
      final routine = supersetRoutine(
        [1, 2],
        setConfigs: [configFor(1, exercises[0])],
      );
      notifier.state = notifier.state.copyWith(
        showExercisePages: true,
        showTimerPages: false,
        dayId: 1,
        iteration: 1,
        routine: routine,
      );

      notifier.calculatePages();

      final slotPages = notifier.state.pages[1].slotPages;
      expect(
        slotPages
            .where((p) => p.type == SlotPageType.exerciseOverview)
            .single
            .setConfigData!
            .exerciseId,
        1,
      );
      expect(slotPages.where((p) => p.type == SlotPageType.log), hasLength(1));
    });
  });

  group('GymStateNotifier.calculatePages', () {
    test(
      'Correctly generates pages - exercise and timer',
      () {
        // Arrange
        notifier.state = notifier.state.copyWith(
          showExercisePages: true,
          showTimerPages: true,
        );

        // Act
        notifier.calculatePages();

        // Assert
        final pages = notifier.state.pages;
        final setEntry = pages.firstWhere((p) => p.type == PageType.set);
        expect(pages.length, 5, reason: '5 PageEntries (start, set 1, set 2, session, summary)');
        expect(
          setEntry.slotPages.where((p) => p.type == SlotPageType.log).length,
          3,
          reason: 'Three sets',
        );
        expect(
          setEntry.slotPages.where((p) => p.type == SlotPageType.timer).length,
          3,
          reason: 'One timer after each set',
        );
        expect(
          setEntry.slotPages.where((p) => p.type == SlotPageType.exerciseOverview).length,
          1,
          reason: 'One exercise overview at the start',
        );
        expect(setEntry.slotPages[0].type, SlotPageType.exerciseOverview);
        expect(setEntry.slotPages[1].type, SlotPageType.log);
        expect(setEntry.slotPages[2].type, SlotPageType.timer);
        expect(notifier.state.totalPages, 17);
      },
    );

    test('Correctly generates pages - no exercises and no timer', () {
      // Arrange
      notifier.state = notifier.state.copyWith(
        showExercisePages: false,
        showTimerPages: false,
      );

      // Act
      notifier.calculatePages();

      // Assert
      final pages = notifier.state.pages;
      final setEntry = pages.firstWhere((p) => p.type == PageType.set);
      expect(pages.length, 5, reason: '4 PageEntries (start, set 1, set 2, session, summary)');
      expect(
        setEntry.slotPages.where((p) => p.type == SlotPageType.log).length,
        3,
        reason: 'Three sets',
      );
      expect(
        setEntry.slotPages.where((p) => p.type == SlotPageType.timer).length,
        0,
        reason: 'No timer',
      );
      expect(
        setEntry.slotPages.where((p) => p.type == SlotPageType.exerciseOverview).length,
        0,
        reason: 'No overview',
      );
      expect(setEntry.slotPages[0].type, SlotPageType.log);
      expect(setEntry.slotPages[1].type, SlotPageType.log);
      expect(setEntry.slotPages[2].type, SlotPageType.log);
      expect(notifier.state.totalPages, 9);
    });

    test('Correctly generates pages - exercises and no timer', () {
      // Arrange
      notifier.state = notifier.state.copyWith(
        showExercisePages: true,
        showTimerPages: false,
      );

      // Act
      notifier.calculatePages();

      // Assert
      final pages = notifier.state.pages;
      final setEntry = pages.firstWhere((p) => p.type == PageType.set);
      expect(pages.length, 5, reason: '5 PageEntries (start, set 1, set 2, session, summary)');
      expect(
        setEntry.slotPages.where((p) => p.type == SlotPageType.log).length,
        3,
        reason: 'Three sets',
      );
      expect(
        setEntry.slotPages.where((p) => p.type == SlotPageType.timer).length,
        0,
        reason: 'No timer',
      );
      expect(
        setEntry.slotPages.where((p) => p.type == SlotPageType.exerciseOverview).length,
        1,
        reason: 'One exercise overview at the start',
      );
      expect(setEntry.slotPages.length, 4);
      expect(setEntry.slotPages[0].type, SlotPageType.exerciseOverview);
      expect(setEntry.slotPages[1].type, SlotPageType.log);
      expect(setEntry.slotPages[2].type, SlotPageType.log);
      expect(setEntry.slotPages[3].type, SlotPageType.log);
      expect(notifier.state.totalPages, 11);
    });
  });

  group('GymStateNotifier.setLogScopeWeeks', () {
    test('Sets the scope and persists it', () async {
      // Act
      notifier.setLogScopeWeeks(12);
      await pumpEventQueue();

      // Assert
      expect(notifier.state.logScopeWeeks, 12);
      expect(await PreferenceHelper.asyncPref.getInt(PREFS_LOG_SCOPE_WEEKS), 12);
    });

    test('Resets the scope to the current routine', () async {
      // Arrange
      notifier.setLogScopeWeeks(12);
      await pumpEventQueue();

      // Act
      notifier.setLogScopeWeeks(null);
      await pumpEventQueue();

      // Assert
      expect(notifier.state.logScopeWeeks, isNull);
      expect(await PreferenceHelper.asyncPref.getInt(PREFS_LOG_SCOPE_WEEKS), isNull);
    });
  });

  group('GymStateNotifier.setShowWorkoutDuration', () {
    test('Sets the flag and persists it', () async {
      // Act
      notifier.setShowWorkoutDuration(false);
      await pumpEventQueue();

      // Assert
      expect(notifier.state.showWorkoutDuration, false);
      expect(await PreferenceHelper.asyncPref.getBool(PREFS_SHOW_WORKOUT_DURATION), false);
    });
  });

  group('GymStateNotifier sticky set values', () {
    // Page structure of the test routine (exercise + timer pages enabled):
    //   start(0)
    //   slot 1 (exercise 1): overview(1), log(2), timer(3), log(4), timer(5), log(6), timer(7)
    //   slot 2 (exercise 6): overview(8), log(9), ...

    Log buildLoggedValues() {
      final slotPage = notifier.state.pages[1].slotPages[1];
      return Log.fromSetConfigData(slotPage.setConfigData!, routineId: 1, iteration: 1)
        ..repetitions = 7
        ..weight = 42.5
        ..rir = 1;
    }

    test('Sets the flag and persists it', () async {
      // Act
      notifier.setStickySetValues(true);
      await pumpEventQueue();

      // Assert
      expect(notifier.state.stickySetValues, true);
      expect(await PreferenceHelper.asyncPref.getBool(PREFS_STICKY_SET_VALUES), true);
    });

    test(
      'Pre-fills the next set of the exercise with the last logged values when enabled',
      () async {
        // Arrange
        notifier.setStickySetValues(true);
        await pumpEventQueue();
        notifier.recordLoggedValues(buildLoggedValues());

        // Act: navigate to the second set of the same exercise
        notifier.setCurrentPage(4);

        // Assert
        final gymLog = container.read(gymLogProvider)!;
        expect(gymLog.repetitions, 7);
        expect(gymLog.weight, 42.5);
        expect(gymLog.rir, 1);
        expect(gymLog.id, isNull, reason: 'A fresh log is seeded, not a copy of the saved one');
      },
    );

    test('Pre-fills with the planned values when disabled', () {
      // Arrange
      notifier.recordLoggedValues(buildLoggedValues());

      // Act
      notifier.setCurrentPage(4);

      // Assert: the values of the set configuration
      final gymLog = container.read(gymLogProvider)!;
      expect(gymLog.repetitions, 3);
      expect(gymLog.weight, 100);
    });

    test('Does not carry values over to a different exercise', () async {
      // Arrange
      notifier.setStickySetValues(true);
      await pumpEventQueue();
      notifier.recordLoggedValues(buildLoggedValues());

      // Act: navigate to the first set of the second exercise
      notifier.setCurrentPage(9);

      // Assert: the values of that exercise's set configuration
      final gymLog = container.read(gymLogProvider)!;
      expect(gymLog.repetitions, 12);
      expect(gymLog.weight, 10);
    });

    test('Clearing the state forgets the logged values', () {
      // Arrange
      notifier.recordLoggedValues(buildLoggedValues());
      expect(notifier.state.lastLoggedValues, isNotEmpty);

      // Act
      notifier.clear();

      // Assert
      expect(notifier.state.lastLoggedValues, isEmpty);
    });
  });

  group('GymStateNotifier.startWorkout', () {
    test('Resets the workout start time to now', () {
      // Arrange
      notifier.state = notifier.state.copyWith(workoutStart: DateTime(2024, 5, 1, 10, 0));

      // Act
      withClock(Clock.fixed(DateTime(2024, 5, 1, 17, 30, 21)), () {
        notifier.startWorkout();
      });

      // Assert
      expect(notifier.state.workoutStart, DateTime(2024, 5, 1, 17, 30, 21));
      expect(notifier.state.startTime, const TimeOfDay(hour: 17, minute: 30));
    });
  });

  group('GymStateNotifier.clear', () {
    test('Resets the workout start time', () {
      // Arrange
      notifier.state = notifier.state.copyWith(workoutStart: DateTime(2024, 5, 1, 10, 0));

      // Act
      withClock(Clock.fixed(DateTime(2024, 5, 2, 9, 15)), () {
        notifier.clear();
      });

      // Assert
      expect(notifier.state.workoutStart, DateTime(2024, 5, 2, 9, 15));
    });
  });

  group('GymStateNotifier.initData', () {
    test('Resets the workout start time when the state is reset', () {
      // Arrange
      notifier.state = notifier.state.copyWith(
        isInitialized: false,
        workoutStart: DateTime(2024, 5, 1, 10, 0),
      );

      // Act
      withClock(Clock.fixed(DateTime(2024, 5, 2, 18, 0)), () {
        notifier.initData(getTestRoutine(), 1, 1);
      });

      // Assert
      expect(notifier.state.workoutStart, DateTime(2024, 5, 2, 18, 0));
    });

    test('Keeps the workout start time when the state is not reset', () {
      // Arrange
      notifier.state = notifier.state.copyWith(
        isInitialized: true,
        workoutStart: DateTime(2024, 5, 1, 10, 0),
      );

      // Act
      notifier.initData(getTestRoutine(), 1, 1);

      // Assert
      expect(notifier.state.workoutStart, DateTime(2024, 5, 1, 10, 0));
    });

    test('Returns the stored page so a resumed workout reopens where it left off', () {
      // The return value is what gym_mode jumps the PageView to
      notifier.state = notifier.state.copyWith(
        isInitialized: true,
        dayId: 1,
        currentPage: 4,
      );

      expect(notifier.initData(getTestRoutine(), 1, 1), 4);
      expect(notifier.state.currentPage, 4);
    });

    test('Starting a different day resets to the first page', () {
      notifier.state = notifier.state.copyWith(
        isInitialized: true,
        dayId: 1,
        currentPage: 4,
      );

      expect(notifier.initData(getTestRoutine(), 2, 1), 0);
      expect(notifier.state.dayId, 2);
    });

    test('An expired validUntil resets even on the same day', () {
      // The session is only resumable for a while; after that the same day
      // starts over instead of dropping the user in the middle of it
      notifier.state = notifier.state.copyWith(
        isInitialized: true,
        dayId: 1,
        currentPage: 4,
        validUntil: DateTime(2024, 5, 1, 10, 0),
      );

      final page = withClock(
        Clock.fixed(DateTime(2024, 5, 2, 18, 0)),
        () => notifier.initData(getTestRoutine(), 1, 1),
      );

      expect(page, 0);
    });
  });

  group('GymModeState.copyWith', () {
    test('Keeps the log scope when it is not passed', () {
      final state = notifier.state.copyWith(logScopeWeeks: 8);

      expect(state.copyWith(showDistinctLogs: false).logScopeWeeks, 8);
    });

    test('Clears the log scope on clearLogScopeWeeks', () {
      final state = notifier.state.copyWith(logScopeWeeks: 8);

      expect(state.copyWith(clearLogScopeWeeks: true).logScopeWeeks, isNull);
    });
  });
}
