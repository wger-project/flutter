/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2025 - 2026 wger Team
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/slot_data.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/gym_state_notifier.dart';
import 'package:wger/providers/workout_logs_repository.dart';
import 'package:wger/widgets/routines/gym_mode/log_page.dart';

import '../../../../test_data/exercises.dart';
import '../../../../test_data/routines.dart' as testdata;
import 'log_page_test.mocks.dart';

@GenerateMocks([WorkoutLogRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LogPage tests', () {
    late List<Exercise> testExercises;
    late ProviderContainer container;
    late MockWorkoutLogRepository mockWorkoutLogRepo;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      testExercises = getTestExercises();
      mockWorkoutLogRepo = MockWorkoutLogRepository();
      when(mockWorkoutLogRepo.addLocalDrift(any)).thenAnswer((_) async {});
      container = ProviderContainer.test(
        overrides: [workoutLogRepositoryProvider.overrideWithValue(mockWorkoutLogRepo)],
      );
    });

    /// Seeds the gym state with [routine] and navigates to the first log page
    /// (index 2: start -> exercise overview -> log). [setCurrentPage] also
    /// seeds gymLogProvider with the log template for that slot.
    void seedLogPage(Routine routine) {
      final notifier = container.read(gymStateProvider.notifier);
      notifier.initData(routine, routine.days.first.id!, 1);
      notifier.setCurrentPage(2);
    }

    Future<void> pumpLogPage(WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              // A PageView gives LogPage's PageController something to attach to.
              body: Builder(
                builder: (context) {
                  final controller = PageController();
                  return PageView(controller: controller, children: [LogPage(controller)]);
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('handles null reps/weight without crashing', (tester) async {
      final notifier = container.read(gymStateProvider.notifier);
      final routine = testdata.getTestRoutine();
      routine.dayDataGym = [
        DayData(
          iteration: 1,
          date: DateTime(2024, 11, 01),
          label: '',
          day: routine.dayDataGym.first.day,
          slots: [
            SlotData(
              isSuperset: false,
              exerciseIds: [testExercises[0].id],
              setConfigs: [
                SetConfigData(
                  exerciseId: testExercises[0].id,
                  exercise: testExercises[0],
                  slotEntryId: 1,
                  nrOfSets: 1,
                  repetitions: null,
                  repetitionsUnit: null,
                  weight: null,
                  weightUnit: null,
                  restTime: 120,
                  rir: 1.5,
                  rpe: 8,
                  textRepr: '3x100kg',
                ),
              ],
            ),
          ],
        ),
      ];
      notifier.initData(routine, routine.days.first.id!, 1);
      notifier.setCurrentPage(2);

      expect(notifier.state.getSlotEntryPageByIndex()!.type, SlotPageType.log);
      await pumpLogPage(tester);
      expect(find.byType(LogPage), findsOneWidget);
    });

    testWidgets('renders without crashing for the default slot entry page', (tester) async {
      seedLogPage(testdata.getTestRoutine());
      await pumpLogPage(tester);

      expect(find.byType(LogPage), findsOneWidget);
    });

    testWidgets('copy from past log updates form fields and shows a SnackBar', (tester) async {
      seedLogPage(testdata.getTestRoutine());
      await pumpLogPage(tester);

      final pastLogTile = find.byWidgetPredicate(
        (w) => w.key is ValueKey && '${(w.key as ValueKey).value}'.startsWith('past-log-'),
      );
      expect(pastLogTile, findsWidgets);
      await tester.tap(pastLogTile.first);
      await tester.pumpAndSettle();

      final editableFields = find.byType(EditableText);
      expect(editableFields, findsWidgets);
      final repText = tester.widget<EditableText>(editableFields.at(0)).controller.text;
      final weightText = tester.widget<EditableText>(editableFields.at(1)).controller.text;
      expect(repText, contains('10'));
      expect(weightText, contains('10'));
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('save button persists the entered reps/weight with slot/routine/iteration', (
      tester,
    ) async {
      seedLogPage(testdata.getTestRoutine());
      await pumpLogPage(tester);

      // Overwrite the pre-filled values so the assertion proves the user's
      // edits flow through, not just the set-config defaults.
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '12'); // reps
      await tester.enterText(fields.at(1), '34'); // weight
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('save-log-button')));
      await tester.pumpAndSettle();

      final saved = verify(mockWorkoutLogRepo.addLocalDrift(captureAny)).captured.single as Log;
      final gymState = container.read(gymStateProvider);
      expect(saved.repetitions, 12);
      expect(saved.weight, 34);
      expect(saved.slotEntryId, gymState.getSlotEntryPageByIndex()!.setConfigData!.slotEntryId);
      expect(saved.routineId, gymState.routine.id);
      expect(saved.iteration, gymState.iteration);
    });

    testWidgets('reps quick buttons increment and decrement the value', (tester) async {
      final routine = testdata.getTestRoutine();
      routine.dayDataGym[0].slots[0].setConfigs[0].repetitions = 0;
      seedLogPage(routine);
      await pumpLogPage(tester);

      final repsWidget = find.byKey(const ValueKey('logs-reps-widget'));
      expect(repsWidget, findsOneWidget);
      final addBtn = find.descendant(of: repsWidget, matching: find.byIcon(Icons.add));
      final removeBtn = find.descendant(of: repsWidget, matching: find.byIcon(Icons.remove));

      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      expect(find.descendant(of: repsWidget, matching: find.text('1')), findsOneWidget);

      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      expect(find.descendant(of: repsWidget, matching: find.text('2')), findsOneWidget);

      await tester.tap(removeBtn);
      await tester.pumpAndSettle();
      expect(find.descendant(of: repsWidget, matching: find.text('1')), findsOneWidget);
    });

    testWidgets('weight quick buttons increment and decrement the value', (tester) async {
      final routine = testdata.getTestRoutine();
      routine.dayDataGym[0].slots[0].setConfigs[0].weight = 0;
      seedLogPage(routine);
      await pumpLogPage(tester);

      final weightWidget = find.byKey(const ValueKey('logs-weight-widget'));
      expect(weightWidget, findsOneWidget);
      final addBtn = find.descendant(of: weightWidget, matching: find.byIcon(Icons.add));
      final removeBtn = find.descendant(of: weightWidget, matching: find.byIcon(Icons.remove));

      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      expect(find.descendant(of: weightWidget, matching: find.text('1.25')), findsOneWidget);

      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      expect(find.descendant(of: weightWidget, matching: find.text('2.5')), findsOneWidget);

      await tester.tap(removeBtn);
      await tester.pumpAndSettle();
      expect(find.descendant(of: weightWidget, matching: find.text('1.25')), findsOneWidget);
    });
  });
}
