/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/locator.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/routines.dart';

import '../../test_data/exercises.dart';
import '../../test_data/routines.dart';
import '../fixtures/fixture_reader.dart';
import 'routines_provider_test.mocks.dart';

@GenerateMocks([WgerBaseProvider, ExercisesProvider])
void main() {
  final mockBaseProvider = MockWgerBaseProvider();

  /// Replacement for SharedPreferences.setMockInitialValues()
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

  setUpAll(() async {
    // Needs to be configured here, setUp runs on every test, setUpAll only once
    await ServiceLocator().configure();
  });

  group('test the workout routine provider', () {
    test('Test fetching and setting a routine', () async {
      final exercisesProvider = ExercisesProvider(mockBaseProvider);

      final uri = Uri.https('localhost', 'api/v2/routine/325397/');
      when(
        mockBaseProvider.makeUrl('routine', id: 325397, query: {'limit': API_MAX_PAGE_SIZE}),
      ).thenReturn(uri);
      when(mockBaseProvider.fetch(uri)).thenAnswer(
        (_) async => Future.value({
          'id': 325397,
          'created': '2022-10-10',
          'name': 'Test workout',
          'description': 'Test workout abcd',
          'start': '2021-12-20',
          'end': '2022-06-06',
          'fit_in_week': false,
        }),
      );

      // Load the entries
      final provider = RoutinesProvider(mockBaseProvider, exercisesProvider, []);
      final plan = await provider.fetchAndSetRoutineSparse(325397);
      final plans = provider.getPlans();

      // Check that everything is ok
      expect(plan, isA<Routine>());
      expect(plan.id, 325397);
      expect(plan.description, 'Test workout abcd');
      expect(plans.length, 1);
    });

    test('Test deleting a workout plan', () async {
      final exercisesProvider = ExercisesProvider(mockBaseProvider);
      final uri = Uri.https('localhost', 'api/v2/workout/325397/');
      when(mockBaseProvider.makeUrl('workout', id: 325397)).thenReturn(uri);
      when(mockBaseProvider.fetch(uri)).thenAnswer(
        (_) async => Future.value({
          'id': 325397,
          'name': 'Test workout',
          'creation_date': '2022-10-10',
          'description': 'Test workout abcd',
        }),
      );
      when(mockBaseProvider.deleteRequest('routine', 325397)).thenAnswer(
        (_) => Future.value(Response('', 204)),
      );

      // Load the entries
      final provider = RoutinesProvider(mockBaseProvider, exercisesProvider, []);

      await provider.fetchAndSetRoutineSparse(325397);
      await provider.deleteRoutine(325397);
      final plans = provider.getPlans();
      expect(plans.length, 0);
    });

    test('Test that fetch and set repetition units for workout', () async {
      final exercisesProvider = ExercisesProvider(mockBaseProvider);

      final uri = Uri.https('localhost', 'api/v2/setting-repetitionunit/');
      final tRepetitionUnits = jsonDecode(fixture('routines/repetition_units.json'));
      when(mockBaseProvider.makeUrl('setting-repetitionunit')).thenReturn(uri);
      when(
        mockBaseProvider.fetchPaginated(uri),
      ).thenAnswer((_) => Future.value(tRepetitionUnits['results']));

      // Load the entries
      final provider = RoutinesProvider(mockBaseProvider, exercisesProvider, []);
      await provider.fetchAndSetRepetitionUnits();
      final repetitionUnits = provider.repetitionUnits;

      expect(repetitionUnits, isA<List<RepetitionUnit>>());
      expect(repetitionUnits.length, 7);
    });
    test('Test that fetch and set weight units for workout', () async {
      final uri = Uri.https('localhost', 'api/v2/setting-weightunit/');
      when(mockBaseProvider.makeUrl('setting-weightunit')).thenReturn(uri);
      final tWeightUnits = jsonDecode(fixture('routines/weight_units.json'));
      when(
        mockBaseProvider.fetchPaginated(uri),
      ).thenAnswer((_) => Future.value(tWeightUnits['results']));

      final ExercisesProvider testExercisesProvider = ExercisesProvider(mockBaseProvider);

      // Load the entries
      final provider = RoutinesProvider(mockBaseProvider, testExercisesProvider, []);
      await provider.fetchAndSetWeightUnits();
      final weightUnits = provider.weightUnits;

      expect(weightUnits, isA<List<WeightUnit>>());
      expect(weightUnits.length, 6);
    });

    test('Test that fetch and set both type of units', () async {
      final weightUri = Uri.https('localhost', 'api/v2/setting-weightunit/');
      when(mockBaseProvider.makeUrl('setting-weightunit')).thenReturn(weightUri);
      final tWeightUnits = jsonDecode(fixture('routines/weight_units.json'));
      when(
        mockBaseProvider.fetchPaginated(weightUri),
      ).thenAnswer((_) => Future.value(tWeightUnits['results']));

      final repUnit = Uri.https('localhost', 'api/v2/setting-repetitionunit/');
      final tRepetitionUnits = jsonDecode(fixture('routines/repetition_units.json'));
      when(mockBaseProvider.makeUrl('setting-repetitionunit')).thenReturn(repUnit);
      when(
        mockBaseProvider.fetchPaginated(repUnit),
      ).thenAnswer((_) => Future.value(tRepetitionUnits['results']));

      final exercisesProvider = ExercisesProvider(mockBaseProvider);
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferenceHelper.asyncPref;

      // Load the entries
      final provider = RoutinesProvider(mockBaseProvider, exercisesProvider, []);
      await provider.fetchAndSetUnits();
      final prefsJson = jsonDecode((await prefs.getString(PREFS_WORKOUT_UNITS))!);

      expect(prefsJson['repetitionUnits'].length, 7);
      expect(prefsJson['weightUnit'].length, 6);
      expect(true, DateTime.parse(prefsJson['date']).isBefore(DateTime.now()));
      expect(true, DateTime.parse(prefsJson['expiresIn']).isAfter(DateTime.now()));
    });

    test('Smoke test fetchAndSetRoutineFull', () async {
      //Arrange
      final structureUri = Uri.https('localhost', 'api/v2/routine/101/structure/');
      when(
        mockBaseProvider.makeUrl('routine', objectMethod: 'structure', id: 101),
      ).thenReturn(structureUri);
      when(mockBaseProvider.fetch(structureUri)).thenAnswer(
        (_) async => Future.value(
          jsonDecode(fixture('routines/routine_structure.json')),
        ),
      );

      final dateSequenceDisplayUri = Uri.https(
        'localhost',
        'api/v2/routine/101/date-sequence-display/',
      );
      when(
        mockBaseProvider.makeUrl('routine', objectMethod: 'date-sequence-display', id: 101),
      ).thenReturn(dateSequenceDisplayUri);
      when(mockBaseProvider.fetch(dateSequenceDisplayUri)).thenAnswer(
        (_) async => Future.value(
          jsonDecode(fixture('routines/routine_date_sequence_display.json')),
        ),
      );

      final dateSequenceGymUri = Uri.https('localhost', 'api/v2/routine/101/date-sequence-gym/');
      when(
        mockBaseProvider.makeUrl('routine', objectMethod: 'date-sequence-gym', id: 101),
      ).thenReturn(dateSequenceGymUri);
      when(mockBaseProvider.fetch(dateSequenceGymUri)).thenAnswer(
        (_) async => Future.value(
          jsonDecode(fixture('routines/routine_date_sequence_gym.json')),
        ),
      );

      final logsUri = Uri.https('localhost', 'api/v2/routine/101/logs/');
      when(mockBaseProvider.makeUrl('routine', objectMethod: 'logs', id: 101)).thenReturn(logsUri);
      when(mockBaseProvider.fetch(logsUri)).thenAnswer(
        (_) async => Future.value(
          jsonDecode(fixture('routines/routine_logs.json')),
        ),
      );

      final mockExercisesProvider = MockExercisesProvider();
      when(mockExercisesProvider.fetchAndSetExercise(76)).thenAnswer(
        (_) async => Future.value(testBenchPress),
      );
      when(mockExercisesProvider.fetchAndSetExercise(92)).thenAnswer(
        (_) async => Future.value(testCrunches),
      );

      final provider = RoutinesProvider(mockBaseProvider, mockExercisesProvider, []);
      provider.repetitionUnits = testRepetitionUnits;
      provider.weightUnits = testWeightUnits;

      // Act
      final result = await provider.fetchAndSetRoutineFull(101);

      // Assert
      expect(result, isA<Routine>());
      expect(result.id, 101);
      expect(result.sessions.length, 3);
      expect(result.days.length, 3);
      expect(result.logs.length, 12);
      expect(result.dayDataCurrentIteration.length, 8);
      expect(result.dayDataCurrentIterationGym.length, 8);
      expect(result.dayData.length, 32);
      expect(result.dayDataGym.length, 32);
    });
  });
}
