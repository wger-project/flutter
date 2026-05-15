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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/secure_token_storage.dart';
import 'package:wger/screens/auth_screen.dart';

import 'auth_screen_test.mocks.dart';

@GenerateMocks([http.Client, SecureTokenStorage])
void main() {
  /// Replacement for SharedPreferences.setMockInitialValues()
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

  late MockClient mockClient;
  late MockSecureTokenStorage mockSecureStorage;

  final Uri tHeadlessLogin = Uri(
    scheme: 'https',
    host: 'wger.de',
    path: '/_allauth/app/v1/auth/login',
  );
  final Uri tHeadlessSignup = Uri(
    scheme: 'https',
    host: 'wger.de',
    path: '/_allauth/app/v1/auth/signup',
  );
  final Uri tHeadlessRefresh = Uri(
    scheme: 'https',
    host: 'wger.de',
    path: '/_allauth/app/v1/tokens/refresh',
  );

  const validJwt = 'header.payload.signature';
  const otherJwt = 'header2.payload2.signature2';

  /// Headless envelope carrying a sham JWT. The signature segment is not
  /// validated client-side, so any three-dot string works.
  Map<String, dynamic> headlessAuthOk() => {
    'status': 200,
    'data': {},
    'meta': {
      'access_token': 'header.payload.signature',
      'refresh_token': 'refresh-token-${DateTime.now().microsecondsSinceEpoch}',
    },
  };

  Widget getWidget() {
    return ProviderScope(
      overrides: [
        authHttpClientProvider.overrideWithValue(mockClient),
        secureTokenStorageProvider.overrideWithValue(mockSecureStorage),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: AuthScreen(),
      ),
    );
  }

  setUp(() {
    mockClient = MockClient();
    mockSecureStorage = MockSecureTokenStorage();
    when(mockSecureStorage.deleteRefreshToken()).thenAnswer((_) async {});
    when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => null);
    when(mockSecureStorage.writeRefreshToken(any)).thenAnswer((_) async {});

    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'wger',
      packageName: 'com.example.example',
      version: '1.2.3',
      buildNumber: '2',
      buildSignature: 'buildSignature',
    );

    // Happy-path stubs for the headless login / signup endpoints; tests
    // that exercise error responses override these as needed.
    when(
      mockClient.post(
        tHeadlessLogin,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((_) => Future(() => Response(json.encode(headlessAuthOk()), 200)));
    when(
      mockClient.post(
        tHeadlessSignup,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((_) => Future(() => Response(json.encode(headlessAuthOk()), 200)));

    when(mockClient.get(any)).thenAnswer((_) => Future(() => Response('"1.2.3.4"', 200)));
    when(
      mockClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) => Future(() => Response('"1.2.3.4"', 200)));
  });

  group('Login mode', () {
    testWidgets('Login smoke test', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

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
      expect(find.byKey(const ValueKey('toggleRefreshTokenButton')), findsNothing);
    });

    testWidgets('Login - with username & password - happy path', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(const ValueKey('inputRefreshToken')), findsNothing);
      expect(find.textContaining('An Error Occurred'), findsNothing);
      verify(mockClient.get(any));
      verify(
        mockClient.post(
          tHeadlessLogin,
          headers: anyNamed('headers'),
          body: json.encode({'username': 'testuser', 'password': '123456789'}),
        ),
      );
    });

    testWidgets('Login - wrong username & password', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      final response = {
        'non_field_errors': ['Username or password unknown'],
      };
      when(
        mockClient.post(
          tHeadlessLogin,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) => Future(() => Response(json.encode(response), 400)));

      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Non field errors'), findsOne);
      expect(find.textContaining('Username or password unknown'), findsOne);
      verify(
        mockClient.post(
          tHeadlessLogin,
          headers: anyNamed('headers'),
          body: json.encode({'username': 'testuser', 'password': '123456789'}),
        ),
      );
    });

    testWidgets('Login - with refresh token - happy path', (WidgetTester tester) async {
      // Arrange: stub tokens/refresh to return a rotated bundle.
      when(
        mockClient.post(tHeadlessRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) => Future(
          () => Response(
            json.encode({
              'status': 200,
              'data': {'access_token': otherJwt, 'refresh_token': 'rotated'},
              'meta': {'is_authenticated': true},
            }),
            200,
          ),
        ),
      );
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const ValueKey('toggleCustomServerButton')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('toggleRefreshTokenButton')));
      await tester.pump();
      await tester.enterText(find.byKey(const ValueKey('inputRefreshToken')), validJwt);

      // Assert that refresh-token mode is active before submitting.
      expect(find.byKey(const ValueKey('inputRefreshToken')), findsOne);
      expect(find.byKey(const Key('inputUsername')), findsNothing);
      expect(find.byKey(const Key('inputPassword')), findsNothing);

      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('An Error Occurred'), findsNothing);

      // The pasted token is sent in the body of tokens/refresh.
      final captured =
          verify(
                mockClient.post(
                  tHeadlessRefresh,
                  headers: anyNamed('headers'),
                  body: captureAnyNamed('body'),
                ),
              ).captured.single
              as String;
      expect(json.decode(captured)['refresh_token'], validJwt);
      // The username/password endpoint must not be hit.
      verifyNever(
        mockClient.post(tHeadlessLogin, headers: anyNamed('headers'), body: anyNamed('body')),
      );
    });

    testWidgets('Login - with refresh token - server rejects it', (WidgetTester tester) async {
      // Arrange
      final response = {
        'detail': ['Invalid token'],
      };
      when(
        mockClient.post(tHeadlessRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) => Future(() => Response(json.encode(response), 401)));
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const ValueKey('toggleCustomServerButton')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('toggleRefreshTokenButton')));
      await tester.pump();
      await tester.enterText(find.byKey(const ValueKey('inputRefreshToken')), validJwt);
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Detail'), findsOne);
      expect(find.textContaining('Invalid token'), findsOne);
      verify(
        mockClient.post(
          tHeadlessRefresh,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      );
      // The username/password endpoint must not be hit.
      verifyNever(
        mockClient.post(tHeadlessLogin, headers: anyNamed('headers'), body: anyNamed('body')),
      );
    });
  });

  group('Registration mode', () {
    testWidgets('Registration smoke test', (WidgetTester tester) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const Key('toggleActionButton')));
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.enterText(find.byKey(const Key('inputPassword2')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('An Error Occurred'), findsNothing);
      verify(
        mockClient.post(
          tHeadlessSignup,
          headers: anyNamed('headers'),
          body: json.encode({'username': 'testuser', 'password': '123456789'}),
        ),
      );
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

      when(
        mockClient.post(
          tHeadlessSignup,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) => Future(() => Response(json.encode(response), 400)));
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

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

      verify(
        mockClient.post(
          tHeadlessSignup,
          headers: anyNamed('headers'),
          body: json.encode({'username': 'testuser', 'password': '123456789'}),
        ),
      );
    });
  });
}
