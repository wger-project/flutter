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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/providers/base_provider.dart';

import '../utils.dart';
import 'base_provider_extra_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late WgerBaseProvider repo;

  setUp(() {
    mockClient = MockClient();
    repo = buildTestBaseProvider(client: mockClient);
  });

  final uri = Uri.https('localhost', '/api/v2/endpoint/');

  group('getDefaultHeaders', () {
    test('omits Authorization by default and includes Content-Type + User-Agent', () {
      final headers = repo.getDefaultHeaders();

      expect(headers[HttpHeaders.contentTypeHeader], contains('application/json'));
      expect(headers[HttpHeaders.userAgentHeader], isNotNull);
      expect(headers.containsKey(HttpHeaders.authorizationHeader), isFalse);
      expect(headers.containsKey(HttpHeaders.acceptLanguageHeader), isFalse);
    });

    test('includeAuth=true adds Token header', () {
      final headers = repo.getDefaultHeaders(includeAuth: true);

      expect(headers[HttpHeaders.authorizationHeader], 'Token FooBar');
    });

    test('language sets Accept-Language', () {
      final headers = repo.getDefaultHeaders(language: 'de');

      expect(headers[HttpHeaders.acceptLanguageHeader], 'de');
    });
  });

  group('fetch', () {
    test('returns the parsed body on 200', () async {
      when(mockClient.get(uri, headers: anyNamed('headers'))).thenAnswer(
        (_) async => Response(jsonEncode({'value': 42}), 200),
      );

      final result = await repo.fetch(uri);

      expect(result, {'value': 42});
    });

    test('throws WgerHttpException on a non-retried 4xx', () async {
      when(
        mockClient.get(uri, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('not found', 404));

      expect(repo.fetch(uri), throwsA(isA<WgerHttpException>()));
    });

    test('retries on a 5xx and eventually succeeds', () async {
      var calls = 0;
      when(mockClient.get(uri, headers: anyNamed('headers'))).thenAnswer((_) async {
        calls++;
        if (calls < 3) {
          return Response('boom', 502);
        }
        return Response(jsonEncode({'ok': true}), 200);
      });

      final result = await repo.fetch(
        uri,
        initialDelay: const Duration(milliseconds: 1),
      );

      expect(result, {'ok': true});
      expect(calls, 3);
    });

    test('gives up and throws after maxRetries on persistent 5xx', () async {
      when(
        mockClient.get(uri, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('boom', 502));

      expect(
        repo.fetch(
          uri,
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 1),
        ),
        throwsA(isA<WgerHttpException>()),
      );
    });

    test('retries on TimeoutException and eventually succeeds', () async {
      var calls = 0;
      when(mockClient.get(uri, headers: anyNamed('headers'))).thenAnswer((_) async {
        calls++;
        if (calls < 2) {
          throw TimeoutException('slow');
        }
        return Response(jsonEncode({'ok': true}), 200);
      });

      final result = await repo.fetch(
        uri,
        initialDelay: const Duration(milliseconds: 1),
      );

      expect(result, {'ok': true});
      expect(calls, 2);
    });

    test('rethrows after maxRetries SocketExceptions', () async {
      when(
        mockClient.get(uri, headers: anyNamed('headers')),
      ).thenThrow(const SocketException('no network'));

      expect(
        repo.fetch(uri, maxRetries: 1, initialDelay: const Duration(milliseconds: 1)),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('post', () {
    test('returns the parsed body on success', () async {
      when(
        mockClient.post(uri, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response(jsonEncode({'id': 7}), 201));

      final result = await repo.post({'name': 'foo'}, uri);

      expect(result['id'], 7);
    });

    test('throws WgerHttpException on >=400', () async {
      when(
        mockClient.post(uri, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response('bad', 400));

      expect(repo.post({}, uri), throwsA(isA<WgerHttpException>()));
    });
  });

  group('patch', () {
    test('returns the parsed body on success', () async {
      when(
        mockClient.patch(uri, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response(jsonEncode({'id': 7}), 200));

      final result = await repo.patch({'name': 'foo'}, uri);

      expect(result['id'], 7);
    });

    test('throws WgerHttpException on >=400', () async {
      when(
        mockClient.patch(uri, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response('bad', 422));

      expect(repo.patch({}, uri), throwsA(isA<WgerHttpException>()));
    });
  });

  group('deleteRequest', () {
    test('builds the URL via makeUrl and returns the response on success', () async {
      final deleteUri = Uri.https('localhost', '/api/v2/endpoint/5/');
      when(
        mockClient.delete(deleteUri, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('', 204));

      final response = await repo.deleteRequest('endpoint', 5);

      expect(response.statusCode, 204);
    });

    test('throws WgerHttpException on >=400', () async {
      final deleteUri = Uri.https('localhost', '/api/v2/endpoint/5/');
      when(
        mockClient.delete(deleteUri, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('forbidden', 403));

      expect(repo.deleteRequest('endpoint', 5), throwsA(isA<WgerHttpException>()));
    });
  });
}
