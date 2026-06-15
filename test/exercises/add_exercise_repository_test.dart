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
import 'package:wger/core/exceptions/http_exception.dart';
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

  group('validateLanguage', () {
    final checkLanguageUri = Uri.parse('https://localhost/api/v2/check-language/');

    setUp(() {
      when(mockBase.makeUrl('check-language')).thenReturn(checkLanguageUri);
    });

    test('returns null when the server accepts the language', () async {
      when(
        mockBase.post(any, checkLanguageUri),
      ).thenAnswer((_) async => {'result': true});

      final result = await repo.validateLanguage('a long enough description', 'en');

      expect(result, isNull);
      verify(
        mockBase.post({
          'input': 'a long enough description',
          'language_code': 'en',
        }, checkLanguageUri),
      ).called(1);
    });

    test('returns the server-supplied message when the language does not match', () async {
      const serverMessage =
          'The detected language is "Spanish" (es), which does not match your selected language "English" (en).';
      when(mockBase.post(any, checkLanguageUri)).thenThrow(
        WgerHttpException.fromMap({
          'check': {
            'result': false,
            'detected_language': 'es',
            'message': serverMessage,
          },
        }),
      );

      final result = await repo.validateLanguage('Hola, esto es una prueba.', 'en');

      expect(result, equals(serverMessage));
    });

    test('falls back to the raw error map when the response shape is unexpected', () async {
      when(mockBase.post(any, checkLanguageUri)).thenThrow(
        WgerHttpException.fromMap({
          'input': ['Ensure this field has at least 10 characters.'],
        }),
      );

      final result = await repo.validateLanguage('short', 'en');

      expect(result, isNotNull);
      expect(result, contains('input'));
    });

    test('falls back to the raw error map when `check` is present without a message', () async {
      when(mockBase.post(any, checkLanguageUri)).thenThrow(
        WgerHttpException.fromMap({
          'check': {'result': false},
        }),
      );

      final result = await repo.validateLanguage('a long enough description', 'en');

      expect(result, isNotNull);
      expect(result, contains('check'));
    });
  });
}
