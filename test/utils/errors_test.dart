/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) wger Team
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
import 'package:wger/helpers/errors.dart';

void main() {
  group('extractErrors', () {
    testWidgets('Returns empty list when errors is empty', (WidgetTester tester) async {
      final result = extractErrors({});
      expect(result, isEmpty);
    });

    testWidgets('Processes string values correctly', (WidgetTester tester) async {
      // Arrange
      final errors = {'error': 'Something went wrong'};

      // Act
      final result = extractErrors(errors);

      // Assert
      expect(result.length, 1, reason: 'Expected 1 error');
      expect(result[0].errorMessages.length, 1, reason: '1 error message');

      expect(result[0].key, 'Error');
      expect(result[0].errorMessages[0], 'Something went wrong');
    });

    testWidgets('Processes list values correctly', (WidgetTester tester) async {
      // Arrange
      final errors = {
        'validation_error': ['Error 1', 'Error 2'],
      };

      // Act
      final result = extractErrors(errors);

      // Assert
      expect(result[0].key, 'Validation error');
      expect(result[0].errorMessages[0], 'Error 1');
      expect(result[0].errorMessages[1], 'Error 2');
    });

    testWidgets('Processes nested list values correctly', (WidgetTester tester) async {
      // Arrange
      final errors = {
        'validation_error': {
          'subkey': ['Error 1', 'Error 2'],
        },
      };

      // Act
      final result = extractErrors(errors);

      // Assert
      expect(result[0].key, 'Validation error | Subkey');
      expect(result[0].errorMessages[0], 'Error 1');
      expect(result[0].errorMessages[1], 'Error 2');
    });

    testWidgets('Processes nested lists correctly', (WidgetTester tester) async {
      // Arrange
      final errors = {
        'validation_error': [
          {
            'subkey': ['Error 1', 'Error 2'],
          },
          {'otherKey': 'foo'},
        ],
      };

      // Act
      final result = extractErrors(errors);

      // Assert
      expect(result[0].key, 'Validation error | Subkey');
      expect(result[0].errorMessages[0], 'Error 1');
      expect(result[0].errorMessages[1], 'Error 2');
      expect(result[1].key, 'Validation error | OtherKey');
      expect(result[1].errorMessages[0], 'foo');
    });

    testWidgets('Processes multiple error types correctly', (WidgetTester tester) async {
      // Arrange
      final errors = {
        'username': ['Username is too boring', 'Username is too short'],
        'password': 'Password does not match',
      };

      // Act
      final result = extractErrors(errors);

      // Assert
      expect(result.length, 2);
      final error1 = result[0];
      final error2 = result[1];

      expect(error1.key, 'Username');
      expect(error1.errorMessages.length, 2);
      expect(error1.errorMessages[0], 'Username is too boring');
      expect(error1.errorMessages[1], 'Username is too short');

      expect(error2.key, 'Password');
      expect(error2.errorMessages.length, 1);
      expect(error2.errorMessages[0], 'Password does not match');
    });
  });
}
