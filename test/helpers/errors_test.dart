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

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
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

  group('buildGithubIssueUrl', () {
    test('Encodes the title and pre-fills the description', () {
      final url = buildGithubIssueUrl(
        issueTitle: 'An error occurred',
        issueErrorMessage: 'Something broke',
        stackTrace: '#0 main (file.dart:1)',
        applicationLogs: ['log line 1', 'log line 2'],
      );

      expect(url, startsWith(GITHUB_ISSUES_BUG_URL));
      expect(url, contains('&title=An%20error%20occurred'));
      expect(url.length, lessThanOrEqualTo(GITHUB_ISSUES_MAX_URL_LENGTH));

      final description = Uri.parse(url).queryParameters['description']!;
      expect(description, contains('Error message: Something broke'));
      expect(description, contains('#0 main (file.dart:1)'));
      expect(description, contains('log line 1'));
    });

    test('Drops the oldest log entries, keeps the newest', () {
      // Logs come newest-first, so index 0 is the most recent entry.
      final logs = List.generate(3000, (i) => 'log entry $i');

      final url = buildGithubIssueUrl(
        issueTitle: 'Application Error',
        issueErrorMessage: 'boom',
        stackTrace: 'short trace',
        applicationLogs: logs,
      );

      expect(url.length, lessThanOrEqualTo(GITHUB_ISSUES_MAX_URL_LENGTH));
      final description = Uri.parse(url).queryParameters['description']!;
      expect(description, contains('log entry 0\n')); // newest kept
      expect(description, isNot(contains('log entry 2999'))); // oldest dropped
    });

    test('Keeps the full stack trace and drops logs instead', () {
      final longTrace = List.generate(
        80,
        (i) => '#$i SomeClass.someMethod (package:wger/some/file.dart:$i:11)',
      ).join('\n');

      final url = buildGithubIssueUrl(
        issueTitle: 'Application Error',
        issueErrorMessage: 'boom',
        stackTrace: longTrace,
        applicationLogs: List.generate(3000, (i) => 'log entry number $i'),
      );

      expect(url.length, lessThanOrEqualTo(GITHUB_ISSUES_MAX_URL_LENGTH));
      final description = Uri.parse(url).queryParameters['description']!;
      // The stack trace is never trimmed: first and last frame survive.
      expect(description, contains('#0 SomeClass.someMethod'));
      expect(description, contains('#79 SomeClass.someMethod'));
    });
  });

  group('classifyError', () {
    test('Connectivity errors are transient', () {
      expect(
        classifyError(const SocketException('no route to host')),
        ErrorSeverity.transient,
      );
      expect(
        classifyError(http.ClientException('connection refused')),
        ErrorSeverity.transient,
      );
      expect(classifyError(TimeoutException('request timed out')), ErrorSeverity.transient);
    });

    test('Network image and layout overflow errors are cosmetic', () {
      expect(
        classifyError(
          NetworkImageLoadException(statusCode: 404, uri: Uri.parse('https://x/y.png')),
        ),
        ErrorSeverity.cosmetic,
      );
      expect(
        classifyError(FlutterError('A RenderFlex overflowed by 99 pixels on the right.')),
        ErrorSeverity.cosmetic,
      );
      // extended_image throws a plain StateError for a failed image load.
      expect(
        classifyError(StateError('Failed to load https://x/y.jpg.')),
        ErrorSeverity.cosmetic,
      );
    });

    test('Other errors are fatal', () {
      expect(classifyError(WgerHttpException.fromMap({'detail': 'invalid'})), ErrorSeverity.fatal);
      expect(classifyError(Exception('boom')), ErrorSeverity.fatal);
      expect(classifyError(StateError('bad state')), ErrorSeverity.fatal);
      expect(classifyError(null), ErrorSeverity.fatal);
    });
  });
}
