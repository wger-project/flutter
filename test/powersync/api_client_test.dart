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
import 'package:wger/powersync/api_client.dart';

import 'api_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockClient mockClient;
  late ApiClient apiClient;
  const baseUrl = 'https://server.example';

  setUp(() {
    mockClient = MockClient();
    apiClient = ApiClient(baseUrl, client: mockClient);
  });

  group('getPowersyncToken', () {
    final tokenUri = Uri.parse('$baseUrl/api/v2/powersync-token');

    test('GETs the powersync-token endpoint and returns the JSON body', () async {
      when(mockClient.get(tokenUri, headers: anyNamed('headers'))).thenAnswer(
        (_) async => Response(
          jsonEncode({'token': 'jwt-token', 'powersync_url': 'https://ps.example.com'}),
          200,
        ),
      );

      final result = await apiClient.getPowersyncToken();

      expect(result['token'], 'jwt-token');
      expect(result['powersync_url'], 'https://ps.example.com');
    });

    test('does not set its own Authorization header (the auth client owns it)', () async {
      when(mockClient.get(tokenUri, headers: anyNamed('headers'))).thenAnswer(
        (_) async => Response(jsonEncode({'token': 'jwt'}), 200),
      );

      await apiClient.getPowersyncToken();

      final captured =
          verify(
                mockClient.get(tokenUri, headers: captureAnyNamed('headers')),
              ).captured.single
              as Map<String, String>;
      expect(captured.containsKey(HttpHeaders.authorizationHeader), isFalse);
      expect(captured[HttpHeaders.contentTypeHeader], contains('application/json'));
    });

    test('throws when the server responds non-200', () async {
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

    test('upsert PUTs the JSON-encoded record, no Authorization built locally', () async {
      when(
        mockClient.put(uploadUri, headers: anyNamed('headers'), body: anyNamed('body')),
      ).thenAnswer((_) async => Response('', 200));

      await apiClient.upsert(record);

      final captured =
          verify(
                mockClient.put(
                  uploadUri,
                  headers: captureAnyNamed('headers'),
                  body: jsonEncode(record),
                ),
              ).captured.single
              as Map<String, String>;
      expect(captured.containsKey(HttpHeaders.authorizationHeader), isFalse);
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
