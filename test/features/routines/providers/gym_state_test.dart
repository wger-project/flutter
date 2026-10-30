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

import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/account/models/user_profile.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';
import 'package:wger/features/exercises/models/exercise.dart';
import 'package:wger/features/routines/models/added_exercise.dart';
import 'package:wger/features/routines/models/day.dart';
import 'package:wger/features/routines/models/day_data.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/models/page_progress.dart';
import 'package:wger/features/routines/models/routine.dart';
import 'package:wger/features/routines/models/set_config_data.dart';
import 'package:wger/features/routines/models/slot_data.dart';
import 'package:wger/features/routines/providers/gym_log_notifier.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/providers/routines_notifier.dart';
import 'package:wger/features/routines/providers/workout_logs_repository.dart';

import '../../../../test_data/exercises.dart';
import '../../../../test_data/routines.dart';
import '../helpers/routine_form_test_overrides.dart';
import 'gym_state_test.mocks.dart';

@GenerateMocks([WorkoutLogRepository])
void main() {
  late GymStateNotifier notifier;
  late ProviderContainer container;
  late MockWorkoutLogRepository mockLogRepo;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

    mockLogRepo = MockWorkoutLogRepository();
    when(mockLogRepo.addLocalDrift(any, dayId: anyNamed('dayId'))).thenAnswer((_) async {});
    container = ProviderContainer.test(
      overrides: [workoutLogRepositoryProvider.overrideWithValue(mockLogRepo)],
    );
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
        notifier.state.pages.every(
          (p) => p.slotPages.every((s) => !notifier.state.progressOf(s.key).done),
        ),
        true,
        reason: 'All slot pages are initially not done',
      );

      // Act
      notifier.markSlotPageAsDone(slotPage.key, isDone: true);

      // Assert
      for (final page in notifier.state.pages.where((p) => p.type == PageType.set)) {
        for (final slot in page.slotPages.where((s) => s.type == SlotPageType.log)) {
          if (slot.key == slotPage.key) {
            expect(notifier.state.progressOf(slot.key).done, true);
          } else {
            expect(notifier.state.progressOf(slot.key).done, false);
          }
        }
      }
    });

    test('Stores the logged entry in the page progress', () {
      // Arrange
      final slotPage = notifier.state.pages[1].slotPages[1];
      expect(slotPage.type, SlotPageType.log);
      final log = Log.fromSetConfigData(slotPage.setConfigData!, routineId: 1, iteration: 1)
        ..id = 'log-1';

      // Act
      notifier.markSlotPageAsDone(slotPage.key, isDone: true, log: log);

      // Assert
      final loggedEntry = notifier.state.progressOf(slotPage.key).loggedEntry!;
      expect(loggedEntry.id, 'log-1');
      expect(loggedEntry, isNot(same(log)));

      // Undoing the flag without a log, e.g. after a failed write, keeps the entry
      notifier.markSlotPageAsDone(slotPage.key, isDone: false);
      expect(notifier.state.progressOf(slotPage.key).done, isFalse);
      expect(notifier.state.progressOf(slotPage.key).loggedEntry!.id, 'log-1');
    });
  });

  group('GymStateNotifier.setCurrentPage', () {
    test('Seeds the gym log from the saved entry when re-visiting a logged page', () {
      // Arrange
      final slotPage = notifier.state.pages[1].slotPages[1];
      expect(slotPage.type, SlotPageType.log);
      final log = Log.fromSetConfigData(slotPage.setConfigData!, routineId: 1, iteration: 1)
        ..id = 'log-1'
        ..sessionId = 'session-1';
      notifier.markSlotPageAsDone(slotPage.key, isDone: true, log: log);

      // Act
      notifier.setCurrentPage(slotPage.pageIndex);

      // Assert: the id and session are kept so saving updates the row
      // instead of inserting a duplicate
      final gymLog = container.read(gymLogProvider);
      expect(gymLog!.id, 'log-1');
      expect(gymLog.sessionId, 'session-1');
    });

    test('Seeds a fresh template for a page without a saved entry', () {
      // Act
      notifier.setCurrentPage(2);

      // Assert
      expect(container.read(gymLogProvider)!.id, isNull);
    });
  });

  group('GymStateNotifier.startNewEntry', () {
    test('Seeds a fresh entry on a page that was already logged', () {
      // Arrange
      final slotPage = notifier.state.pages[1].slotPages[1];
      final log = Log.fromSetConfigData(slotPage.setConfigData!, routineId: 1, iteration: 1)
        ..id = 'log-1'
        ..repetitions = 99;
      notifier.markSlotPageAsDone(slotPage.key, isDone: true, log: log);
      notifier.setCurrentPage(slotPage.pageIndex);
      expect(container.read(gymLogProvider)!.id, 'log-1');

      // Act
      notifier.startNewEntry();

      // Assert: the planned values, without an id so saving inserts a row
      final gymLog = container.read(gymLogProvider)!;
      expect(gymLog.id, isNull);
      expect(gymLog.repetitions, slotPage.setConfigData!.repetitions);
      expect(notifier.state.progressOf(slotPage.key).loggedEntry!.id, 'log-1');
    });
  });

  group('GymStateNotifier.startTimerIfNeeded', () {
    test('Sets the start time only once', () {
      // Arrange
      final timerPage = notifier.state.pages[1].slotPages[2];
      expect(timerPage.type, SlotPageType.timer);

      // Act
      withClock(Clock.fixed(DateTime(2024, 5, 2, 12)), () {
        notifier.startTimerIfNeeded(timerPage.key);
      });

      // Assert
      expect(
        notifier.state.progressOf(timerPage.key).timerStartedAt,
        DateTime(2024, 5, 2, 12),
      );

      // Act: starting again does not restart the timer
      withClock(Clock.fixed(DateTime(2024, 5, 2, 12, 5)), () {
        notifier.startTimerIfNeeded(timerPage.key);
      });

      // Assert
      expect(
        notifier.state.progressOf(timerPage.key).timerStartedAt,
        DateTime(2024, 5, 2, 12),
      );
    });

    test('Saving a new set restarts the following timer, correcting it does not', () {
      // Arrange: the timer was started by scrolling past it
      final logPage = notifier.state.pages[1].slotPages[1];
      final timerPage = notifier.state.pages[1].slotPages[2];
      expect(logPage.type, SlotPageType.log);
      expect(timerPage.type, SlotPageType.timer);
      withClock(Clock.fixed(DateTime(2024, 5, 2, 12)), () {
        notifier.startTimerIfNeeded(timerPage.key);
      });
      // The id is minted by the insert
      final log = Log.fromSetConfigData(logPage.setConfigData!, routineId: 1, iteration: 1)
        ..id = 'log-1';

      // Act: the set is saved
      withClock(Clock.fixed(DateTime(2024, 5, 2, 12, 10)), () {
        notifier.markSlotPageAsDone(logPage.key, isDone: true, log: log);
      });

      // Assert
      expect(
        notifier.state.progressOf(timerPage.key).timerStartedAt,
        DateTime(2024, 5, 2, 12, 10),
      );

      // Act: correcting the saved set keeps the running timer
      withClock(Clock.fixed(DateTime(2024, 5, 2, 12, 11)), () {
        notifier.markSlotPageAsDone(logPage.key, isDone: true, log: log);
      });

      // Assert
      expect(
        notifier.state.progressOf(timerPage.key).timerStartedAt,
        DateTime(2024, 5, 2, 12, 10),
      );

      // Act: another set is logged on the same page ("add set")
      final extraLog = log.copyWith(id: 'log-2');
      withClock(Clock.fixed(DateTime(2024, 5, 2, 12, 15)), () {
        notifier.markSlotPageAsDone(logPage.key, isDone: true, log: extraLog);
      });

      // Assert
      expect(
        notifier.state.progressOf(timerPage.key).timerStartedAt,
        DateTime(2024, 5, 2, 12, 15),
      );
    });
  });

  group('GymStateNotifier.replaceExercises', () {
    test('Correctly swaps an exercise', () {
      // Arrange
      final page = notifier.state.pages[1];
      final slotPage = page.slotPages[1];
      final slotPageKeys = page.slotPages.map((s) => s.key).toList();
      expect(slotPage.type, SlotPageType.log);
      expect(
        notifier.state.pages.every((p) => p.exercises.every((e) => e.id != testSquats.id)),
        isTrue,
        reason: 'the new exercise is not part of the routine yet',
      );

      // Act
      notifier.replaceExercises(originalExerciseId: 1, newExercise: testSquats);

      // Assert: every slot page of that page carries the new exercise, and the
      // routine itself was rebuilt too (the log draft reads from it)
      final updated = notifier.state.pages[1];
      expect(
        updated.slotPages.map((s) => s.key),
        slotPageKeys,
        reason: 'the layout is the same, including the overview of the exercise',
      );
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
    /// A notifier for an imperial user, with the pages calculated
    Future<GymStateNotifier> imperialGymNotifier() async {
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
      return imperialNotifier;
    }

    test('Stamps the profile default weight unit on the ad-hoc set configs', () async {
      // Ad-hoc exercises bypass routine hydration, so the notifier itself
      // resolves the profile default: lb (id 2) for an imperial user.
      final imperialNotifier = await imperialGymNotifier();
      final setPage = imperialNotifier.state.pages.firstWhere((p) => p.type == PageType.set);

      imperialNotifier.addExerciseAfterPage(setPage.key, newExercise: testSquats);

      // The pages are recalculated, so look the page up by key
      final pages = imperialNotifier.state.pages;
      final newPage = pages[pages.indexWhere((p) => p.key == setPage.key) + 1];
      expect(newPage.slotPages, isNotEmpty);
      for (final slotPage in newPage.slotPages) {
        // testWeightUnit2 has id 2 == WEIGHT_UNIT_LB.
        expect(slotPage.setConfigData!.weightUnit, testWeightUnit2);
        expect(slotPage.setConfigData!.weightUnitId, isNull);
      }

      // The ad-hoc sets borrow the slot entry of the page they follow, so
      // their keys must not be derived from it
      expect(newPage.key, 'added:1');
      expect(newPage.slotPages.map((p) => p.key), [
        'added:1:log:1',
        'added:1:log:2',
        'added:1:log:3',
        'added:1:log:4',
      ]);
    });

    test('Keeps the added exercises when the pages are recalculated', () async {
      final gymNotifier = await imperialGymNotifier();
      final slotKey = gymNotifier.state.pages[1].key;
      gymNotifier.addExerciseAfterPage(slotKey, newExercise: testSquats);
      gymNotifier.addExerciseAfterPage('added:1', newExercise: testCurls);
      gymNotifier.markSlotPageAsDone('added:1:log:1', isDone: true);

      gymNotifier.state = gymNotifier.state.copyWith(showExercisePages: false);
      gymNotifier.calculatePages();

      final pages = gymNotifier.state.pages;
      expect(pages.map((p) => p.key).toList().sublist(1, 4), [slotKey, 'added:1', 'added:2']);
      expect(pages[2].exercises.single.id, testSquats.id);
      expect(pages[3].exercises.single.id, testCurls.id);
      expect(
        pages[2].slotPages.map((p) => p.setIndex),
        [0, 1, 2, 3],
        reason: 'the sets of the exercise are numbered on their own',
      );
      expect(pages[2].slotPages.first.setConfigData!.weightUnit, testWeightUnit2);
      expect(gymNotifier.state.progressOf('added:1:log:1').done, isTrue);
      expect(
        pages.expand((p) => p.slotPages).map((p) => p.pageIndex),
        List.generate(pages.expand((p) => p.slotPages).length, (i) => i + 1),
        reason: 'the page indices stay consecutive',
      );
    });

    test('Keeps a replaced added exercise when the pages are recalculated', () async {
      final gymNotifier = await imperialGymNotifier();
      gymNotifier.addExerciseAfterPage(gymNotifier.state.pages[1].key, newExercise: testSquats);

      gymNotifier.replaceExercises(
        originalExerciseId: testSquats.id,
        newExercise: testCurls,
      );
      gymNotifier.calculatePages();

      final added = gymNotifier.state.pages.firstWhere((p) => p.key == 'added:1');
      expect(added.exercises.single.id, testCurls.id);
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

    test('numbers the sets of each exercise on its own', () {
      final exercises = getTestExercises();
      notifier.state = notifier.state.copyWith(
        showExercisePages: false,
        showTimerPages: true,
        dayId: 1,
        iteration: 1,
        routine: supersetRoutine(
          [1, 2],
          setConfigs: [
            configFor(1, exercises[0]),
            configFor(2, exercises[1]),
            configFor(1, exercises[0]),
            configFor(2, exercises[1]),
          ],
        ),
      );

      notifier.calculatePages();

      expect(notifier.state.pages[1].slotPages.map((p) => p.key), [
        'log:1:1',
        'timer:1:1',
        'log:2:1',
        'timer:2:1',
        'log:1:2',
        'timer:1:2',
        'log:2:2',
        'timer:2:2',
      ]);
    });
  });

  group('GymStateNotifier.calculatePages', () {
    test('Keeps the progress when the layout changes mid-workout', () {
      final logPage = notifier.state.pages[1].slotPages[1];
      final timerPage = notifier.state.pages[1].slotPages[2];
      final log = Log(id: 'log-1', exerciseId: 1, date: DateTime(2026, 7, 26));
      withClock(Clock.fixed(DateTime(2026, 7, 26, 18, 30)), () {
        notifier.markSlotPageAsDone(logPage.key, isDone: true, log: log);
      });

      notifier.state = notifier.state.copyWith(showExercisePages: false);
      notifier.calculatePages();

      expect(notifier.state.pages[1].slotPages.first.key, logPage.key);
      final progress = notifier.state.progressOf(logPage.key);
      expect(progress.done, isTrue);
      expect(progress.loggedEntry!.id, 'log-1');
      expect(
        notifier.state.progressOf(timerPage.key).timerStartedAt,
        DateTime(2026, 7, 26, 18, 30),
      );
    });

    test('Keeps the keys of the set pages when the layout changes', () {
      List<String> logKeys() => [
        for (final slotPage in notifier.state.pages.expand((p) => p.slotPages))
          if (slotPage.type == SlotPageType.log) slotPage.key,
      ];

      notifier.state = notifier.state.copyWith(showExercisePages: true, showTimerPages: true);
      notifier.calculatePages();
      final allKeys = [
        for (final page in notifier.state.pages) ...[page.key, ...page.slotPages.map((p) => p.key)],
      ];
      final keysWithAllPages = logKeys();

      notifier.state = notifier.state.copyWith(showExercisePages: false, showTimerPages: false);
      notifier.calculatePages();

      expect(logKeys(), keysWithAllPages);
      expect(allKeys.toSet(), hasLength(allKeys.length), reason: 'every page has its own key');
    });

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

  group('GymStateNotifier notification settings', () {
    test('Both are on without stored preferences', () async {
      await notifier.loadPrefs();

      expect(notifier.state.alertOnCountdownEnd, isTrue);
      expect(notifier.state.showWorkoutNotification, isTrue);
    });

    test('Stored values are loaded', () async {
      await PreferenceHelper.asyncPref.setBool(PREFS_ALERT_COUNTDOWN, false);
      await PreferenceHelper.asyncPref.setBool(PREFS_WORKOUT_NOTIFICATION, false);

      await notifier.loadPrefs();

      expect(notifier.state.alertOnCountdownEnd, isFalse);
      expect(notifier.state.showWorkoutNotification, isFalse);
    });

    test('The setters change only their own flag and persist it', () async {
      notifier.setAlertOnCountdownEnd(false);
      await pumpEventQueue();
      expect(notifier.state.alertOnCountdownEnd, isFalse);
      expect(notifier.state.showWorkoutNotification, isTrue);
      expect(await PreferenceHelper.asyncPref.getBool(PREFS_ALERT_COUNTDOWN), false);

      notifier.setShowWorkoutNotification(false);
      await pumpEventQueue();
      expect(notifier.state.alertOnCountdownEnd, isFalse);
      expect(notifier.state.showWorkoutNotification, isFalse);
      expect(await PreferenceHelper.asyncPref.getBool(PREFS_WORKOUT_NOTIFICATION), false);
    });
  });

  group('GymStateNotifier.setCurrentPage, rest', () {
    final start = DateTime.utc(2024, 5, 1, 17, 30);
    final later = DateTime.utc(2024, 5, 1, 17, 45);

    Iterable<SlotPageEntry> slotPages() => notifier.state.pages.expand((p) => p.slotPages);

    // The fixture's first slot has a rest time of 120 s, the second has none
    int timerWithRestTime() => slotPages()
        .firstWhere((p) => p.type == SlotPageType.timer && p.setConfigData!.restTime != null)
        .pageIndex;
    int timerWithoutRestTime() => slotPages()
        .firstWhere((p) => p.type == SlotPageType.timer && p.setConfigData!.restTime == null)
        .pageIndex;

    void goTo(int page, {DateTime? at}) =>
        withClock(Clock.fixed(at ?? start), () => notifier.setCurrentPage(page));

    test('A timer page counts down from the rest time of its set', () {
      notifier.state = notifier.state.copyWith(useCountdownBetweenSets: false);

      goTo(timerWithRestTime());

      expect(notifier.state.restStartedAt, start);
      expect(notifier.state.restEndsAt, start.add(const Duration(seconds: 120)));
    });

    test('Without a rest time the countdown uses the user setting', () {
      notifier.state = notifier.state.copyWith(
        useCountdownBetweenSets: true,
        countdownDuration: 90,
      );

      goTo(timerWithoutRestTime());

      expect(notifier.state.restEndsAt, start.add(const Duration(seconds: 90)));
    });

    test('Without a rest time and the countdown setting off, the rest counts up', () {
      notifier.state = notifier.state.copyWith(useCountdownBetweenSets: false);

      goTo(timerWithoutRestTime());

      expect(notifier.state.restStartedAt, start);
      expect(notifier.state.restEndsAt, isNull);
    });

    test('Other pages have no rest', () {
      final timer = timerWithRestTime();
      goTo(timer);

      goTo(timer + 1);

      expect(notifier.state.getSlotEntryPageByIndex()!.type, SlotPageType.log);
      expect(notifier.state.restStartedAt, isNull);
      expect(notifier.state.restEndsAt, isNull);
    });

    test('Setting the same timer page again keeps the running rest', () {
      // gym_mode reports the restored page again when it is reopened
      final timer = timerWithRestTime();
      goTo(timer);

      goTo(timer, at: later);

      expect(notifier.state.restStartedAt, start);
    });

    test('Coming back to a timer page continues its rest', () {
      // E.g. after going back to correct the set during the rest
      final timer = timerWithRestTime();
      goTo(timer);
      goTo(timer + 1);

      goTo(timer, at: later);

      expect(notifier.state.restStartedAt, start);
      expect(notifier.state.restEndsAt, start.add(const Duration(seconds: 120)));
    });

    test('clear() ends the rest', () {
      goTo(timerWithRestTime());

      notifier.clear();

      expect(notifier.state.restStartedAt, isNull);
      expect(notifier.state.restEndsAt, isNull);
    });

    test('A reset in initData ends the rest', () {
      goTo(timerWithRestTime());

      notifier.initData(getTestRoutine(), 2, 1);

      expect(notifier.state.restStartedAt, isNull);
      expect(notifier.state.restEndsAt, isNull);
    });
  });

  group('GymStateNotifier logging and skipping', () {
    final start = DateTime.utc(2024, 5, 1, 17, 30);

    List<SlotPageEntry> slotPages() => notifier.state.pages.expand((p) => p.slotPages).toList();

    // First slot of the fixture: overview, then log/timer pairs with 3x100kg
    // and a rest time of 120 s
    SlotPageEntry firstLog() => slotPages().firstWhere((p) => p.type == SlotPageType.log);
    SlotPageEntry secondLog() => slotPages().where((p) => p.type == SlotPageType.log).elementAt(1);

    Log capturedLog() =>
        verify(mockLogRepo.addLocalDrift(captureAny, dayId: anyNamed('dayId'))).captured.single
            as Log;

    test('logCurrentSet saves the draft, marks the page done and starts the rest', () async {
      final log = firstLog();
      notifier.setCurrentPage(log.pageIndex);
      container.read(gymLogProvider.notifier).setRepetitions(12);

      await withClock(Clock.fixed(start), notifier.logCurrentSet);

      final captured = verify(
        mockLogRepo.addLocalDrift(captureAny, dayId: captureAnyNamed('dayId')),
      ).captured;
      expect((captured[0] as Log).repetitions, 12);
      expect(captured[1], 1);
      expect(notifier.state.progressOf(log.key).done, isTrue);
      expect(notifier.state.currentPage, log.pageIndex + 1);
      expect(notifier.state.restEndsAt, start.add(const Duration(seconds: 120)));
    });

    test('logCurrentSet keeps the page open when the write fails', () async {
      final log = firstLog();
      notifier.setCurrentPage(log.pageIndex);
      when(mockLogRepo.addLocalDrift(any, dayId: anyNamed('dayId'))).thenThrow(Exception('db'));

      await expectLater(notifier.logCurrentSet(), throwsException);

      expect(notifier.state.progressOf(log.key).done, isFalse);
      expect(notifier.state.currentPage, log.pageIndex);
    });

    test('logCurrentSet updates a corrected set and keeps its rest running', () async {
      when(mockLogRepo.addLocalDrift(any, dayId: anyNamed('dayId'))).thenAnswer((invocation) async {
        (invocation.positionalArguments.first as Log).id = 'log-1';
      });
      when(mockLogRepo.updateLocalDrift(any)).thenAnswer((_) async {});
      final log = firstLog();
      notifier.setCurrentPage(log.pageIndex);
      await withClock(Clock.fixed(start), notifier.logCurrentSet);

      // Back to the set during the rest, the form holds the saved entry
      notifier.setCurrentPage(log.pageIndex);
      container.read(gymLogProvider.notifier).setRepetitions(5);
      await withClock(Clock.fixed(start.add(const Duration(seconds: 40))), notifier.logCurrentSet);

      final updated = verify(mockLogRepo.updateLocalDrift(captureAny)).captured.single as Log;
      expect(updated.id, 'log-1');
      expect(updated.repetitions, 5);
      verify(mockLogRepo.addLocalDrift(any, dayId: anyNamed('dayId'))).called(1);
      expect(notifier.state.currentPage, log.pageIndex + 1);
      expect(notifier.state.restStartedAt, start);
    });

    test('logCurrentSet does not move on when the user left the page meanwhile', () async {
      final write = Completer<void>();
      when(
        mockLogRepo.addLocalDrift(any, dayId: anyNamed('dayId')),
      ).thenAnswer((_) => write.future);
      notifier.setCurrentPage(firstLog().pageIndex);

      final saving = notifier.logCurrentSet();
      notifier.setCurrentPage(0);
      write.complete();
      await saving;

      expect(notifier.state.currentPage, 0);
    });

    test('logPlannedSet from the rest before the set logs the planned values', () async {
      final log = secondLog();
      notifier.setCurrentPage(log.pageIndex - 1);

      final logged = await withClock(
        Clock.fixed(start),
        () => notifier.logPlannedSet(log.key),
      );

      expect(logged, isTrue);
      final saved = capturedLog();
      expect(saved.repetitions, log.setConfigData!.repetitions);
      expect(saved.weight, log.setConfigData!.weight);
      expect(notifier.state.progressOf(log.key).done, isTrue);
      expect(notifier.state.currentPage, log.pageIndex + 1);
      expect(notifier.state.restStartedAt, start);
    });

    test('logPlannedSet on the set page itself logs the edited draft', () async {
      final log = secondLog();
      notifier.setCurrentPage(log.pageIndex);
      container.read(gymLogProvider.notifier).setRepetitions(7);

      expect(await notifier.logPlannedSet(log.key), isTrue);

      expect(capturedLog().repetitions, 7);
    });

    test('extendRest adds to a running countdown, after its end from now', () async {
      final timer = secondLog().pageIndex - 1;
      withClock(Clock.fixed(start), () => notifier.setCurrentPage(timer));
      final endsAt = notifier.state.restEndsAt!;

      withClock(Clock.fixed(start), () => notifier.extendRest(const Duration(seconds: 30)));
      expect(notifier.state.restEndsAt, endsAt.add(const Duration(seconds: 30)));

      final later = endsAt.add(const Duration(minutes: 5));
      withClock(Clock.fixed(later), () => notifier.extendRest(const Duration(seconds: 30)));
      expect(notifier.state.restEndsAt, later.add(const Duration(seconds: 30)));
    });

    test('extendRest does nothing outside a countdown', () {
      notifier.setCurrentPage(secondLog().pageIndex);

      notifier.extendRest(const Duration(seconds: 30));

      expect(notifier.state.restEndsAt, isNull);
    });

    test('logPlannedSet with the values of an earlier log logs those instead', () async {
      final log = secondLog();
      notifier.setCurrentPage(log.pageIndex - 1);
      final earlier = Log(exerciseId: log.setConfigData!.exerciseId, repetitions: 8, weight: 62.5);
      earlier.weightUnit = testWeightUnit2;

      expect(await notifier.logPlannedSet(log.key, valuesFrom: earlier), isTrue);

      final saved = capturedLog();
      expect(saved.repetitions, 8);
      expect(saved.weight, 62.5);
      expect(saved.weightUnitId, testWeightUnit2.id);
      // The planned RiR is 1.5, the earlier log had none
      expect(saved.rir, isNull);
      expect(saved.slotEntryId, log.setConfigData!.slotEntryId);
      expect(notifier.state.currentPage, log.pageIndex + 1);
    });

    test('logPlannedSet with an earlier log also replaces an edited draft', () async {
      final log = secondLog();
      notifier.setCurrentPage(log.pageIndex);
      container.read(gymLogProvider.notifier).setRepetitions(7);
      final earlier = Log(exerciseId: log.setConfigData!.exerciseId, repetitions: 9, weight: 60);

      expect(await notifier.logPlannedSet(log.key, valuesFrom: earlier), isTrue);

      expect(capturedLog().repetitions, 9);
    });

    test('logPlannedSet on the set page needs the draft', () async {
      // A restored state points at the page before onPageChanged seeds the draft
      final log = secondLog();
      notifier.state = notifier.state.copyWith(currentPage: log.pageIndex);

      expect(await notifier.logPlannedSet(log.key), isFalse);
      verifyNever(mockLogRepo.addLocalDrift(any, dayId: anyNamed('dayId')));
    });

    test('logPlannedSet ignores a second action while the first one is saving', () async {
      final write = Completer<void>();
      when(
        mockLogRepo.addLocalDrift(any, dayId: anyNamed('dayId')),
      ).thenAnswer((_) => write.future);
      final log = secondLog();
      notifier.setCurrentPage(log.pageIndex - 1);

      final first = notifier.logPlannedSet(log.key);
      final second = await notifier.logPlannedSet(log.key);
      write.complete();

      expect(second, isFalse);
      expect(await first, isTrue);
      verify(mockLogRepo.addLocalDrift(any, dayId: anyNamed('dayId'))).called(1);
    });

    test('logPlannedSet ignores stale actions', () async {
      final log = secondLog();
      notifier.setCurrentPage(log.pageIndex - 1);
      final timerKey = notifier.state.getSlotEntryPageByIndex()!.key;

      expect(await notifier.logPlannedSet('unknown'), isFalse, reason: 'unknown page');
      expect(await notifier.logPlannedSet(timerKey), isFalse, reason: 'not a log page');
      expect(await notifier.logPlannedSet(firstLog().key), isFalse, reason: 'not the next set');

      notifier.markSlotPageAsDone(log.key, isDone: true);
      expect(await notifier.logPlannedSet(log.key), isFalse, reason: 'already logged');

      verifyNever(mockLogRepo.addLocalDrift(any, dayId: anyNamed('dayId')));
      expect(notifier.state.currentPage, log.pageIndex - 1);
    });

    test('logPlannedSet only starts from a rest, not from the exercise overview', () async {
      final log = firstLog();
      notifier.setCurrentPage(log.pageIndex - 1);
      expect(notifier.state.getSlotEntryPageByIndex()!.type, SlotPageType.exerciseOverview);

      expect(await notifier.logPlannedSet(log.key), isFalse);
      verifyNever(mockLogRepo.addLocalDrift(any, dayId: anyNamed('dayId')));
    });

    test('logPlannedSet leaves a set without planned values to the app', () async {
      final config = SetConfigData(
        exerciseId: 1,
        exercise: getTestExercises().first,
        slotEntryId: 1,
        nrOfSets: 1,
        repetitions: null,
        weight: null,
        restTime: 60,
        textRepr: '',
      );
      final routine = getTestRoutine()
        ..dayDataGym = [
          DayData(
            iteration: 1,
            date: DateTime(2024, 11, 1),
            day: Day(id: 1, routineId: 1, name: 'Open sets'),
            slots: [
              SlotData(isSuperset: false, exerciseIds: [1], setConfigs: [config, config]),
            ],
          ),
        ];
      notifier.state = notifier.state.copyWith(routine: routine);
      notifier.calculatePages();
      final log = secondLog();
      notifier.setCurrentPage(log.pageIndex - 1);

      expect(await notifier.logPlannedSet(log.key), isFalse);

      verifyNever(mockLogRepo.addLocalDrift(any, dayId: anyNamed('dayId')));
      expect(notifier.state.currentPage, log.pageIndex - 1, reason: 'stays on the rest');
    });

    test('skipRest moves from the timer page to the next set', () {
      final log = secondLog();
      notifier.setCurrentPage(log.pageIndex - 1);

      notifier.skipRest();

      expect(notifier.state.currentPage, log.pageIndex);
      expect(notifier.state.restStartedAt, isNull);
    });

    test('skipRest does nothing outside a rest', () {
      final log = firstLog();
      notifier.setCurrentPage(log.pageIndex);

      notifier.skipRest();

      expect(notifier.state.currentPage, log.pageIndex);
    });
  });

  group('GymStateNotifier sticky set values', () {
    // Page structure of the test routine (exercise + timer pages enabled):
    //   start(0)
    //   slot 1 (exercise 1): overview(1), log(2), timer(3), log(4), timer(5), log(6), timer(7)
    //   slot 2 (exercise 6): overview(8), log(9), ...

    late MockWorkoutLogRepository logRepo;

    setUp(() {
      logRepo = MockWorkoutLogRepository();
      when(logRepo.getLatestLogByExercise(any)).thenAnswer((_) async => null);

      final initialState = notifier.state;
      container = ProviderContainer.test(
        overrides: [workoutLogRepositoryProvider.overrideWithValue(logRepo)],
      );
      notifier = container.read(gymStateProvider.notifier)..state = initialState;
    });

    Log buildLoggedValues() {
      final slotPage = notifier.state.pages[1].slotPages[1];
      return Log.fromSetConfigData(slotPage.setConfigData!, routineId: 1, iteration: 1)
        ..id = 'log-1'
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

    test('Pre-fills the set with the last logged values of the exercise when enabled', () async {
      // Arrange
      notifier.setStickySetValues(true);
      await pumpEventQueue();
      when(logRepo.getLatestLogByExercise(1)).thenAnswer((_) async => buildLoggedValues());

      // Act
      notifier.setCurrentPage(4);
      await pumpEventQueue();

      // Assert
      final gymLog = container.read(gymLogProvider)!;
      expect(gymLog.repetitions, 7);
      expect(gymLog.weight, 42.5);
      expect(gymLog.rir, 1);
      expect(gymLog.id, isNull, reason: 'A fresh log is seeded, not a copy of the saved one');
    });

    test('Pre-fills with the planned values when disabled', () async {
      // Arrange
      when(logRepo.getLatestLogByExercise(1)).thenAnswer((_) async => buildLoggedValues());

      // Act
      notifier.setCurrentPage(4);
      await pumpEventQueue();

      // Assert: the values of the set configuration
      final gymLog = container.read(gymLogProvider)!;
      expect(gymLog.repetitions, 3);
      expect(gymLog.weight, 100);
      verifyNever(logRepo.getLatestLogByExercise(any));
    });

    test('Pre-fills with the planned values when the exercise was never logged', () async {
      // Arrange
      notifier.setStickySetValues(true);
      await pumpEventQueue();

      // Act: the first set of the second exercise
      notifier.setCurrentPage(9);
      await pumpEventQueue();

      // Assert: the values of that exercise's set configuration
      verify(logRepo.getLatestLogByExercise(6));
      final gymLog = container.read(gymLogProvider)!;
      expect(gymLog.repetitions, 12);
      expect(gymLog.weight, 10);
    });

    test('Does not overwrite values entered while the lookup was running', () async {
      // Arrange
      notifier.setStickySetValues(true);
      await pumpEventQueue();
      final lookup = Completer<Log?>();
      when(logRepo.getLatestLogByExercise(1)).thenAnswer((_) => lookup.future);

      // Act
      notifier.setCurrentPage(4);
      container.read(gymLogProvider.notifier).setWeight(55);
      lookup.complete(buildLoggedValues());
      await pumpEventQueue();

      // Assert
      final gymLog = container.read(gymLogProvider)!;
      expect(gymLog.weight, 55);
      expect(gymLog.repetitions, 3);
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
    test('Resets the workout start time and the progress', () {
      // Arrange
      notifier.state = notifier.state.copyWith(
        workoutStart: DateTime(2024, 5, 1, 10, 0),
        progress: {'log:1:1': const PageProgress(done: true)},
        addedExercises: [
          AddedExercise(afterPageKey: 'slot:1:1', exercise: testSquats, slotEntryId: 1),
        ],
      );

      // Act
      withClock(Clock.fixed(DateTime(2024, 5, 2, 9, 15)), () {
        notifier.clear();
      });

      // Assert
      expect(notifier.state.workoutStart, DateTime(2024, 5, 2, 9, 15));
      expect(notifier.state.progress, isEmpty);
      expect(notifier.state.addedExercises, isEmpty);
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
        progress: {'log:1:1': const PageProgress(done: true)},
        addedExercises: [
          AddedExercise(afterPageKey: 'slot:1:1', exercise: testSquats, slotEntryId: 1),
        ],
      );

      expect(notifier.initData(getTestRoutine(), 2, 1), 0);
      expect(notifier.state.dayId, 2);
      expect(notifier.state.progress, isEmpty, reason: 'the new workout starts without progress');
      expect(notifier.state.addedExercises, isEmpty);
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

      // The new workout gets its own window, so it can be resumed in turn
      notifier.state = notifier.state.copyWith(currentPage: 3);
      final resumedPage = withClock(
        Clock.fixed(DateTime(2024, 5, 2, 19, 0)),
        () => notifier.initData(getTestRoutine(), 1, 1),
      );

      expect(resumedPage, 3);
    });
  });

  group('GymStateNotifier workout progress', () {
    /// Simulates the app being killed: a new container means a new (empty)
    /// notifier, while the stored preferences and [logs] survive, as on a real
    /// restart.
    GymStateNotifier restartedNotifier({List<Log> logs = const [], Object? lookupError}) {
      final logRepo = MockWorkoutLogRepository();
      when(logRepo.getLogsByIds(any)).thenAnswer((invocation) async {
        if (lookupError != null) {
          throw lookupError;
        }
        return [
          for (final log in logs)
            if ((invocation.positionalArguments.first as List<String>).contains(log.id)) log,
        ];
      });
      return ProviderContainer.test(
        overrides: [workoutLogRepositoryProvider.overrideWithValue(logRepo)],
      ).read(gymStateProvider.notifier);
    }

    Future<int> openDay1(GymStateNotifier gymNotifier) => gymNotifier.open(getTestRoutine(), 1, 1);

    /// Runs a workout up to [currentPage], with one log page marked as done
    Future<void> runWorkout({int currentPage = 2}) async {
      await openDay1(notifier);
      notifier.markSlotPageAsDone(notifier.state.pages[1].slotPages[1].key, isDone: true);
      notifier.setCurrentPage(currentPage);
      await pumpEventQueue();
    }

    /// Changes one field of the stored progress
    Future<void> editStoredProgress(String key, Object value) async {
      final stored =
          json.decode((await PreferenceHelper.asyncPref.getString(PREFS_WORKOUT_PROGRESS))!)
              as Map<String, dynamic>;
      stored[key] = value;
      await PreferenceHelper.asyncPref.setString(PREFS_WORKOUT_PROGRESS, json.encode(stored));
    }

    test('Continues the workout in memory with its progress', () async {
      await runWorkout();
      final timerKey = notifier.state.pages[1].slotPages[2].key;
      withClock(Clock.fixed(DateTime(2026, 7, 26, 18, 30)), () {
        notifier.startTimerIfNeeded(timerKey);
      });

      // The app kept running, the user only left gym mode and came back
      expect(await openDay1(notifier), 2);
      expect(
        notifier.state.progressOf(notifier.state.pages[1].slotPages[1].key).done,
        isTrue,
        reason: 'the set that was already logged is still marked as done',
      );
      expect(
        notifier.state.progressOf(timerKey).timerStartedAt,
        DateTime(2026, 7, 26, 18, 30),
        reason: 'the rest timer keeps running',
      );
    });

    test('Continues an interrupted workout where it stopped', () async {
      await runWorkout();

      final restarted = restartedNotifier();

      expect(await openDay1(restarted), 2);
      expect(restarted.state.currentPage, 2);
      expect(
        restarted.state.progressOf(restarted.state.pages[1].slotPages[1].key).done,
        isTrue,
        reason: 'the set that was already logged is still marked as done',
      );
    });

    test('Keeps the elapsed time of an interrupted workout', () async {
      await withClock(Clock.fixed(DateTime(2026, 7, 26, 18, 30)), () async {
        await runWorkout();
      });

      // Two minutes later the app is started again
      await withClock(Clock.fixed(DateTime(2026, 7, 26, 18, 32)), () async {
        final restarted = restartedNotifier();
        await openDay1(restarted);

        expect(restarted.state.workoutStart, DateTime(2026, 7, 26, 18, 30));
      });
    });

    test('Does not continue the workout of another day', () async {
      await runWorkout();
      await editStoredProgress('dayId', 2);

      final restarted = restartedNotifier();

      expect(await openDay1(restarted), 0);
      expect(restarted.state.currentPage, 0);
    });

    test('Does not continue a workout that is too old', () async {
      await withClock(Clock.fixed(DateTime(2026, 7, 26, 18, 30)), () async {
        await runWorkout();
      });

      // The next morning the workout is long over
      await withClock(Clock.fixed(DateTime(2026, 7, 27, 9, 0)), () async {
        final restarted = restartedNotifier();

        expect(await openDay1(restarted), 0);
        expect(restarted.state.currentPage, 0);
      });
    });

    test('Restores the logged entries and the rest timers', () async {
      final logPage = notifier.state.pages[1].slotPages[1];
      final timerKey = notifier.state.pages[1].slotPages[2].key;
      final log = Log(id: 'log-1', exerciseId: 1, weight: 80, date: DateTime(2026, 7, 26));
      await openDay1(notifier);
      withClock(Clock.fixed(DateTime(2026, 7, 26, 18, 30)), () {
        notifier.markSlotPageAsDone(logPage.key, isDone: true, log: log);
      });
      notifier.setCurrentPage(3);
      await pumpEventQueue();

      final restarted = restartedNotifier(logs: [log]);

      expect(await openDay1(restarted), 3);
      expect(restarted.state.progressOf(logPage.key).loggedEntry!.id, 'log-1');
      expect(
        restarted.state.progressOf(timerKey).timerStartedAt,
        DateTime(2026, 7, 26, 18, 30),
        reason: 'the rest that started with the logged set keeps running',
      );
    });

    test('Restores the rest of the progress when the logs can not be read', () async {
      final logPage = notifier.state.pages[1].slotPages[1];
      final timerKey = notifier.state.pages[1].slotPages[2].key;
      final log = Log(id: 'log-1', exerciseId: 1, date: DateTime(2026, 7, 26));
      await openDay1(notifier);
      withClock(Clock.fixed(DateTime(2026, 7, 26, 18, 30)), () {
        notifier.markSlotPageAsDone(logPage.key, isDone: true, log: log);
      });
      notifier.setCurrentPage(3);
      await pumpEventQueue();

      final restarted = restartedNotifier(lookupError: StateError('database closed'));

      expect(await openDay1(restarted), 3);
      expect(restarted.state.progressOf(logPage.key).done, isTrue);
      expect(restarted.state.progressOf(logPage.key).loggedEntry, isNull);
      expect(restarted.state.progressOf(timerKey).timerStartedAt, DateTime(2026, 7, 26, 18, 30));
    });

    test('Stores a rest timer as soon as it starts', () async {
      await runWorkout();
      final timerKey = notifier.state.pages[1].slotPages[2].key;

      // Killed during the rest, before moving on to another page
      withClock(Clock.fixed(DateTime(2026, 7, 26, 18, 30)), () {
        notifier.startTimerIfNeeded(timerKey);
      });
      await pumpEventQueue();

      final restarted = restartedNotifier();
      await openDay1(restarted);

      expect(restarted.state.progressOf(timerKey).timerStartedAt, DateTime(2026, 7, 26, 18, 30));
    });

    test('Leaves out the pages the routine no longer has', () async {
      await runWorkout();

      // The routine was edited in the meantime, the page the workout stopped
      // on and one of the done sets are gone
      await editStoredProgress('currentPageKey', 'log:999:1');
      final stored =
          json.decode((await PreferenceHelper.asyncPref.getString(PREFS_WORKOUT_PROGRESS))!)
              as Map<String, dynamic>;
      await editStoredProgress('pages', {
        ...stored['pages'] as Map<String, dynamic>,
        'log:999:2': {'done': true},
      });

      final restarted = restartedNotifier();

      expect(await openDay1(restarted), 0);
      expect(restarted.state.progress.keys, ['log:1:1']);
    });

    test('Ignores progress stored in an older format', () async {
      await PreferenceHelper.asyncPref.setString(
        PREFS_WORKOUT_PROGRESS,
        json.encode({
          'dayId': 1,
          'iteration': 1,
          'currentPage': 2,
          'workoutStart': DateTime.now().toIso8601String(),
          'validUntil': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          'donePageIndices': [2],
        }),
      );

      expect(await openDay1(restartedNotifier()), 0);
      expect(await PreferenceHelper.asyncPref.getString(PREFS_WORKOUT_PROGRESS), isNull);
    });

    test('Forgets the workout once it is finished', () async {
      await runWorkout();

      notifier.clear();
      await pumpEventQueue();

      expect(await openDay1(restartedNotifier()), 0);
    });

    test('Ignores stored progress that can not be read', () async {
      await PreferenceHelper.asyncPref.setString(PREFS_WORKOUT_PROGRESS, 'not json');

      expect(await openDay1(restartedNotifier()), 0);
      expect(
        await PreferenceHelper.asyncPref.getString(PREFS_WORKOUT_PROGRESS),
        isNull,
        reason: 'the unreadable value is cleared instead of failing again later',
      );
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

  group('GymModeState.getNextLogPage', () {
    // Page structure of the test routine (exercise + timer pages enabled):
    //   start(0)
    //   slot 1 (exercise 1): overview(1), log(2), timer(3), log(4), timer(5), log(6), timer(7)
    //   slot 2 (exercise 6): overview(8), log(9), timer(10), log(11), timer(12), log(13), timer(14)
    //   session(15), summary(16)

    test('Returns the next set of the same exercise for a rest between sets', () {
      final next = notifier.state.getNextLogPage(3);

      expect(next!.type, SlotPageType.log);
      expect(next.pageIndex, 4);
      expect(next.setConfigData!.exerciseId, getTestExercises()[0].id);
    });

    test('Returns the first set of the next exercise after the final rest of an exercise', () {
      final next = notifier.state.getNextLogPage(7);

      expect(next!.type, SlotPageType.log);
      expect(next.pageIndex, 9);
      expect(next.setConfigData!.exerciseId, getTestExercises()[5].id);
    });

    test('Returns null after the last set of the day', () {
      expect(notifier.state.getNextLogPage(14), isNull);
    });
  });
}
