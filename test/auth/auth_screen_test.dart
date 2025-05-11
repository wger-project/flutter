/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/screens/auth_screen.dart';

import 'auth_screen_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  /// Replacement for SharedPreferences.setMockInitialValues()
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

  late AuthProvider authProvider;
  late MockClient mockClient;

  final Uri tRegistration = Uri(
    scheme: 'https',
    host: 'wger.de',
    path: 'api/v2/register/',
  );

  final Uri tLogin = Uri(
    scheme: 'https',
    host: 'wger.de',
    path: 'api/v2/login/',
  );
  final Uri tProfileCheck = Uri(
    scheme: 'https',
    host: 'wger.de',
    path: 'api/v2/userprofile/',
  );
  final responseLoginOk = {'token': '1234567890abcdef1234567890abcdef12345678'};

  final responseRegistrationOk = {
    'message': 'api user successfully registered',
    'token': '1234567890abcdef1234567890abcdef12345678',
  };

  MultiProvider getWidget() {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (ctx) => authProvider)],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: AuthScreen(),
        ),
      ),
    );
  }

  setUp(() {
    mockClient = MockClient();
    authProvider = AuthProvider(mockClient);
    authProvider.serverUrl = 'https://wger.de';

    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'wger',
      packageName: 'com.example.example',
      version: '1.2.3',
      buildNumber: '2',
      buildSignature: 'buildSignature',
    );

    when(mockClient.post(
      tLogin,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) => Future(() => Response(json.encode(responseLoginOk), 200)));

    when(mockClient.get(any)).thenAnswer((_) => Future(() => Response('"1.2.3.4"', 200)));
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) => Future(() => Response('"1.2.3.4"', 200)));

    when(mockClient.post(
      tRegistration,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) => Future(() => Response(json.encode(responseRegistrationOk), 201)));
  });

  group('Login mode', () {
    testWidgets('Login smoke test', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(getWidget());

      // Assert
      expect(find.text('wger'), findsOneWidget);

      expect(find.textContaining("Don't have an account?"), findsOneWidget);
      expect(find.textContaining('Already have an account?'), findsNothing);

      expect(find.byKey(const Key('inputUsername')), findsOneWidget);
      expect(find.byKey(const Key('inputEmail')), findsNothing);
      expect(find.byKey(const Key('inputPassword')), findsOneWidget);
      expect(find.byKey(const Key('inputServer')), findsNothing);
      expect(find.byKey(const Key('inputPassword2')), findsNothing);
      expect(find.byKey(const Key('actionButton')), findsOneWidget);
      expect(find.byKey(const Key('toggleActionButton')), findsOneWidget);
      expect(find.byKey(const Key('toggleCustomServerButton')), findsOneWidget);
      expect(find.byKey(const ValueKey('toggleApiTokenButton')), findsNothing);
    });

    testWidgets('Login - with username & password - happy path', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(getWidget());

      // Act
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const ValueKey('inputApiToken')), findsNothing);
      expect(find.textContaining('An Error Occurred'), findsNothing);
      verify(mockClient.get(any));
      verify(mockClient.post(
        tLogin,
        headers: anyNamed('headers'),
        body: json.encode({'username': 'testuser', 'password': '123456789'}),
      ));
    });

    testWidgets('Login - wrong username & password', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      final response = {
        'non_field_errors': ['Username or password unknown'],
      };
      when(mockClient.post(
        tLogin,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) => Future(() => Response(json.encode(response), 400)));

      await tester.pumpWidget(getWidget());

      // Act
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Non field errors'), findsOne);
      expect(find.textContaining('Username or password unknown'), findsOne);
      verify(mockClient.post(
        tLogin,
        headers: anyNamed('headers'),
        body: json.encode({'username': 'testuser', 'password': '123456789'}),
      ));
    });

    testWidgets('Login - with API token - happy path', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(getWidget());

      // Act
      await tester.tap(find.byKey(const ValueKey('toggleCustomServerButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('toggleApiTokenButton')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('inputApiToken')),
        '1234567890abcdef1234567890abcdef12345678',
      );
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const ValueKey('inputApiToken')), findsOne);
      expect(find.byKey(const Key('inputUsername')), findsNothing);
      expect(find.byKey(const Key('inputPassword')), findsNothing);
      expect(find.textContaining('An Error Occurred'), findsNothing);

      verify(mockClient.get(
        tProfileCheck,
        headers: argThat(
          predicate((headers) =>
              headers is Map<String, String> &&
              headers['authorization'] == 'Token 1234567890abcdef1234567890abcdef12345678'),
          named: 'headers',
        ),
      ));
      verifyNever(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ));
    });

    testWidgets('Login - with API token - wrong key', (WidgetTester tester) async {
      // Arrange
      final response = {
        'detail': ['Invalid token'],
      };
      when(mockClient.get(tProfileCheck, headers: anyNamed('headers')))
          .thenAnswer((_) => Future(() => Response(json.encode(response), 400)));
      await tester.pumpWidget(getWidget());

      // Act
      await tester.tap(find.byKey(const ValueKey('toggleCustomServerButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('toggleApiTokenButton')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('inputApiToken')),
        '31e2ea0322c07b9df583a9b6d1e794f7139e78d4',
      );
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Detail'), findsOne);
      expect(find.textContaining('Invalid token'), findsOne);
      verify(mockClient.get(
        tProfileCheck,
        headers: argThat(
          predicate((headers) =>
              headers is Map<String, String> &&
              headers['authorization'] == 'Token 31e2ea0322c07b9df583a9b6d1e794f7139e78d4'),
          named: 'headers',
        ),
      ));
      verifyNever(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ));
    });
  });

  group('Registration mode', () {
    testWidgets('Registration smoke test', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());

      // Act
      await tester.tap(find.byKey(const Key('toggleActionButton')));
      await tester.pump();

      // Assert
      expect(find.textContaining("Don't have an account?"), findsNothing);
      expect(find.textContaining('Already have an account?'), findsOneWidget);

      expect(find.byKey(const Key('inputUsername')), findsOneWidget);
      expect(find.byKey(const Key('inputEmail')), findsOneWidget);
      expect(find.byKey(const Key('inputPassword')), findsOneWidget);
      expect(find.byKey(const Key('inputServer')), findsNothing);
      expect(find.byKey(const Key('inputPassword2')), findsOneWidget);
      expect(find.byKey(const Key('actionButton')), findsOneWidget);
      expect(find.byKey(const Key('toggleActionButton')), findsOneWidget);

      // Act - show custom server
      await tester.tap(find.byKey(const Key('toggleCustomServerButton')));
      await tester.pump();
      expect(find.byKey(const Key('inputServer')), findsOneWidget);
    });

    testWidgets('Registration - happy path', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());

      // Act
      await tester.tap(find.byKey(const Key('toggleActionButton')));
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.enterText(find.byKey(const Key('inputPassword2')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('An Error Occurred'), findsNothing);
      verify(mockClient.post(
        tRegistration,
        headers: anyNamed('headers'),
        body: json.encode({'username': 'testuser', 'password': '123456789'}),
      ));
    });

    testWidgets('Registration - password problems', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      final response = {
        'username': ['This field must be unique.'],
        'password': [
          'This password is too common.',
          'This password is entirely numeric.',
        ],
      };

      when(mockClient.post(
        tRegistration,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) => Future(() => Response(json.encode(response), 400)));
      await tester.pumpWidget(getWidget());

      // Act
      await tester.tap(find.byKey(const Key('toggleActionButton')));
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.enterText(find.byKey(const Key('inputPassword2')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('This password is too common'), findsOne);
      expect(find.textContaining('This password is entirely numeric'), findsOne);
      expect(find.textContaining('This field must be unique'), findsOne);

      verify(mockClient.post(
        tRegistration,
        headers: anyNamed('headers'),
        body: json.encode({'username': 'testuser', 'password': '123456789'}),
      ));
    });
  });
}
