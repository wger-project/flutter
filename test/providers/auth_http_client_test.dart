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

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/providers/auth_http_client.dart';
import 'package:wger/providers/auth_state.dart';

import 'auth_http_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient inner;
  late AuthState? auth;
  late int refreshCalls;
  late int sessionExpiredCalls;
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
}
