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
import 'package:wger/core/locator.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/workout_plans.dart';

import '../fixtures/fixture_reader.dart';
import 'workout_provider_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  final mockBaseProvider = MockWgerBaseProvider();

  setUpAll(() async {
    // Needs to be configured here, setUp runs on every test, setUpAll only once
    await ServiceLocator().configure();
  });

  group('test the workout routine provider', () {
    test('Test fetching and setting a plan', () async {
      final exercisesProvider = ExercisesProvider(mockBaseProvider);

      final uri = Uri.https('localhost', 'api/v2/workout/325397/');
      when(mockBaseProvider.makeUrl('workout', id: 325397)).thenReturn(uri);
      when(mockBaseProvider.fetch(
        uri,
      )).thenAnswer(
        (_) async => Future.value({
          'id': 325397,
          'name': 'Test workout',
          'creation_date': '2022-10-10',
          'description': 'Test workout abcd'
        }),
      );

      // Load the entries
      final provider = WorkoutPlansProvider(mockBaseProvider, exercisesProvider, []);
      final plan = await provider.fetchAndSetPlanSparse(325397);
      final plans = provider.getPlans();

      // Check that everything is ok
      expect(plan, isA<WorkoutPlan>());
      expect(plan.id, 325397);
      expect(plan.description, 'Test workout abcd');
      expect(plans.length, 1);
    });

    test('Test deleting a workout plan', () async {
      final exercisesProvider = ExercisesProvider(mockBaseProvider);
      final uri = Uri.https('localhost', 'api/v2/workout/325397/');
      when(mockBaseProvider.makeUrl('workout', id: 325397)).thenReturn(uri);
      when(mockBaseProvider.fetch(
        uri,
      )).thenAnswer(
        (_) async => Future.value({
          'id': 325397,
          'name': 'Test workout',
          'creation_date': '2022-10-10',
          'description': 'Test workout abcd'
        }),
      );
      when(mockBaseProvider.deleteRequest('workout', 325397)).thenAnswer(
        (_) => Future.value(Response('', 204)),
      );

      // Load the entries
      final provider = WorkoutPlansProvider(mockBaseProvider, exercisesProvider, []);

      await provider.fetchAndSetPlanSparse(325397);
      await provider.deleteWorkout(325397);
      final plans = provider.getPlans();
      expect(plans.length, 0);
    });

    test('Test that fetch and set repetition units for workout', () async {
      final exercisesProvider = ExercisesProvider(mockBaseProvider);

      final uri = Uri.https('localhost', 'api/v2/setting-repetitionunit/');
      final tRepetitionUnits = jsonDecode(fixture('routines/repetition_units.json'));
      when(mockBaseProvider.makeUrl('setting-repetitionunit')).thenReturn(uri);
      when(mockBaseProvider.fetchPaginated(uri))
          .thenAnswer((_) => Future.value(tRepetitionUnits['results']));

      // Load the entries
      final provider = WorkoutPlansProvider(mockBaseProvider, exercisesProvider, []);
      await provider.fetchAndSetRepetitionUnits();
      final repetitionUnits = provider.repetitionUnits;

      expect(repetitionUnits, isA<List<RepetitionUnit>>());
      expect(repetitionUnits.length, 7);
    });
    test('Test that fetch and set weight units for workout', () async {
      final uri = Uri.https('localhost', 'api/v2/setting-weightunit/');
      when(mockBaseProvider.makeUrl('setting-weightunit')).thenReturn(uri);
      final tWeightUnits = jsonDecode(fixture('routines/weight_units.json'));
      when(mockBaseProvider.fetchPaginated(uri))
          .thenAnswer((_) => Future.value(tWeightUnits['results']));

      final ExercisesProvider testExercisesProvider = ExercisesProvider(mockBaseProvider);

      // Load the entries
      final provider = WorkoutPlansProvider(mockBaseProvider, testExercisesProvider, []);
      await provider.fetchAndSetWeightUnits();
      final weightUnits = provider.weightUnits;

      expect(weightUnits, isA<List<WeightUnit>>());
      expect(weightUnits.length, 6);
    });

    test('Test that fetch and set both type of units', () async {
      final weightUri = Uri.https('localhost', 'api/v2/setting-weightunit/');
      when(mockBaseProvider.makeUrl('setting-weightunit')).thenReturn(weightUri);
      final tWeightUnits = jsonDecode(fixture('routines/weight_units.json'));
      when(mockBaseProvider.fetchPaginated(weightUri))
          .thenAnswer((_) => Future.value(tWeightUnits['results']));

      final repUnit = Uri.https('localhost', 'api/v2/setting-repetitionunit/');
      final tRepetitionUnits = jsonDecode(fixture('routines/repetition_units.json'));
      when(mockBaseProvider.makeUrl('setting-repetitionunit')).thenReturn(repUnit);
      when(mockBaseProvider.fetchPaginated(repUnit))
          .thenAnswer((_) => Future.value(tRepetitionUnits['results']));

      final exercisesProvider = ExercisesProvider(mockBaseProvider);
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Load the entries
      final provider = WorkoutPlansProvider(mockBaseProvider, exercisesProvider, []);
      await provider.fetchAndSetUnits();
      final prefsJson = jsonDecode(prefs.getString('workoutUnits')!);

      expect(prefsJson['repetitionUnits'].length, 7);
      expect(prefsJson['weightUnit'].length, 6);
      expect(true, DateTime.parse(prefsJson['date']).isBefore(DateTime.now()));
      expect(true, DateTime.parse(prefsJson['expiresIn']).isAfter(DateTime.now()));
    });
  });
}
