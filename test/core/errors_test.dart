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

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/errors.dart';
import 'package:wger/core/exceptions/http_exception.dart';

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

  group('collectAppVersion', () {
    void mockPackageInfo({String? installerStore}) {
      PackageInfo.setMockInitialValues(
        appName: 'wger',
        packageName: 'de.wger.flutter',
        version: '2.1.0',
        buildNumber: '260',
        buildSignature: '',
        installerStore: installerStore,
      );
    }

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });
    });

    test('Reports version, build, platform and installer', () async {
      mockPackageInfo(installerStore: 'org.fdroid.fdroid');

      expect(
        await collectAppVersion(),
        '2.1.0+260 on android, installed by org.fdroid.fdroid',
      );
    });

    test('Omits the installer when the platform reports none', () async {
      mockPackageInfo();

      expect(await collectAppVersion(), '2.1.0+260 on android');
    });
  });

  group('buildGithubIssueUrl', () {
    test('Encodes the title and pre-fills the description', () {
      final url = buildGithubIssueUrl(
        issueTitle: 'An error occurred',
        issueErrorMessage: 'Something broke',
        stackTrace: '#0 main (file.dart:1)',
        applicationLogs: ['log line 1', 'log line 2'],
        appVersion: '2.1.0+260 on android',
        serverVersion: '2.7.0',
      );

      expect(url, startsWith(GITHUB_ISSUES_BUG_URL));
      expect(url, contains('&title=An%20error%20occurred'));
      expect(url.length, lessThanOrEqualTo(GITHUB_ISSUES_MAX_URL_LENGTH));

      // The template renders these as its own fields, not in the description
      final query = Uri.parse(url).queryParameters;
      expect(query['app-version'], '2.1.0+260 on android');
      expect(query['server-version'], '2.7.0');

      final description = Uri.parse(url).queryParameters['description']!;
      expect(description, contains('Error message: Something broke'));
      expect(description, contains('#0 main (file.dart:1)'));
      expect(description, contains('log line 1'));
    });

    test('Builds a user-initiated report without error sections', () {
      final url = buildGithubIssueUrl(
        applicationLogs: ['log line'],
        syncDiagnostics: 'connected: true',
      );

      expect(url, startsWith(GITHUB_ISSUES_BUG_URL));
      expect(url, isNot(contains('&title=')));
      expect(url, isNot(contains('&app-version=')));
      expect(url, isNot(contains('&server-version=')));
      final description = Uri.parse(url).queryParameters['description']!;
      expect(description, contains('[Please describe the problem you are seeing.]'));
      expect(description, isNot(contains('Error details')));
      expect(description, contains('Sync status:'));
      expect(description, contains('log line'));
    });

    test('Includes the sync status section when diagnostics are passed', () {
      final url = buildGithubIssueUrl(
        issueTitle: 'Sync error',
        issueErrorMessage: 'boom',
        applicationLogs: ['log line'],
        syncDiagnostics: 'connected: false\npending uploads: 3',
      );

      final description = Uri.parse(url).queryParameters['description']!;
      expect(description, contains('Sync status:'));
      expect(description, contains('pending uploads: 3'));
      // No stack trace was passed, so the section is omitted entirely
      expect(description, isNot(contains('Stack trace:')));
    });

    test('Keeps the sync status section and drops logs instead', () {
      final url = buildGithubIssueUrl(
        issueTitle: 'Sync error',
        issueErrorMessage: 'boom',
        applicationLogs: List.generate(3000, (i) => 'log entry number $i'),
        syncDiagnostics: 'connected: false\npending uploads: 3',
      );

      expect(url.length, lessThanOrEqualTo(GITHUB_ISSUES_MAX_URL_LENGTH));
      final description = Uri.parse(url).queryParameters['description']!;
      expect(description, contains('pending uploads: 3'));
      expect(description, isNot(contains('log entry number 2999')));
    });

    test('Omits the sync status section without diagnostics', () {
      final url = buildGithubIssueUrl(
        issueTitle: 'An error occurred',
        issueErrorMessage: 'boom',
        stackTrace: 'trace',
        applicationLogs: ['log line'],
      );

      final description = Uri.parse(url).queryParameters['description']!;
      expect(description, isNot(contains('Sync status:')));
      expect(description, contains('Stack trace:'));
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

    test('Drops logs first, then trims the stack trace from the bottom', () {
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
      // The trace alone exceeds the limit here, so the logs are gone and
      // the outermost frames were dropped; the top of the trace survives.
      expect(description, contains('#0 SomeClass.someMethod'));
      expect(description, isNot(contains('#79 SomeClass.someMethod')));
      expect(description, isNot(contains('log entry number')));
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

  group('serverWithLocalFallback', () {
    final logger = Logger('test');

    test('online: returns the server result without touching local', () async {
      var localCalls = 0;
      final result = await serverWithLocalFallback(
        isOnline: true,
        server: () async => 'server',
        local: () {
          localCalls++;
          return 'local';
        },
        logger: logger,
        fallbackLog: 'falling back',
      );

      expect(result, 'server');
      expect(localCalls, 0);
    });

    test('offline: skips the server attempt entirely', () async {
      var serverCalls = 0;
      final result = await serverWithLocalFallback(
        isOnline: false,
        server: () async {
          serverCalls++;
          return 'server';
        },
        local: () => 'local',
        logger: logger,
        fallbackLog: 'falling back',
      );

      expect(result, 'local');
      expect(serverCalls, 0);
    });

    test('online: a network error falls back to local', () async {
      final result = await serverWithLocalFallback(
        isOnline: true,
        server: () async => throw const SocketException('no route to host'),
        local: () => 'local',
        logger: logger,
        fallbackLog: 'falling back',
      );

      expect(result, 'local');
    });

    test('online: an error that is not about the network rethrows', () async {
      await expectLater(
        serverWithLocalFallback<String>(
          isOnline: true,
          server: () async => throw StateError('broken'),
          local: () => 'local',
          logger: logger,
          fallbackLog: 'falling back',
        ),
        throwsStateError,
      );
    });
  });
}
