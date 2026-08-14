/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/network/auth_http_client.dart';
import 'package:wger/core/network/auth_notifier.dart';
import 'package:wger/core/network/auth_state.dart';
import 'package:wger/core/network/network_provider.dart';

import '../../helpers/fake_connectivity.dart';
import 'auth_http_client_test.mocks.dart';

/// Records the calls the provider's closures are supposed to route to the
/// notifier, and hands out a credential that a refresh can replace.
class _RecordingAuthNotifier extends AuthNotifier {
  _RecordingAuthNotifier(this._initial);

  AuthState _initial;
  int refreshCalls = 0;
  int clearSessionCalls = 0;
  AuthState? refreshResult;

  @override
  Future<AuthState> build() async => _initial;

  @override
  Future<void> refreshAccessToken() async {
    refreshCalls++;
    final refreshed = refreshResult;
    if (refreshed != null) {
      _initial = refreshed;
      state = AsyncData(refreshed);
    }
  }

  @override
  Future<void> clearSessionOnly() async {
    clearSessionCalls++;
    _initial = const AuthState();
    state = const AsyncData(AuthState());
  }
}

/// Records what the provider's reachability closure routes to the notifier.
class _RecordingNetworkStatus extends NetworkStatus {
  final reports = <bool>[];

  @override
  bool build() => true;

  @override
  void reportRequestSuccess() => reports.add(true);

  @override
  void reportRequestFailure() => reports.add(false);
}

