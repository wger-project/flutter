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
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';

import '../../../../test_data/exercises.dart';
import '../../../../test_data/routines.dart';

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
      final slotPage = notifier.state.pages[1].slotPages[1];
      expect(slotPage.type, SlotPageType.log);
      notifier.state.pages.every((p) => p.exercises.every((s) => s.id != testSquats.id));

      // Act
      notifier.replaceExercises(slotPage.uuid, originalExerciseId: 1, newExercise: testSquats);
      // print(notifier.readPageStructure());

      // Assert
      expect(notifier.state.pages[1].exercises.first.id, testSquats.id);
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
