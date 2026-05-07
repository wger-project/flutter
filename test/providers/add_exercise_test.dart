/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/base_provider.dart';

import 'add_exercise_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late MockWgerBaseProvider mockBaseProvider;
  late AddExerciseProvider provider;

  final checkLanguageUri = Uri.parse('https://localhost/api/v2/check-language/');

  setUp(() {
    mockBaseProvider = MockWgerBaseProvider();
    provider = AddExerciseProvider(mockBaseProvider);
    when(mockBaseProvider.makeUrl(any)).thenReturn(checkLanguageUri);
  });

  group('validateLanguage', () {
    test('returns null when the server accepts the language', () async {
      when(
        mockBaseProvider.post(any, checkLanguageUri),
      ).thenAnswer((_) async => {'result': true});

      final result = await provider.validateLanguage('a long enough description', 'en');

      expect(result, isNull);
      verify(
        mockBaseProvider.post({
          'input': 'a long enough description',
          'language_code': 'en',
        }, checkLanguageUri),
      ).called(1);
    });

    test('returns the server-supplied message when the language does not match', () async {
      const serverMessage =
          'The detected language is "Spanish" (es), which does not match your selected language "English" (en).';
      when(mockBaseProvider.post(any, checkLanguageUri)).thenThrow(
        WgerHttpException.fromMap({
          'check': {
            'result': false,
            'detected_language': 'es',
            'message': serverMessage,
          },
        }),
      );

      final result = await provider.validateLanguage('Hola, esto es una prueba.', 'en');

      expect(result, equals(serverMessage));
    });

    test('falls back to the raw error map when the response shape is unexpected', () async {
      // Hitting the serializer's min_length=10 on `input` returns a 400 with a
      // different shape (no `check` key).
      when(mockBaseProvider.post(any, checkLanguageUri)).thenThrow(
        WgerHttpException.fromMap({
          'input': ['Ensure this field has at least 10 characters.'],
        }),
      );

      final result = await provider.validateLanguage('short', 'en');

      expect(result, isNotNull);
      expect(result, contains('input'));
    });

    test('falls back to the raw error map when `check` is present without a message', () async {
      when(mockBaseProvider.post(any, checkLanguageUri)).thenThrow(
        WgerHttpException.fromMap({
          'check': {'result': false},
        }),
      );

      final result = await provider.validateLanguage('a long enough description', 'en');

      expect(result, isNotNull);
      expect(result, contains('check'));
    });
  });
}
