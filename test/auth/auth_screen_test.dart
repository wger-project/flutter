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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/screens/auth_screen.dart';

import 'auth_screen_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
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

  final responseLoginOk = {'token': 'b01c44d3e3e016a615d2f82b16d31f8b924fb936'};

  final responseRegistrationOk = {
    'message': 'api user successfully registered',
    'token': 'b01c44d3e3e016a615d2f82b16d31f8b924fb936'
  };

  MultiProvider getWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => authProvider),
      ],
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
    authProvider = AuthProvider(mockClient, false);
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
    });

    testWidgets('Tests the login - happy path', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(getWidget());

      // Act
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('An Error Occurred'), findsNothing);
      verify(mockClient.get(any));
      verify(mockClient.post(
        tLogin,
        headers: anyNamed('headers'),
        body: json.encode({'username': 'testuser', 'password': '123456789'}),
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

    testWidgets('Tests the registration - happy path', (WidgetTester tester) async {
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

    testWidgets('Tests the registration - password problems', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      final response = {
        'username': [
          'This field must be unique.',
        ],
        'password': [
          'This password is too common.',
          'This password is entirely numeric.',
        ]
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
      expect(find.textContaining('An Error Occurred'), findsOne);
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
