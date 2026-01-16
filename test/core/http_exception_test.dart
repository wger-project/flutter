/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:wger/core/exceptions/http_exception.dart';

void main() {
  group('WgerHttpException', () {
    test('parses valid JSON response', () {
      // Arrange
      final resp = http.Response(
        '{"foo":"bar"}',
        400,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );

      // Act
      final ex = WgerHttpException(resp);

      // Assert
      expect(ex.type, ErrorType.json);
      expect(ex.errors['foo'], 'bar');
      expect(ex.toString(), contains('WgerHttpException'));
    });

    test('falls back on malformed JSON', () {
      // Arrange
      const body = '{"foo":';
      final resp = http.Response(
        body,
        500,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );

      // Act
      final ex = WgerHttpException(resp);

      // Assert
      expect(ex.type, ErrorType.json);
      expect(ex.errors['unknown_error'], body);
    });

    test('detects HTML response from headers', () {
      // Arrange
      const body = '<html lang="en"><body>Error</body></html>';
      final resp = http.Response(
        body,
        500,
        headers: {HttpHeaders.contentTypeHeader: 'text/html; charset=utf-8'},
      );

      // Act
      final ex = WgerHttpException(resp);

      // Assert
      expect(ex.type, ErrorType.html);
      expect(ex.htmlError, body);
    });

    test('detects HTML response from content', () {
      // Arrange
      const body = '<html lang="en"><body>Error</body></html>';
      final resp = http.Response(
        body,
        500,
        headers: {HttpHeaders.contentTypeHeader: 'text/foo; charset=utf-8'},
      );

      // Act
      final ex = WgerHttpException(resp);

      // Assert
      expect(ex.type, ErrorType.html);
      expect(ex.htmlError, body);
    });

    test('fromMap sets errors and type', () {
      // Arrange
      final map = <String, dynamic>{'field': 'value'};

      // Act
      final ex = WgerHttpException.fromMap(map);

      // Assert
      expect(ex.type, ErrorType.json);
      expect(ex.errors, map);
    });
  });
}
