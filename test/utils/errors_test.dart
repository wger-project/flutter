import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/errors.dart';

void main() {
  group('extractErrors', () {
    testWidgets('Returns empty list when errors is null', (WidgetTester tester) async {
      final result = extractErrors(null);
      expect(result, isEmpty);
    });

    testWidgets('Returns empty list when errors is empty', (WidgetTester tester) async {
      final result = extractErrors({});
      expect(result, isEmpty);
    });

    testWidgets('Processes string values correctly', (WidgetTester tester) async {
      // Arrange
      final errors = {'error': 'Something went wrong'};

      // Act
      final widgets = extractErrors(errors);

      // Assert
      expect(widgets.length, 3, reason: 'Expected 3 widgets: header, message, and spacing');

      final headerWidget = widgets[0] as Text;
      expect(headerWidget.data, 'Error');

      final messageWidget = widgets[1] as Text;
      expect(messageWidget.data, 'Something went wrong');
      expect(widgets[2] is SizedBox, true);
    });

    testWidgets('Processes list values correctly', (WidgetTester tester) async {
      // Arrange
      final errors = {
        'validation_error': ['Error 1', 'Error 2'],
      };

      // Act
      final widgets = extractErrors(errors);

      // Assert
      expect(widgets.length, 4);

      final headerWidget = widgets[0] as Text;
      expect(headerWidget.data, 'Validation error');

      final messageWidget1 = widgets[1] as Text;
      expect(messageWidget1.data, 'Error 1');

      final messageWidget2 = widgets[2] as Text;
      expect(messageWidget2.data, 'Error 2');
    });

    testWidgets('Processes multiple error types correctly', (WidgetTester tester) async {
      // Arrange
      final errors = {
        'username': ['Username is too boring', 'Username is too short'],
        'password': 'Password does not match',
      };

      // Act
      final widgets = extractErrors(errors);

      // Assert
      expect(widgets.length, 7);

      final textWidgets = widgets.whereType<Text>().toList();
      expect(textWidgets.map((w) => w.data).contains('Username'), true);
      expect(textWidgets.map((w) => w.data).contains('Password'), true);
      expect(textWidgets.map((w) => w.data).contains('Username is too boring'), true);
      expect(textWidgets.map((w) => w.data).contains('Username is too short'), true);
      expect(textWidgets.map((w) => w.data).contains('Password does not match'), true);

      final spacers = widgets.whereType<SizedBox>().toList();
      expect(spacers.length, 2);
    });
  });
}
