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

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/providers/base_provider.dart';

import '../fixtures/fixture_reader.dart';
import '../utils.dart';
import 'base_provider_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('test base provider', () {
    test('Test the makeUrl helper', () async {
      final WgerBaseProvider provider = WgerBaseProvider(testAuthProvider);

      expect(
        Uri.https('localhost', '/api/v2/endpoint/'),
        provider.makeUrl('endpoint'),
      );
      expect(
        Uri.https('localhost', '/api/v2/endpoint/5/'),
        provider.makeUrl('endpoint', id: 5),
      );
      expect(
        Uri.https('localhost', '/api/v2/endpoint/5/log_data/'),
        provider.makeUrl('endpoint', id: 5, objectMethod: 'log_data'),
      );
      expect(
        Uri.https('localhost', '/api/v2/endpoint/', {'a': '2', 'b': 'c'}),
        provider.makeUrl('endpoint', query: {'a': '2', 'b': 'c'}),
      );
      expect(
        Uri.https('localhost', '/api/v2/endpoint/log_data/', {'a': '2', 'b': 'c'}),
        provider.makeUrl('endpoint', objectMethod: 'log_data', query: {'a': '2', 'b': 'c'}),
      );
      expect(
        Uri.https('localhost', '/api/v2/endpoint/42/', {'a': '2', 'b': 'c'}),
        provider.makeUrl('endpoint', id: 42, query: {'a': '2', 'b': 'c'}),
      );
      expect(
        Uri.https('localhost', '/api/v2/endpoint/42/log_data/', {'a': '2', 'b': 'c'}),
        provider.makeUrl('endpoint', id: 42, objectMethod: 'log_data', query: {'a': '2', 'b': 'c'}),
      );
    });

    test('Test the makeUrl helper with sub url', () async {
      // Trailing slash is removed when saving the server URL
      testAuthProvider.serverUrl = 'https://example.com/wger-url';
      final WgerBaseProvider provider = WgerBaseProvider(testAuthProvider);

      expect(
        Uri.https('example.com', '/wger-url/api/v2/endpoint/'),
        provider.makeUrl('endpoint'),
      );
      expect(
        Uri.https('example.com', '/wger-url/api/v2/endpoint/5/'),
        provider.makeUrl('endpoint', id: 5),
      );
      expect(
        Uri.https('example.com', '/wger-url/api/v2/endpoint/5/log_data/'),
        provider.makeUrl('endpoint', id: 5, objectMethod: 'log_data'),
      );
      expect(
        Uri.https('example.com', '/wger-url/api/v2/endpoint/', {'a': '2', 'b': 'c'}),
        provider.makeUrl('endpoint', query: {'a': '2', 'b': 'c'}),
      );
      expect(
        Uri.https('example.com', '/wger-url/api/v2/endpoint/log_data/', {'a': '2', 'b': 'c'}),
        provider.makeUrl('endpoint', objectMethod: 'log_data', query: {'a': '2', 'b': 'c'}),
      );
      expect(
        Uri.https('example.com', '/wger-url/api/v2/endpoint/42/', {'a': '2', 'b': 'c'}),
        provider.makeUrl('endpoint', id: 42, query: {'a': '2', 'b': 'c'}),
      );
      expect(
        Uri.https('example.com', '/wger-url/api/v2/endpoint/42/log_data/', {'a': '2', 'b': 'c'}),
        provider.makeUrl('endpoint', id: 42, objectMethod: 'log_data', query: {'a': '2', 'b': 'c'}),
      );
    });
  });

  group('Retrieving and fetching data', () {
    test('Test loading paginated data', () async {
      // Arrange
      final mockHttpClient = MockClient();
      final response1 = Response(fixture('pagination/pagination1.json'), 200);
      final response2 = Response(fixture('pagination/pagination2.json'), 200);
      final response3 = Response(fixture('pagination/pagination3.json'), 200);
      final Uri paginationUri1 = Uri(
        scheme: 'https',
        host: 'localhost',
        path: 'api/v2/itcrowd/',
      );
      final Uri paginationUri2 = Uri(
        scheme: 'https',
        host: 'localhost',
        path: 'api/v2/itcrowd/',
        query: 'limit=20&offset=20',
      );
      final Uri paginationUri3 = Uri(
        scheme: 'https',
        host: 'localhost',
        path: 'api/v2/itcrowd/',
        query: 'limit=20&offset=40',
      );

      when(mockHttpClient.get(paginationUri1, headers: anyNamed('headers')))
          .thenAnswer((_) => Future.value(response1));
      when(mockHttpClient.get(paginationUri2, headers: anyNamed('headers')))
          .thenAnswer((_) => Future.value(response2));
      when(mockHttpClient.get(paginationUri3, headers: anyNamed('headers')))
          .thenAnswer((_) => Future.value(response3));

      // Act
      final WgerBaseProvider provider = WgerBaseProvider(testAuthProvider, mockHttpClient);
      final data = await provider.fetchPaginated(paginationUri1);

      // Assert
      expect(data.length, 5);
      expect(data[0], {'id': 1, 'value': "You wouldn't steal a handbag."});
      expect(data[1], {'id': 2, 'value': "You wouldn't steal a car."});
      expect(data[2], {'id': 3, 'value': "You wouldn't steal a baby."});
      expect(data[3], {'id': 4, 'value': "You wouldn't shoot a policeman."});
      expect(data[4], {'id': 5, 'value': 'And then steal his helmet.'});
    });
  });
}