@GenerateMocks([http.Client])
void main() {
  // The provider's onSessionExpired shows a snackbar through
  // scaffoldMessengerKey. Initialising the binding makes that key return null
  // (no widget tree), so the snackbar is skipped instead of throwing.
  TestWidgetsFlutterBinding.ensureInitialized();

  // The provider reports every request outcome to NetworkStatus, which would
  // otherwise reach for the real connectivity plugin and a DNS lookup.
  installFakeConnectivity();

  late MockClient inner;
  late AuthState? auth;
  late int refreshCalls;
  late int sessionExpiredCalls;
  late List<bool> reachabilityReports;
  Future<void> Function() onRefresh = () async {};

  AuthHttpClient buildClient() => AuthHttpClient(
    inner: inner,
    readAuth: () => auth,
    refresh: () async {
      refreshCalls++;
      await onRefresh();
    },
    onSessionExpired: () async {
      sessionExpiredCalls++;
      auth = const AuthState();
    },
    reportReachability: ({required bool reachable}) => reachabilityReports.add(reachable),
  );

  /// Stubs a single response and returns the headers captured from the
  /// matching inner-client invocation.
  Future<Map<String, String>> sendAndCapture(
    http.BaseRequest request, {
    int statusCode = 200,
    String body = '',
  }) async {
    when(inner.send(any)).thenAnswer(
      (inv) async => http.StreamedResponse(
        Stream.value(body.codeUnits),
        statusCode,
      ),
    );
    await buildClient().send(request);
    final captured = verify(inner.send(captureAny)).captured.last as http.BaseRequest;
    return captured.headers;
  }

  setUp(() {
    inner = MockClient();
    auth = null;
    refreshCalls = 0;
    sessionExpiredCalls = 0;
    reachabilityReports = [];
    onRefresh = () async {};
  });

  group('header injection', () {
    test('JWT credential → Authorization: Bearer <access>', () async {
      auth = AuthState(
        credential: JwtCredential(
          accessToken: 'jwt-access',
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );

      final headers = await sendAndCapture(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(headers[HttpHeaders.authorizationHeader], 'Bearer jwt-access');
      expect(refreshCalls, 0);
    });

    test('legacy credential → Authorization: Token <key>', () async {
      auth = const AuthState(credential: LegacyCredential('legacy-key'));

      final headers = await sendAndCapture(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(headers[HttpHeaders.authorizationHeader], 'Token legacy-key');
      expect(refreshCalls, 0);
    });

    test('no auth state → no Authorization header set', () async {
      auth = null;
      final headers = await sendAndCapture(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );
      expect(headers.containsKey(HttpHeaders.authorizationHeader), isFalse);
    });

    test('logged-out state (no credential) → no Authorization header set', () async {
      auth = const AuthState();
      final headers = await sendAndCapture(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );
      expect(headers.containsKey(HttpHeaders.authorizationHeader), isFalse);
    });
  });

  group('pre-emptive refresh', () {
    test('fires when accessExpiresAt is within the leeway window', () async {
      auth = AuthState(
        credential: JwtCredential(
          accessToken: 'old-access',
          expiresAt: DateTime.now().toUtc().add(const Duration(seconds: 5)),
        ),
      );
      onRefresh = () async {
        auth = AuthState(
          credential: JwtCredential(
            accessToken: 'new-access',
            expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
          ),
        );
      };

      final headers = await sendAndCapture(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(refreshCalls, 1);
      expect(headers[HttpHeaders.authorizationHeader], 'Bearer new-access');
    });

    test('does not fire when accessExpiresAt is far in the future', () async {
      auth = AuthState(
        credential: JwtCredential(
          accessToken: 'fresh-access',
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );

      await sendAndCapture(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(refreshCalls, 0);
    });

    test('does not fire for the legacy permanent token', () async {
      auth = const AuthState(credential: LegacyCredential('legacy-key'));

      await sendAndCapture(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(refreshCalls, 0);
    });

    test('does not fire when accessExpiresAt is null', () async {
      auth = const AuthState(credential: JwtCredential(accessToken: 'opaque-jwt'));

      await sendAndCapture(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(refreshCalls, 0);
    });
  });

  group('401 retry', () {
    Future<http.StreamedResponse> stubTwoResponses(
      http.StreamedResponse first,
      http.StreamedResponse second,
    ) {
      var call = 0;
      when(inner.send(any)).thenAnswer((_) async {
        call++;
        return call == 1 ? first : second;
      });
      return Future.value(first);
    }

    test('replayable Request: refresh + retry succeeds → returns retry response', () async {
      auth = AuthState(
        credential: JwtCredential(
          accessToken: 'old-access',
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );
      onRefresh = () async {
        auth = AuthState(
          credential: JwtCredential(
            accessToken: 'new-access',
            expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
          ),
        );
      };
      await stubTwoResponses(
        http.StreamedResponse(Stream.value(<int>[]), 401),
        http.StreamedResponse(Stream.value('OK'.codeUnits), 200),
      );

      final request = http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/'))
        ..body = 'irrelevant';
      final response = await buildClient().send(request);

      expect(response.statusCode, 200);
      expect(refreshCalls, 1);

      final captured = verify(inner.send(captureAny)).captured;
      expect(captured.length, 2);
      expect(
        (captured[0] as http.BaseRequest).headers[HttpHeaders.authorizationHeader],
        'Bearer old-access',
      );
      expect(
        (captured[1] as http.BaseRequest).headers[HttpHeaders.authorizationHeader],
        'Bearer new-access',
      );
    });

    test('replayable Request: retry also 401 → session expired + synthetic 401', () async {
      auth = AuthState(
        credential: JwtCredential(
          accessToken: 'old-access',
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );
      onRefresh = () async {
        auth = AuthState(
          credential: JwtCredential(
            accessToken: 'new-access',
            expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
          ),
        );
      };
      await stubTwoResponses(
        http.StreamedResponse(Stream.value(<int>[]), 401),
        http.StreamedResponse(Stream.value(<int>[]), 401),
      );

      final response = await buildClient().send(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(response.statusCode, 401);
      expect(refreshCalls, 1);
      expect(sessionExpiredCalls, 1);
    });

    test('refresh that returns no fresh access token → synthetic 401, no retry', () async {
      auth = AuthState(
        credential: JwtCredential(
          accessToken: 'old-access',
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );
      onRefresh = () async {
        // Simulates a refresh that gave up and logged out.
        auth = const AuthState();
      };
      when(inner.send(any)).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(<int>[]), 401),
      );

      final response = await buildClient().send(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(response.statusCode, 401);
      expect(refreshCalls, 1);
      verify(inner.send(any)).called(1); // No retry attempted.
    });

    test('legacy 401 → no retry, original 401 surfaces', () async {
      auth = const AuthState(credential: LegacyCredential('legacy-key'));
      when(inner.send(any)).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(<int>[]), 401),
      );

      final response = await buildClient().send(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(response.statusCode, 401);
      expect(refreshCalls, 0);
    });

    test('403 → no refresh, no retry, the response surfaces unchanged', () async {
      // The API answers an auth failure with 403, not 401, because
      // SessionAuthentication runs first. Only the refresh path logs the user
      // out; a 403 here has to reach the caller as it is.
      auth = AuthState(
        credential: JwtCredential(
          accessToken: 'access',
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );
      when(inner.send(any)).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(<int>[]), 403),
      );

      final response = await buildClient().send(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(response.statusCode, 403);
      expect(refreshCalls, 0);
      expect(sessionExpiredCalls, 0);
      verify(inner.send(any)).called(1);
    });

    test('MultipartRequest 401 → no retry (body not replayable)', () async {
      auth = AuthState(
        credential: JwtCredential(
          accessToken: 'old-access',
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );
      when(inner.send(any)).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(<int>[]), 401),
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://wger.example/api/v2/exerciseimage/'),
      )..fields['name'] = 'test';
      final response = await buildClient().send(request);

      expect(response.statusCode, 401);
      expect(refreshCalls, 0);
      verify(inner.send(any)).called(1);
    });
  });

  group('reachability reporting', () {
    // Every real request is a free, perfectly targeted probe for
    // NetworkStatus, which is what keeps its cached status fresh.
    Future<void> send() => buildClient().send(
      http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
    );

    test('any response counts as reachable, including 4xx and 5xx', () async {
      for (final status in [200, 403, 500]) {
        reachabilityReports = [];
        when(inner.send(any)).thenAnswer(
          (_) async => http.StreamedResponse(Stream.value(<int>[]), status),
        );

        await send();

        expect(reachabilityReports, [true], reason: 'HTTP $status was not reported as reachable');
      }
    });

    test('a network error reports unreachable', () async {
      when(inner.send(any)).thenThrow(const SocketException('no route to host'));

      await expectLater(send(), throwsA(isA<SocketException>()));

      expect(reachabilityReports, [false]);
    });

    test('a non-network error reports nothing either way', () async {
      when(inner.send(any)).thenThrow(const FormatException('broken response'));

      await expectLater(send(), throwsA(isA<FormatException>()));

      expect(reachabilityReports, isEmpty);
    });

    test('the retry after a refresh reports as well', () async {
      auth = AuthState(
        credential: JwtCredential(
          accessToken: 'stale',
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );
      onRefresh = () async => auth = AuthState(
        credential: JwtCredential(
          accessToken: 'fresh',
          expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
      );
      var call = 0;
      when(inner.send(any)).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(<int>[]), ++call == 1 ? 401 : 200),
      );

      await send();

      expect(reachabilityReports, [true, true]);
    });
  });

  group('authenticatedHttpClientProvider', () {
    // The tests above build the client with hand-written closures. These cover
    // the wiring the app actually runs: the closures the provider hands to
    // AuthHttpClient have to reach the notifier, or every request goes out
    // unauthenticated and an expired session is never noticed.
    late _RecordingAuthNotifier notifier;
    late _RecordingNetworkStatus networkStatus;

    JwtCredential jwt(String token) => JwtCredential(
      accessToken: token,
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );

    http.Client buildFromProvider(AuthState initial) {
      notifier = _RecordingAuthNotifier(initial);
      networkStatus = _RecordingNetworkStatus();
      final container = ProviderContainer.test(
        overrides: [
          authHttpClientProvider.overrideWithValue(inner),
          authProvider.overrideWith(() => notifier),
          networkStatusProvider.overrideWith(() => networkStatus),
        ],
      );
      // The provider reads authProvider synchronously, so the state has to be
      // resolved before the first request
      container.read(authProvider);
      return container.read(authenticatedHttpClientProvider);
    }

    test('signs requests with the credential held by authProvider', () async {
      final client = buildFromProvider(AuthState(credential: jwt('from-notifier')));
      await pumpEventQueue();
      when(inner.send(any)).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(<int>[]), 200),
      );

      await client.send(http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')));

      final captured = verify(inner.send(captureAny)).captured.single as http.BaseRequest;
      expect(captured.headers[HttpHeaders.authorizationHeader], 'Bearer from-notifier');
    });

    test('a 401 refreshes through the notifier and retries with the new token', () async {
      final client = buildFromProvider(AuthState(credential: jwt('stale')));
      await pumpEventQueue();
      notifier.refreshResult = AuthState(credential: jwt('refreshed'));
      var call = 0;
      when(inner.send(any)).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(<int>[]), ++call == 1 ? 401 : 200),
      );

      final response = await client.send(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(response.statusCode, 200);
      expect(notifier.refreshCalls, 1);
      final captured = verify(inner.send(captureAny)).captured;
      expect(
        (captured.last as http.BaseRequest).headers[HttpHeaders.authorizationHeader],
        'Bearer refreshed',
      );
    });

    test('reports a reached backend to the network status', () async {
      // The closure resolves the notifier at call time; a captured one would
      // go stale when the auth flow invalidates networkStatusProvider.
      final client = buildFromProvider(AuthState(credential: jwt('token')));
      await pumpEventQueue();
      when(inner.send(any)).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(<int>[]), 200),
      );

      await client.send(http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')));

      expect(networkStatus.reports, [true]);
    });

    test('reports an unreachable backend to the network status', () async {
      final client = buildFromProvider(AuthState(credential: jwt('token')));
      await pumpEventQueue();
      when(inner.send(any)).thenThrow(const SocketException('no route to host'));

      await expectLater(
        client.send(http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/'))),
        throwsA(isA<SocketException>()),
      );

      expect(networkStatus.reports, [false]);
    });

    test('a 401 that survives the refresh clears the session', () async {
      final client = buildFromProvider(AuthState(credential: jwt('stale')));
      await pumpEventQueue();
      notifier.refreshResult = AuthState(credential: jwt('also-stale'));
      when(inner.send(any)).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(<int>[]), 401),
      );

      final response = await client.send(
        http.Request('GET', Uri.parse('https://wger.example/api/v2/routine/')),
      );

      expect(response.statusCode, 401);
      expect(notifier.clearSessionCalls, 1);
    });
  });
}
