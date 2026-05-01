/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/exercises/exercise_submission.dart';
import 'package:wger/providers/add_exercise_repository.dart';
import 'package:wger/providers/base_provider.dart';

import 'add_exercise_repository_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late MockWgerBaseProvider mockBase;
  late AddExerciseRepository repo;

  setUp(() {
    mockBase = MockWgerBaseProvider();
    repo = AddExerciseRepository(mockBase);
  });

  group('submit', () {
    test('POSTs the payload as JSON and returns the new exercise id', () async {
      final uri = Uri.https('localhost', 'api/v2/exercise-submission/');
      when(mockBase.makeUrl('exercise-submission')).thenReturn(uri);
      when(mockBase.post(any, uri)).thenAnswer((_) async => {'id': 42});

      const payload = ExerciseSubmissionApi(
        author: 'Alice',
        category: 1,
        muscles: [1],
        musclesSecondary: [],
        equipment: [],
        translations: [],
      );

      final id = await repo.submit(payload);

      expect(id, 42);
      verify(mockBase.post(payload.toJson(), uri)).called(1);
    });
  });

  // Note: uploadImage is not unit-tested here. It builds an http.MultipartRequest
  // and calls .send() directly without going through WgerBaseProvider, so a
  // proper test requires HTTP-level mocking (e.g. MockClient + dependency
  // injection of the http.Client). Tracked as a separate task.
}
