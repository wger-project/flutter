/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/core/exceptions/mfa_required_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/auth_state.dart';
import 'package:wger/providers/secure_token_storage.dart';

import 'auth_notifier_login_test.mocks.dart';

@GenerateMocks([http.Client, SecureTokenStorage])
void main() {
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

  late MockClient mockClient;
  late MockSecureTokenStorage mockSecureStorage;

  const serverUrl = 'https://wger.example';
  const username = 'alice';
  const password = 'hunter2';
  const powerSyncUrl = 'https://ps.example/';

  final tHeadlessLogin = Uri.parse('$serverUrl/_allauth/app/v1/auth/login');
  final tHeadlessSignup = Uri.parse('$serverUrl/_allauth/app/v1/auth/signup');
  final tVersion = Uri.parse('$serverUrl/api/v2/version/');
  final tMinAppVersion = Uri.parse('$serverUrl/api/v2/min-app-version/');
  final tPowerSyncToken = Uri.parse('$serverUrl/api/v2/powersync-token');
  final tLiveness = Uri.parse('${powerSyncUrl}probes/liveness');

  /// Builds a JWT-shaped string with the given payload. Signature is a sham,
  /// we only decode the middle segment.
  String makeJwt(Map<String, dynamic> payload) {
    String enc(Map<String, dynamic> m) =>
        base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
    return '${enc({'alg': 'HS256', 'typ': 'JWT'})}.${enc(payload)}.signature';
  }

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [
        authHttpClientProvider.overrideWithValue(mockClient),
        secureTokenStorageProvider.overrideWithValue(mockSecureStorage),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
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
    await PreferenceHelper.asyncPref.clear();

    // Default gating-chain mocks (happy path). Login-flow tests override
    // only what they care about.
    when(mockClient.get(tVersion)).thenAnswer((_) async => Response('"99.99.99"', 200));
    when(mockClient.get(tMinAppVersion)).thenAnswer((_) async => Response('"0.0.1"', 200));
    when(
      mockClient.get(tPowerSyncToken, headers: anyNamed('headers')),
    ).thenAnswer(
      (_) async => Response(
        jsonEncode({'token': 'ps-jwt', 'powersync_url': powerSyncUrl}),
        200,
      ),
    );
    when(mockClient.get(tLiveness)).thenAnswer((_) async => Response('OK', 200));
    // _serverConfigSane probe → null `next` means clean.
    when(
      mockClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) async => Response(jsonEncode({'next': null}), 200));
    // Re-stub the explicit ones (any-match above otherwise wins).
    when(mockClient.get(tVersion)).thenAnswer((_) async => Response('"99.99.99"', 200));
    when(mockClient.get(tMinAppVersion)).thenAnswer((_) async => Response('"0.0.1"', 200));
    when(
      mockClient.get(tPowerSyncToken, headers: anyNamed('headers')),
    ).thenAnswer(
      (_) async => Response(
        jsonEncode({'token': 'ps-jwt', 'powersync_url': powerSyncUrl}),
        200,
      ),
    );
    when(mockClient.get(tLiveness)).thenAnswer((_) async => Response('OK', 200));
  });

  group('login: headless happy path', () {
    test('200 → stores headless JWT bundle, wipes legacy PREFS_USER, state has tokens', () async {
      final accessJwt = makeJwt({'sub': '7', 'exp': 1900000000});
      when(
        mockClient.post(tHeadlessLogin, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 200,
            'data': {},
            'meta': {'access_token': accessJwt, 'refresh_token': 'fresh-refresh'},
          }),
          200,
        ),
      );

      final container = makeContainer();
      // Let auto-login settle as logged-out (no PREFS_USER yet).
      await container.read(authProvider.future);

      // Seed a stale legacy blob *after* auto-login, so we can assert
      // login() wipes it on success without auto-login itself trying to
      // probe with it.
      await PreferenceHelper.asyncPref.setString(
        PREFS_USER,
        jsonEncode({'token': 'stale-legacy', 'serverUrl': serverUrl}),
      );

      final result = await container
          .read(authProvider.notifier)
          .login(username, password, serverUrl, null);

      expect(result, LoginActions.proceed);
      final state = container.read(authProvider).value!;
      expect(state.tokenType, AuthTokenType.headlessJwt);
      expect(state.accessToken, accessJwt);
      expect(state.token, isNull);
      expect(state.status, AuthStatus.loggedIn);

      // Refresh token in secure storage.
      verify(mockSecureStorage.writeRefreshToken('fresh-refresh')).called(1);

      // Headless prefs populated. The JWT subject is persisted so the next
      // login can detect a user-switch and wipe the local DB.
      final prefs = PreferenceHelper.asyncPref;
      expect(await prefs.getString(PREFS_ACCESS_TOKEN), accessJwt);
      expect(await prefs.getString(PREFS_TOKEN_TYPE), AuthTokenType.headlessJwt.name);
      expect(await prefs.getString(PREFS_SERVER_URL), serverUrl);
      expect(await prefs.getString(PREFS_USER_ID), '7');

      // Stale legacy blob wiped.
      expect(await prefs.containsKey(PREFS_USER), false);

      // No prior session, so the user-switch wipe path must not have fired.
      expect(container.read(authProvider.notifier).userSwitchWipeCount, 0);
    });

    test('Authorization is not built by the notifier itself; the auth client owns it', () async {
      final accessJwt = makeJwt({'exp': 1900000000});
      when(
        mockClient.post(tHeadlessLogin, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 200,
            'data': {},
            'meta': {'access_token': accessJwt, 'refresh_token': 'r'},
          }),
          200,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).login(username, password, serverUrl, null);

      // The headless login POST is unauthenticated (no Authorization header).
      final captured =
          verify(
                mockClient.post(
                  tHeadlessLogin,
                  headers: captureAnyNamed('headers'),
                  body: anyNamed('body'),
                ),
              ).captured.last
              as Map<String, String>;
      expect(captured.containsKey('authorization'), false);
    });
  });

  group('login: user-switch detection', () {
    /// Builds a 200 response carrying [accessJwt] and a refresh token.
    void stubLoginSuccess(String accessJwt) {
      when(
        mockClient.post(tHeadlessLogin, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 200,
            'data': {},
            'meta': {'access_token': accessJwt, 'refresh_token': 'r'},
          }),
          200,
        ),
      );
    }

    test('login as a different user wipes the local DB on completion', () async {
      // Previous session belonged to user '5'.
      await PreferenceHelper.asyncPref.setString(PREFS_USER_ID, '5');
      stubLoginSuccess(makeJwt({'sub': '7', 'exp': 1900000000}));

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).login(username, password, serverUrl, null);

      // The user-switch wipe path must have fired exactly once.
      expect(container.read(authProvider.notifier).userSwitchWipeCount, 1);
      // And the new user-id is now persisted so a future re-login can detect
      // the next switch.
      expect(await PreferenceHelper.asyncPref.getString(PREFS_USER_ID), '7');
    });

    test('same user logging back in keeps the local DB', () async {
      // Same user as the previously stored session.
      await PreferenceHelper.asyncPref.setString(PREFS_USER_ID, '7');
      stubLoginSuccess(makeJwt({'sub': '7', 'exp': 1900000000}));

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).login(username, password, serverUrl, null);

      // No user mismatch → no wipe.
      expect(container.read(authProvider.notifier).userSwitchWipeCount, 0);
      expect(await PreferenceHelper.asyncPref.getString(PREFS_USER_ID), '7');
    });

    test('first login after a clean install does not wipe (no previous user)', () async {
      // No PREFS_USER_ID at all → nothing to compare against, no wipe.
      stubLoginSuccess(makeJwt({'sub': '7', 'exp': 1900000000}));

      final container = makeContainer();
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).login(username, password, serverUrl, null);

      expect(container.read(authProvider.notifier).userSwitchWipeCount, 0);
      expect(await PreferenceHelper.asyncPref.getString(PREFS_USER_ID), '7');
    });
  });

  group('login: headless 401 / MFA detection', () {
    test(
      '401 with `meta.session_token` + `mfa_authenticate` flow → MfaRequiredException',
      () async {
        when(
          mockClient.post(tHeadlessLogin, headers: anyNamed('headers'), body: anyNamed('body')),
        ).thenAnswer(
          (_) async => Response(
            jsonEncode({
              'status': 401,
              'data': {
                'flows': [
                  {
                    'id': 'mfa_authenticate',
                    'is_pending': true,
                    'types': ['totp', 'recovery_codes'],
                  },
                ],
              },
              'meta': {'session_token': 'flow-handle-xyz', 'is_authenticated': false},
            }),
            401,
          ),
        );

        final container = makeContainer();
        await container.read(authProvider.future);

        try {
          await container.read(authProvider.notifier).login(username, password, serverUrl, null);
          fail('expected MfaRequiredException');
        } on MfaRequiredException catch (e) {
          expect(e.sessionToken, 'flow-handle-xyz');
          expect(e.availableFactors, ['totp', 'recovery_codes']);
        }
      },
    );

    test('plain 401 (no session_token) → WgerHttpException', () async {
      when(
        mockClient.post(tHeadlessLogin, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 401,
            'data': {},
            'meta': {'is_authenticated': false},
          }),
          401,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);

      expect(
        container.read(authProvider.notifier).login(username, password, serverUrl, null),
        throwsA(isA<WgerHttpException>()),
      );
    });
  });

  group('login: pasted refresh token', () {
    final tRefresh = Uri.parse('$serverUrl/_allauth/app/v1/tokens/refresh');

    test('exchanges at tokens/refresh and stores the rotated bundle', () async {
      final newAccess = makeJwt({'exp': 1900000000});
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 200,
            'data': {'access_token': newAccess, 'refresh_token': 'rotated-refresh'},
            'meta': {'is_authenticated': true},
          }),
          200,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);

      final result = await container
          .read(authProvider.notifier)
          .login('', '', serverUrl, 'pasted-refresh-token');

      expect(result, LoginActions.proceed);
      final state = container.read(authProvider).value!;
      expect(state.tokenType, AuthTokenType.headlessJwt);
      expect(state.accessToken, newAccess);

      verify(mockSecureStorage.writeRefreshToken('rotated-refresh')).called(1);
      // Must not have hit the username/password endpoint.
      verifyNever(
        mockClient.post(tHeadlessLogin, headers: anyNamed('headers'), body: anyNamed('body')),
      );
      // The pasted refresh token is sent as the body of the exchange call.
      final captured =
          verify(
                mockClient.post(
                  tRefresh,
                  headers: anyNamed('headers'),
                  body: captureAnyNamed('body'),
                ),
              ).captured.single
              as String;
      expect(jsonDecode(captured)['refresh_token'], 'pasted-refresh-token');
    });

    test('server rejection surfaces as WgerHttpException', () async {
      when(
        mockClient.post(tRefresh, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response(jsonEncode({'detail': 'invalid'}), 401));

      final container = makeContainer();
      await container.read(authProvider.future);

      expect(
        container.read(authProvider.notifier).login('', '', serverUrl, 'bad-refresh-token'),
        throwsA(isA<WgerHttpException>()),
      );
    });
  });

  group('register: headless signup', () {
    test('200 stores tokens directly without a follow-up login call', () async {
      final accessJwt = makeJwt({'exp': 1900000000});
      when(
        mockClient.post(tHeadlessSignup, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 200,
            'data': {},
            'meta': {'access_token': accessJwt, 'refresh_token': 'r'},
          }),
          200,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);

      final result = await container
          .read(authProvider.notifier)
          .register(
            username: username,
            password: password,
            email: 'alice@example.com',
            serverUrl: serverUrl,
          );

      expect(result, LoginActions.proceed);
      expect(container.read(authProvider).value!.tokenType, AuthTokenType.headlessJwt);
      verify(mockSecureStorage.writeRefreshToken('r')).called(1);
    });
  });

  group('completeMfa', () {
    final tMfa = Uri.parse('$serverUrl/_allauth/app/v1/auth/2fa/authenticate');

    test('200 persists tokens and reaches loggedIn', () async {
      final accessJwt = makeJwt({'exp': 1900000000});
      when(
        mockClient.post(tMfa, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 200,
            'data': {},
            'meta': {'access_token': accessJwt, 'refresh_token': 'mfa-refresh'},
          }),
          200,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);

      final result = await container
          .read(authProvider.notifier)
          .completeMfa(
            sessionToken: 'flow-handle-xyz',
            code: '123456',
            serverUrl: serverUrl,
          );

      expect(result, LoginActions.proceed);
      final state = container.read(authProvider).value!;
      expect(state.status, AuthStatus.loggedIn);
      expect(state.tokenType, AuthTokenType.headlessJwt);
      expect(state.accessToken, accessJwt);
      verify(mockSecureStorage.writeRefreshToken('mfa-refresh')).called(1);
    });

    test('passes the session_token as X-Session-Token header and the code in the body', () async {
      final accessJwt = makeJwt({'exp': 1900000000});
      when(
        mockClient.post(tMfa, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'status': 200,
            'data': {},
            'meta': {'access_token': accessJwt, 'refresh_token': 'r'},
          }),
          200,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);
      await container
          .read(authProvider.notifier)
          .completeMfa(
            sessionToken: 'flow-handle-xyz',
            code: '123456',
            serverUrl: serverUrl,
          );

      final captured = verify(
        mockClient.post(
          tMfa,
          headers: captureAnyNamed('headers'),
          body: captureAnyNamed('body'),
        ),
      ).captured;
      final headers = captured[0] as Map<String, String>;
      final body = jsonDecode(captured[1] as String) as Map<String, dynamic>;
      expect(headers['X-Session-Token'], 'flow-handle-xyz');
      expect(body, {'code': '123456'});
      // Must not have set an Authorization header (no access token yet).
      expect(headers.containsKey('authorization'), false);
    });

    test('400 with bad-code body surfaces as WgerHttpException', () async {
      when(
        mockClient.post(tMfa, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer(
        (_) async => Response(
          jsonEncode({
            'code': ['Incorrect code.'],
          }),
          400,
        ),
      );

      final container = makeContainer();
      await container.read(authProvider.future);

      expect(
        container
            .read(authProvider.notifier)
            .completeMfa(
              sessionToken: 'flow-handle-xyz',
              code: 'wrong',
              serverUrl: serverUrl,
            ),
        throwsA(isA<WgerHttpException>()),
      );
    });
  });
}
