/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/secure_token_storage.dart';
import 'package:wger/screens/auth_screen.dart';

import '../fake_connectivity.dart';
import 'auth_screen_test.mocks.dart';

/// Captures `launchUrl(...)` calls so the web-handoff test can inspect the
/// URL the app would hand off to the system browser, without actually
/// opening one.
class _FakeUrlLauncher extends Fake with MockPlatformInterfaceMixin implements UrlLauncherPlatform {
  String? launchedUrl;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    return true;
  }
}

@GenerateMocks([http.Client, SecureTokenStorage])
void main() {
  // The auth screen watches networkStatusProvider to gate the action button.
  // Stub connectivity so that probe is deterministic.
  installFakeConnectivity();

  late MockClient mockClient;
  late MockSecureTokenStorage mockSecureStorage;

  final Uri tHeadlessLogin = Uri(
    scheme: 'https',
    host: 'wger.de',
    path: '/allauth/app/v1/auth/login',
  );
  final Uri tHeadlessSignup = Uri(
    scheme: 'https',
    host: 'wger.de',
    path: '/allauth/app/v1/auth/signup',
  );
  final Uri tHeadlessRefresh = Uri(
    scheme: 'https',
    host: 'wger.de',
    path: '/allauth/app/v1/tokens/refresh',
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

    // Default: online. The offline test overrides this.
    reachabilityCheck = (_, _, _) async => true;

    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
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

      expect(find.textContaining('New to wger?'), findsOneWidget);
      expect(find.textContaining('Already have an account?'), findsNothing);

      expect(find.byKey(const Key('inputUsername')), findsOneWidget);
      expect(find.byKey(const Key('inputEmail')), findsNothing);
      expect(find.byKey(const Key('inputPassword')), findsOneWidget);
      expect(find.byKey(const Key('inputServer')), findsNothing);
      expect(find.byKey(const Key('inputPassword2')), findsNothing);
      expect(find.byKey(const Key('actionButton')), findsOneWidget);
      expect(find.byKey(const Key('toggleActionButton')), findsOneWidget);
      expect(find.byKey(const Key('advancedButton')), findsOneWidget);
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

    testWidgets('Login - short password is accepted (no min-length block)', (
      WidgetTester tester,
    ) async {
      // Regression (bug #1): the login form must not enforce a minimum
      // password length, otherwise existing accounts with shorter passwords
      // are locked out.
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), 'short');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert: the form submitted instead of blocking on a length validator.
      expect(find.text('The password is too short'), findsNothing);
      verify(
        mockClient.post(
          tHeadlessLogin,
          headers: anyNamed('headers'),
          body: json.encode({'username': 'testuser', 'password': 'short'}),
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

    testWidgets('Login - server unreachable shows a friendly message', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      // Regression (bug #2): a network error during login must surface as a
      // message, not crash through to the red error screen.
      when(
        mockClient.post(
          tHeadlessLogin,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenThrow(http.ClientException('SocketException: Connection refused'));

      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text("Couldn't connect to server"), findsOneWidget);
      expect(tester.takeException(), isNull);
      verify(
        mockClient.post(
          tHeadlessLogin,
          headers: anyNamed('headers'),
          body: json.encode({'username': 'testuser', 'password': '123456789'}),
        ),
      );
    });

    testWidgets('Login button is disabled when offline', (WidgetTester tester) async {
      // Arrange: no connectivity.
      reachabilityCheck = (_, _, _) async => false;
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Assert: the action button cannot be tapped.
      final button = tester.widget<ElevatedButton>(find.byKey(const Key('actionButton')));
      expect(button.onPressed, isNull);
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
      await tester.tap(find.byKey(const Key('advancedButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Refresh token'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('advancedDoneButton')));
      await tester.pumpAndSettle();
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
      await tester.tap(find.byKey(const Key('advancedButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Refresh token'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('advancedDoneButton')));
      await tester.pumpAndSettle();
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

    testWidgets('Login - custom server URL is used and trailing slash trimmed', (
      WidgetTester tester,
    ) async {
      // A custom server URL with a trailing slash must be trimmed before the
      // request is built, otherwise makeHeadlessUri produces a double slash.
      // The login is stubbed to fail, so nothing is persisted and only the
      // request URL is under test.
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      final tHeadlessLoginCustom = Uri(
        scheme: 'https',
        host: 'my.server',
        path: '/allauth/app/v1/auth/login',
      );
      when(
        mockClient.post(
          tHeadlessLoginCustom,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) => Future(() => Response(json.encode({'detail': 'nope'}), 400)));

      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const Key('advancedButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Self-hosted'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('inputServer')), 'https://my.server/');
      await tester.tap(find.byKey(const Key('advancedDoneButton')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert: the request hit the trimmed custom host, not the default.
      verify(
        mockClient.post(
          tHeadlessLoginCustom,
          headers: anyNamed('headers'),
          body: json.encode({'username': 'testuser', 'password': '123456789'}),
        ),
      );
      verifyNever(
        mockClient.post(tHeadlessLogin, headers: anyNamed('headers'), body: anyNamed('body')),
      );
    });

    testWidgets('Login - server misconfiguration shows a warning dialog', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      // The config check only runs once login fully reaches loggedIn, so the
      // version and PowerSync probes must all report a healthy server.
      when(
        mockClient.get(Uri.parse('https://wger.de/api/v2/version/')),
      ).thenAnswer((_) => Future(() => Response('"99.99.99"', 200)));
      when(
        mockClient.get(Uri.parse('https://wger.de/api/v2/min-app-version/')),
      ).thenAnswer((_) => Future(() => Response('"0.0.1"', 200)));
      when(
        mockClient.get(
          Uri.parse('https://wger.de/api/v2/powersync-token'),
          headers: anyNamed('headers'),
        ),
      ).thenAnswer(
        (_) => Future(
          () => Response(
            json.encode({'token': 'ps-jwt', 'powersync_url': 'https://ps.example/'}),
            200,
          ),
        ),
      );
      when(
        mockClient.get(Uri.parse('https://ps.example/probes/liveness')),
      ).thenAnswer((_) => Future(() => Response('OK', 200)));
      // _serverConfigSane fetches the exercise list; a `next` URL on a
      // different host than the server flags a reverse-proxy misconfiguration.
      when(
        mockClient.get(
          Uri.parse('https://wger.de/api/v2/exercise/?limit=1'),
          headers: anyNamed('headers'),
        ),
      ).thenAnswer(
        (_) => Future(
          () => Response(
            json.encode({'next': 'https://internal.host/api/v2/exercise/?limit=1&offset=1'}),
            200,
          ),
        ),
      );

      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Server Configuration Issue'), findsOneWidget);
    });

    testWidgets('Sheet round-trip: Self-hosted → default server', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('advancedButton')));
      await tester.pumpAndSettle();

      // Self-hosted → server field appears in the sheet.
      await tester.tap(find.text('Self-hosted'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('inputServer')), findsOneWidget);

      // Back to wger.de → server field disappears again.
      await tester.tap(find.text('wger.de'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('inputServer')), findsNothing);
    });

    testWidgets('Sheet round-trip: Refresh token → Username & password', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Refresh token → close → main screen shows JWT field.
      await tester.tap(find.byKey(const Key('advancedButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Refresh token'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('advancedDoneButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('inputRefreshToken')), findsOneWidget);
      expect(find.byKey(const Key('inputUsername')), findsNothing);

      // Re-open sheet, pick Username & password → close → username/password
      // visible again, JWT field gone.
      await tester.tap(find.byKey(const Key('advancedButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Username and password'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('advancedDoneButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('inputRefreshToken')), findsNothing);
      expect(find.byKey(const Key('inputUsername')), findsOneWidget);
      expect(find.byKey(const Key('inputPassword')), findsOneWidget);
    });

    testWidgets('Web handoff link launches app-auth URL with state in prefs', (
      WidgetTester tester,
    ) async {
      // Intercept url_launcher so no real browser opens.
      final original = UrlLauncherPlatform.instance;
      final fake = _FakeUrlLauncher();
      UrlLauncherPlatform.instance = fake;
      addTearDown(() => UrlLauncherPlatform.instance = original);

      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('loginViaWebButton')));
      await tester.pumpAndSettle();

      // The handoff URL points at the configured server's app-auth page and
      // carries a non-empty state nonce. State persistence to prefs is
      // covered by issueAppAuthState's own tests in app_link_router_test.
      expect(fake.launchedUrl, isNotNull);
      final launched = Uri.parse(fake.launchedUrl!);
      expect(launched.scheme, 'https');
      expect(launched.host, 'wger.de');
      expect(launched.path, '/user/app-auth/');
      final state = launched.queryParameters['state'];
      expect(state, isNotNull);
      expect(state, isNotEmpty);
    });

    testWidgets('Advanced footer shows indicator suffix for custom server', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // No indicator while on the default server.
      expect(find.textContaining('my.example.com'), findsNothing);

      // Pick Self-hosted with a custom URL.
      await tester.tap(find.byKey(const Key('advancedButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Self-hosted'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('inputServer')),
        'https://my.example.com',
      );
      await tester.tap(find.byKey(const Key('advancedDoneButton')));
      await tester.pumpAndSettle();

      // Footer now carries the scheme-stripped suffix.
      expect(find.text('· my.example.com'), findsOneWidget);

      // Reset to wger.de → suffix gone again.
      await tester.tap(find.byKey(const Key('advancedButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('wger.de'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('advancedDoneButton')));
      await tester.pumpAndSettle();
      expect(find.textContaining('my.example.com'), findsNothing);
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
      expect(find.textContaining('New to wger?'), findsNothing);
      expect(find.textContaining('Already have an account?'), findsOneWidget);

      expect(find.byKey(const Key('inputUsername')), findsOneWidget);
      expect(find.byKey(const Key('inputEmail')), findsOneWidget);
      expect(find.byKey(const Key('inputPassword')), findsOneWidget);
      expect(find.byKey(const Key('inputServer')), findsNothing);
      expect(find.byKey(const Key('inputPassword2')), findsOneWidget);
      expect(find.byKey(const Key('actionButton')), findsOneWidget);
      expect(find.byKey(const Key('toggleActionButton')), findsOneWidget);

      // Act - show advanced sheet, pick self-hosted, server field appears
      await tester.tap(find.byKey(const Key('advancedButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Self-hosted'));
      await tester.pumpAndSettle();
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

    testWidgets('Registration - short password is rejected', (WidgetTester tester) async {
      // Regression (bug #1): the registration form enforces a minimum
      // password length and must block before submitting.
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const Key('toggleActionButton')));
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), 'short');
      await tester.enterText(find.byKey(const Key('inputPassword2')), 'short');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert: the length validator blocks and signup is never hit.
      expect(find.text('The password is too short'), findsOneWidget);
      verifyNever(
        mockClient.post(tHeadlessSignup, headers: anyNamed('headers'), body: anyNamed('body')),
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

    testWidgets('Registration - mismatched confirm password is rejected', (
      WidgetTester tester,
    ) async {
      // The ConfirmPasswordField validator must block submit when the two
      // password entries differ.
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const Key('toggleActionButton')));
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.enterText(find.byKey(const Key('inputPassword2')), '987654321');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert: the mismatch validator blocks and signup is never hit.
      expect(find.text("The passwords don't match"), findsOneWidget);
      verifyNever(
        mockClient.post(tHeadlessSignup, headers: anyNamed('headers'), body: anyNamed('body')),
      );
    });

    testWidgets('Registration - empty form blocks submit', (WidgetTester tester) async {
      // Tapping the action button with empty fields must trip the validators
      // and never reach the network.
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const Key('toggleActionButton')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid username'), findsOneWidget);
      verifyNever(
        mockClient.post(tHeadlessSignup, headers: anyNamed('headers'), body: anyNamed('body')),
      );
    });

    testWidgets('Registration - invalid email is rejected', (WidgetTester tester) async {
      // A non-empty email without an '@' must trip the email validator.
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byKey(const Key('toggleActionButton')));
      await tester.enterText(find.byKey(const Key('inputUsername')), 'testuser');
      await tester.enterText(find.byKey(const Key('inputEmail')), 'notanemail');
      await tester.enterText(find.byKey(const Key('inputPassword')), '123456789');
      await tester.enterText(find.byKey(const Key('inputPassword2')), '123456789');
      await tester.tap(find.byKey(const Key('actionButton')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid e-mail address'), findsOneWidget);
      verifyNever(
        mockClient.post(tHeadlessSignup, headers: anyNamed('headers'), body: anyNamed('body')),
      );
    });

    testWidgets('Mode switch round-trip: login → register → login', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(getWidget());
      await tester.pumpAndSettle();

      // Login → register.
      await tester.tap(find.byKey(const Key('toggleActionButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('inputEmail')), findsOneWidget);
      expect(find.byKey(const Key('inputPassword2')), findsOneWidget);
      expect(find.textContaining('Already have an account?'), findsOneWidget);

      // Register → login.
      await tester.tap(find.byKey(const Key('toggleActionButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('inputEmail')), findsNothing);
      expect(find.byKey(const Key('inputPassword2')), findsNothing);
      expect(find.textContaining('New to wger?'), findsOneWidget);
    });
  });
}
