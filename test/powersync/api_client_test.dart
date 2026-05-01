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

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/powersync/api_client.dart';

import 'api_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockClient mockClient;
  late ApiClient apiClient;
  const baseUrl = 'https://server.example';

  setUp(() async {
    mockClient = MockClient();
    apiClient = ApiClient(baseUrl, client: mockClient);
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  Future<void> seedUserPrefs(Map<String, dynamic> apiData) async {
    await SharedPreferencesAsyncPlatform.instance!.setString(
      PREFS_USER,
      jsonEncode(apiData),
      const SharedPreferencesOptions(),
    );
  }

  group('getPowersyncToken', () {
    final tokenUri = Uri.parse('$baseUrl/api/v2/powersync-token');

    test('reads the API token from prefs and GETs the powersync-token endpoint', () async {
      await seedUserPrefs({'token': 'abc123'});
      when(mockClient.get(tokenUri, headers: anyNamed('headers'))).thenAnswer(
        (_) async => Response(
          jsonEncode({'token': 'jwt-token', 'powersync_url': 'https://ps.example.com'}),
          200,
        ),
      );

      final result = await apiClient.getPowersyncToken();

      expect(result['token'], 'jwt-token');
      expect(result['powersync_url'], 'https://ps.example.com');
      // The Token header must use the *user's* permanent API token, not the
      // returned JWT, that's the auth model for the powersync-token endpoint.
      final captured =
          verify(
                mockClient.get(tokenUri, headers: captureAnyNamed('headers')),
              ).captured.single
              as Map<String, String>;
      expect(captured[HttpHeaders.authorizationHeader], 'Token abc123');
    });

    test('caches the API token on the instance for subsequent CRUD ops', () async {
      await seedUserPrefs({'token': 'abc123'});
      when(mockClient.get(tokenUri, headers: anyNamed('headers'))).thenAnswer(
        (_) async => Response(jsonEncode({'token': 'jwt'}), 200),
      );

      await apiClient.getPowersyncToken();

      expect(apiClient.token, 'abc123');
      // getHeaders() then uses the cached token.
      expect(apiClient.getHeaders()[HttpHeaders.authorizationHeader], 'Token abc123');
    });

    test('throws when the server responds non-200', () async {
      await seedUserPrefs({'token': 'abc'});
      when(
        mockClient.get(tokenUri, headers: anyNamed('headers')),
      ).thenAnswer((_) async => Response('forbidden', 403));

      expect(apiClient.getPowersyncToken(), throwsException);
    });
  });

  group('upsert/update/delete', () {
    final uploadUri = Uri.parse('$baseUrl/api/v2/upload-powersync-data');
    final record = {
      'table': 'manager_routine',
      'data': {'id': '5', 'name': 'Push'},
    };

    setUp(() {
      // Pre-populate the token so getHeaders builds a complete Authorization.
      apiClient.token = 'cached-token';
    });

    test('upsert PUTs the JSON-encoded record', () async {
      when(
        mockClient.put(uploadUri, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response('', 200));

      await apiClient.upsert(record);

      verify(
        mockClient.put(
          uploadUri,
          headers: argThat(
            containsPair(HttpHeaders.authorizationHeader, 'Token cached-token'),
            named: 'headers',
          ),
          body: jsonEncode(record),
        ),
      ).called(1);
    });

    test('update PATCHes the JSON-encoded record', () async {
      when(
        mockClient.patch(uploadUri, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response('', 200));

      await apiClient.update(record);

      verify(
        mockClient.patch(uploadUri, headers: anyNamed('headers'), body: jsonEncode(record)),
      ).called(1);
    });

    test('delete DELETEs with the JSON-encoded record as body', () async {
      when(
        mockClient.delete(uploadUri, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response('', 200));

      await apiClient.delete(record);

      verify(
        mockClient.delete(uploadUri, headers: anyNamed('headers'), body: jsonEncode(record)),
      ).called(1);
    });

    test('upload methods return the raw http.Response so the connector can inspect it', () async {
      when(
        mockClient.put(uploadUri, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response('{"error":"validation"}', 200));

      final response = await apiClient.upsert(record);

      expect(response.statusCode, 200);
      expect(response.body, '{"error":"validation"}');
    });
  });
}
