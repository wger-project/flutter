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
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/workout_plans.dart';
import '../measurements/measurement_provider_test.mocks.dart';
import '../other/base_provider_test.mocks.dart';
import '../utils.dart';

void main() {
  var repetitionUnitsResponse = '{"count":7,"next":null,"previous":null,'
      '"results":['
      '{"id":6,"name":"Kilometers"},'
      '{"id":7,"name":"MaxReps"},'
      '{"id":5,"name":"Miles"},'
      '{"id":4,"name":"Minutes"},'
      '{"id":1,"name":"Repetitions"},'
      '{"id":3,"name":"Seconds"},'
      '{"id":2,"name":"UntilFailure"}]}';

  var weightUnitsResponse = '{"count":6,"next":null,"previous":null,'
      '"results":['
      '{"id":3,"name":"BodyWeight"},'
      '{"id":1,"name":"kg"},'
      '{"id":5,"name":"KilometersPerHour"},'
      '{"id":2,"name":"lb"},'
      '{"id":6,"name":"MilesPerHour"},'
      '{"id":4,"name":"Plates"}]}';

  group('test workout plans provider', () {
    test('Test that fetch and set plans', () async {
      final client = MockClient();

      final mockBaseProvider = MockWgerBaseProvider();
      final ExercisesProvider testExercisesProvider = ExercisesProvider(mockBaseProvider);

      when(client.get(
        Uri.https('localhost', 'api/v2/workout/325397/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
          '{"id": 325397,"name": "Test workout","creation_date": "2022-10-10","description": "It is test workout to fix a bug."}',
          200));

      // Load the entries
      final WorkoutPlansProvider provider =
          WorkoutPlansProvider(testAuthProvider, testExercisesProvider, [], client);

      final plan = await provider.fetchAndSetPlanSparse(325397);
      final plans = provider.getPlans();

      // Check that everything is ok
      expect(plan, isA<WorkoutPlan>());
      expect(plan.id, 325397);
      expect(plans.length, 1);
    });

    test('Test that deletes workout plan', () async {
      final client = MockClient();

      final mockBaseProvider = MockWgerBaseProvider();
      final ExercisesProvider testExercisesProvider = ExercisesProvider(mockBaseProvider);

      when(client.get(
        Uri.https('localhost', 'api/v2/workout/325397/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
          '{"id": 325397,"name": "Test workout","creation_date": "2022-10-10","description": "It is test workout to fix a bug."}',
          200));

      when(client.delete(
        Uri.https('localhost', 'api/v2/workout/325397/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
          '{"id": 325397,"name": "Test workout","creation_date": "2022-10-10","description": "It is test workout to fix a bug."}',
          200));

      // Load the entries
      final WorkoutPlansProvider provider =
          WorkoutPlansProvider(testAuthProvider, testExercisesProvider, [], client);

      await provider.fetchAndSetPlanSparse(325397);
      await provider.deleteWorkout(325397);
      final plans = provider.getPlans();
      expect(plans.length, 0);
    });

    test('Test that fetch and set repetition units for workout', () async {
      final client = MockClient();

      final mockBaseProvider = MockWgerBaseProvider();
      final ExercisesProvider testExercisesProvider = ExercisesProvider(mockBaseProvider);

      when(client.get(
        Uri.https('localhost', 'api/v2/setting-repetitionunit/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(repetitionUnitsResponse, 200));

      // Load the entries
      final WorkoutPlansProvider provider =
          WorkoutPlansProvider(testAuthProvider, testExercisesProvider, [], client);

      await provider.fetchAndSetRepetitionUnits();

      List<RepetitionUnit> repetitionUnits = provider.repetitionUnits;

      expect(repetitionUnits, isA<List<RepetitionUnit>>());
      expect(repetitionUnits.length, 7);
    });
    test('Test that fetch and set weight units for workout', () async {
      final client = MockClient();

      final mockBaseProvider = MockWgerBaseProvider();
      final ExercisesProvider testExercisesProvider = ExercisesProvider(mockBaseProvider);

      when(client.get(
        Uri.https('localhost', 'api/v2/setting-weightunit/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(weightUnitsResponse, 200));

      // Load the entries
      final WorkoutPlansProvider provider =
          WorkoutPlansProvider(testAuthProvider, testExercisesProvider, [], client);

      await provider.fetchAndSetWeightUnits();

      List<WeightUnit> weightUnits = provider.weightUnits;

      expect(weightUnits, isA<List<WeightUnit>>());
      expect(weightUnits.length, 6);
    });

    test('Test that fetch and set both type of units', () async {
      final client = MockClient();

      final mockBaseProvider = MockWgerBaseProvider();
      final ExercisesProvider testExercisesProvider = ExercisesProvider(mockBaseProvider);
      final prefs = await SharedPreferences.getInstance();

      when(client.get(
        Uri.https('localhost', 'api/v2/setting-repetitionunit/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(repetitionUnitsResponse, 200));
      when(client.get(
        Uri.https('localhost', 'api/v2/setting-weightunit/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(weightUnitsResponse, 200));

      // Load the entries
      final WorkoutPlansProvider provider =
          WorkoutPlansProvider(testAuthProvider, testExercisesProvider, [], client);

      await provider.fetchAndSetUnits();

      dynamic prefsJson = jsonDecode(prefs.getString('workoutUnits')!);

      expect(prefsJson["repetitionUnits"].length, 7);
      expect(prefsJson["weightUnit"].length, 6);
      expect(true, DateTime.parse(prefsJson["date"]).isBefore(DateTime.now()));
      expect(true, DateTime.parse(prefsJson["expiresIn"]).isAfter(DateTime.now()));
    });
  });
}
