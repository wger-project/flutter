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
import 'package:material_ui/material_ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/core/network/secure_token_storage.dart';
import 'package:wger/core/update_app_screen.dart';
import 'package:wger/core/update_server_screen.dart';
import 'package:wger/features/auth/screens/mfa_challenge_screen.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../helpers/fake_auth_environment.dart';
import 'mfa_challenge_screen_test.mocks.dart';

@GenerateMocks([http.Client, SecureTokenStorage])
void main() {
  installFakeAuthEnvironment();

  late MockClient mockClient;
  late MockSecureTokenStorage mockSecureStorage;

  const serverUrl = 'https://wger.example';
  const powerSyncUrl = 'https://ps.example/';
  final tMfa = Uri.parse('$serverUrl/allauth/app/v1/auth/2fa/authenticate');
  final tVersion = Uri.parse('$serverUrl/api/v2/version/');
  final tMinAppVersion = Uri.parse('$serverUrl/api/v2/min-app-version/');
  final tPowerSyncToken = Uri.parse('$serverUrl/api/v2/powersync-token');
  final tLiveness = Uri.parse('${powerSyncUrl}probes/liveness');

  String makeJwt(Map<String, dynamic> payload) {
    String enc(Map<String, dynamic> m) =>
        base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
    return '${enc({'alg': 'HS256', 'typ': 'JWT'})}.${enc(payload)}.signature';
  }

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [
        authHttpClientProvider.overrideWithValue(mockClient),
        secureTokenStorageProvider.overrideWithValue(mockSecureStorage),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        // Pop targets need a parent route to pop to; use a Builder so the
        // child screen can be pushed onto a regular navigator stack.
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => child)),
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  setUp(() async {
    mockClient = MockClient();
    mockSecureStorage = MockSecureTokenStorage();
    when(mockSecureStorage.deleteRefreshToken()).thenAnswer((_) async {});
    when(mockSecureStorage.readRefreshToken()).thenAnswer((_) async => null);
    when(mockSecureStorage.writeRefreshToken(any)).thenAnswer((_) async {});

    // Gating-chain happy-path stubs so a successful completeMfa reaches
    // AuthStatus.loggedIn rather than getting stuck on a probe.
    when(mockClient.get(tVersion)).thenAnswer((_) async => Response('"99.99.99"', 200));
    when(mockClient.get(tMinAppVersion)).thenAnswer((_) async => Response('"0.0.1"', 200));
    when(
      mockClient.get(tPowerSyncToken, headers: anyNamed('headers')),
    ).thenAnswer(
      (_) async => Response(
        jsonEncode({'token': 'ps', 'powersync_url': powerSyncUrl}),
        200,
      ),
    );
    when(mockClient.get(tLiveness)).thenAnswer((_) async => Response('OK', 200));
    when(
      mockClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) async => Response(jsonEncode({'next': null}), 200));
    when(mockClient.get(tVersion)).thenAnswer((_) async => Response('"99.99.99"', 200));
    when(mockClient.get(tMinAppVersion)).thenAnswer((_) async => Response('"0.0.1"', 200));
    when(
      mockClient.get(tPowerSyncToken, headers: anyNamed('headers')),
    ).thenAnswer(
      (_) async => Response(
        jsonEncode({'token': 'ps', 'powersync_url': powerSyncUrl}),
        200,
      ),
    );
    when(mockClient.get(tLiveness)).thenAnswer((_) async => Response('OK', 200));
  });

  Future<void> openScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(wrap(screen));
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
  }

  group('MfaChallengeScreen smoke', () {
    testWidgets('renders title, prompt, code input and submit button', (tester) async {
      await openScreen(
        tester,
        const MfaChallengeScreen(
          sessionToken: 'flow-handle',
          serverUrl: serverUrl,
          availableFactors: ['totp', 'recovery_codes'],
        ),
      );

      expect(find.text('Two-factor authentication'), findsOneWidget);
      expect(find.textContaining('authenticator app'), findsOneWidget);
      expect(find.byKey(const ValueKey('inputMfaCode')), findsOneWidget);
      expect(find.byKey(const Key('mfaSubmitButton')), findsOneWidget);
      // Both factors available, toggle shown.
      expect(find.byKey(const Key('mfaToggleModeButton')), findsOneWidget);
    });

    testWidgets('only TOTP supported: no recovery toggle', (tester) async {
      await openScreen(
        tester,
        const MfaChallengeScreen(
          sessionToken: 'flow-handle',
          serverUrl: serverUrl,
          availableFactors: ['totp'],
        ),
      );

      expect(find.byKey(const Key('mfaToggleModeButton')), findsNothing);
      expect(find.byKey(const ValueKey('inputMfaCode')), findsOneWidget);
    });

    testWidgets('unsupported factor (webauthn-only): shows fallback message', (tester) async {
      await openScreen(
        tester,
        const MfaChallengeScreen(
          sessionToken: 'flow-handle',
          serverUrl: serverUrl,
          availableFactors: ['webauthn'],
        ),
      );

      expect(find.textContaining('does not support yet'), findsOneWidget);
      expect(find.byKey(const ValueKey('inputMfaCode')), findsNothing);
      expect(find.byKey(const Key('mfaSubmitButton')), findsNothing);
    });
  });

  group('MfaChallengeScreen submit', () {
    testWidgets('valid code: hits auth/2fa/authenticate and pops', (tester) async {
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

      await openScreen(
        tester,
        const MfaChallengeScreen(
          sessionToken: 'flow-handle',
          serverUrl: serverUrl,
          availableFactors: ['totp', 'recovery_codes'],
        ),
      );

      await tester.enterText(find.byKey(const ValueKey('inputMfaCode')), '123456');
      await tester.tap(find.byKey(const Key('mfaSubmitButton')));
      await tester.pumpAndSettle();

      // Screen popped, opener button visible again.
      expect(find.text('OPEN'), findsOneWidget);
      // Session token + code reached the endpoint.
      final captured = verify(
        mockClient.post(
          tMfa,
          headers: captureAnyNamed('headers'),
          body: captureAnyNamed('body'),
        ),
      ).captured;
      expect((captured[0] as Map<String, String>)['X-Session-Token'], 'flow-handle');
      expect(jsonDecode(captured[1] as String), {'code': '123456'});
    });

    testWidgets('submitting the code field sends the same request as the button', (tester) async {
      // This screen deliberately does not use the shared FormSubmitButton
      // because the code field has to trigger the submit as well. That is the
      // whole reason for the deviation, so it needs to stay covered.
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

      await openScreen(
        tester,
        const MfaChallengeScreen(
          sessionToken: 'flow-handle',
          serverUrl: serverUrl,
          availableFactors: ['totp'],
        ),
      );

      await tester.enterText(find.byKey(const ValueKey('inputMfaCode')), '123456');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('OPEN'), findsOneWidget, reason: 'the screen popped after submitting');
      final captured = verify(
        mockClient.post(
          tMfa,
          headers: captureAnyNamed('headers'),
          body: captureAnyNamed('body'),
        ),
      ).captured;
      expect((captured[0] as Map<String, String>)['X-Session-Token'], 'flow-handle');
      expect(jsonDecode(captured[1] as String), {'code': '123456'});
    });

    testWidgets('an empty code field submitted with the keyboard does not call the server', (
      tester,
    ) async {
      await openScreen(
        tester,
        const MfaChallengeScreen(
          sessionToken: 'flow-handle',
          serverUrl: serverUrl,
          availableFactors: ['totp'],
        ),
      );

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a code'), findsOneWidget);
      verifyNever(
        mockClient.post(tMfa, headers: anyNamed('headers'), body: anyNamed('body')),
      );
    });

    /// Answers the 2FA endpoint with a valid session so the gating chain runs.
    void stubAcceptedCode() {
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
    }

    Future<void> submitValidCode(WidgetTester tester) async {
      await openScreen(
        tester,
        const MfaChallengeScreen(
          sessionToken: 'flow-handle',
          serverUrl: serverUrl,
          availableFactors: ['totp'],
        ),
      );
      await tester.enterText(find.byKey(const ValueKey('inputMfaCode')), '123456');
      await tester.tap(find.byKey(const Key('mfaSubmitButton')));
      await tester.pumpAndSettle();
    }

    testWidgets('an outdated server routes to the update-server screen', (tester) async {
      // The version gate runs after the code was accepted, so the user lands
      // on the update screen instead of back on the login form
      stubAcceptedCode();
      when(mockClient.get(tVersion)).thenAnswer((_) async => Response('"1.0.0"', 200));

      await submitValidCode(tester);

      expect(find.byType(UpdateServerScreen), findsOneWidget);
      expect(find.text('OPEN'), findsNothing, reason: 'the screen was replaced, not popped');
    });

    testWidgets('an outdated app routes to the update-app screen', (tester) async {
      stubAcceptedCode();
      when(mockClient.get(tMinAppVersion)).thenAnswer((_) async => Response('"99.0.0"', 200));

      await submitValidCode(tester);

      expect(find.byType(UpdateAppScreen), findsOneWidget);
    });

    testWidgets('empty code: validation error, no network call', (tester) async {
      await openScreen(
        tester,
        const MfaChallengeScreen(
          sessionToken: 'flow-handle',
          serverUrl: serverUrl,
          availableFactors: ['totp'],
        ),
      );

      await tester.tap(find.byKey(const Key('mfaSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a code'), findsOneWidget);
      verifyNever(
        mockClient.post(tMfa, headers: anyNamed('headers'), body: anyNamed('body')),
      );
    });

    testWidgets('server rejects code: error widget visible, screen stays open', (tester) async {
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

      await openScreen(
        tester,
        const MfaChallengeScreen(
          sessionToken: 'flow-handle',
          serverUrl: serverUrl,
          availableFactors: ['totp'],
        ),
      );

      await tester.enterText(find.byKey(const ValueKey('inputMfaCode')), '000000');
      await tester.tap(find.byKey(const Key('mfaSubmitButton')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Incorrect code'), findsOneWidget);
      // Still on the MFA screen.
      expect(find.byKey(const Key('mfaSubmitButton')), findsOneWidget);
    });

    testWidgets('toggle: switches between TOTP and recovery prompts', (tester) async {
      await openScreen(
        tester,
        const MfaChallengeScreen(
          sessionToken: 'flow-handle',
          serverUrl: serverUrl,
          availableFactors: ['totp', 'recovery_codes'],
        ),
      );

      expect(find.textContaining('authenticator app'), findsOneWidget);
      expect(find.textContaining('recovery code'), findsOneWidget); // toggle button label

      await tester.tap(find.byKey(const Key('mfaToggleModeButton')));
      await tester.pumpAndSettle();

      expect(find.textContaining('recovery code'), findsAtLeast(1));
      expect(find.textContaining('authenticator app'), findsOneWidget); // toggle button label
    });
  });
}
