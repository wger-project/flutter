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
