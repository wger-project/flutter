/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2025 wger Team
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
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/routines.dart';

import '../fixtures/fixture_reader.dart';
import 'routines_provider_repository_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  final mockBaseProvider = MockWgerBaseProvider();

  group('test the routine provider repository', () {
    test('Test creating a new routine', () async {
      // Arrange
      final repo = RoutinesRepository(mockBaseProvider);
      final uri = Uri.https('localhost', 'api/v2/routine/');
      when(
        mockBaseProvider.makeUrl('routine'),
      ).thenReturn(uri);
      when(mockBaseProvider.post(any, uri)).thenAnswer(
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

      // Act
      final plan = await repo.addRoutineServer(
        Routine(
          id: 325397,
          name: 'Test workout',
          description: 'Test workout abcd',
        ),
      );

      // Assert
      expect(plan, isA<Routine>());
      expect(plan.id, 325397);
      expect(plan.description, 'Test workout abcd');
    });

    test('Test deleting a workout plan', () async {
      // Arrange
      when(mockBaseProvider.deleteRequest('routine', 325397)).thenAnswer(
        (_) => Future.value(Response('', 204)),
      );

      // Act
      final repo = RoutinesRepository(mockBaseProvider);
      await repo.deleteRoutineServer(325397);
      verify(mockBaseProvider.deleteRequest('routine', 325397)).called(1);
    });

    test('Smoke test fetchAndSetRoutineFullServer', () async {
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

      final repo = RoutinesRepository(mockBaseProvider);

      // Act
      final result = await repo.fetchAndSetRoutineFullServer(101);

      // Assert
      expect(result, isA<Routine>());
      expect(result.id, 101);
      expect(result.days.length, 3);
      // expect(result.sessions.length, 3);
      // expect(result.logs.length, 12);
      expect(result.dayDataCurrentIteration.length, 8);
      expect(result.dayDataCurrentIterationGym.length, 8);
      expect(result.dayData.length, 32);
      expect(result.dayDataGym.length, 32);
    });
  });
}
