/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2025 - 2025 wger Team
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
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/slot_data.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/gym_mode/log_page.dart';

import '../../../../test_data/exercises.dart';
import '../../../../test_data/routines.dart' as testdata;
import 'log_page_test.mocks.dart';

@GenerateMocks([ExercisesProvider, RoutinesProvider])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LogPage smoke tests', () {
    late List<Exercise> testExercises;
    late ProviderContainer container;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      testExercises = getTestExercises();
      container = ProviderContainer.test();
    });

    Future<void> pumpLogPage(WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: provider.ChangeNotifierProvider<RoutinesProvider>.value(
            value: MockRoutinesProvider(),
            child: MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: LogPage(PageController()),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('handles null values', (tester) async {
      // Arrange
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
              exerciseIds: [testExercises[0].id!],
              setConfigs: [
                SetConfigData(
                  exerciseId: testExercises[0].id!,
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
      notifier.state = notifier.state.copyWith(
        dayId: routine.days.first.id,
        routine: routine,
        iteration: 1,
        currentPage: 2,
      );

      // Act
      notifier.calculatePages();

      // Assert
      expect(notifier.state.getSlotEntryPageByIndex()!.type, SlotPageType.log);
      await pumpLogPage(tester);
      expect(find.byType(LogPage), findsOneWidget);
    });

    testWidgets('renders without crashing for default slotEntryPage', (tester) async {
      final notifier = container.read(gymStateProvider.notifier);
      final routine = testdata.getTestRoutine();
      notifier.state = notifier.state.copyWith(
        dayId: routine.days.first.id,
        routine: routine,
        iteration: 1,
      );
      notifier.calculatePages();
      await pumpLogPage(tester);

      expect(find.byType(LogPage), findsOneWidget);
    });
  });
}
