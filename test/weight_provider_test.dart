/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight.dart';

import 'utils.dart';

void main() {
  group('test body weight provider', () {
    test('Test that the weight entries are correctly loaded', () async {
      final client = MockClient();

      // Mock the server response
      when(client.get(
        'https://localhost/api/v2/weightentry/?ordering=-date',
        headers: <String, String>{
          HttpHeaders.authorizationHeader: 'Token ${testAuth.token}',
          HttpHeaders.userAgentHeader: 'wger Workout Manager App',
        },
      )).thenAnswer((_) async => http.Response(
          '{"results": [{"id": 1, "date": "2021-01-01", "weight": "80.00"}, '
          '{"id": 2, "date": "2021-01-10", "weight": "99"},'
          '{"id": 3, "date": "2021-01-20", "weight": "100.01"}]}',
          200));

      // Load the entries
      BodyWeight provider = BodyWeight(testAuth, [], client);
      await provider.fetchAndSetEntries();

      // Check that everything is ok
      expect(provider.items, isA<List<WeightEntry>>());
      expect(provider.items.length, 3);
    });

    test('Test adding a new weight entry', () async {
      final client = MockClient();

      // Mock the server response
      when(client.post('https://localhost/api/v2/weightentry/',
              headers: {
                HttpHeaders.authorizationHeader: 'Token ${testAuth.token}',
                HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
                HttpHeaders.userAgentHeader: 'wger Workout Manager App',
              },
              body: '{"id":null,"weight":"80","date":"2021-01-01"}'))
          .thenAnswer(
              (_) async => http.Response('{"id": 25, "date": "2021-01-01", "weight": "80"}', 200));

      // POST the data to the server
      final WeightEntry weightEntry = WeightEntry(date: DateTime(2021, 1, 1), weight: 80);
      final BodyWeight provider = BodyWeight(testAuth, [], client);
      final WeightEntry weightEntryNew = await provider.addEntry(weightEntry);

      // Check that the server response is what we expect
      expect(weightEntryNew.id, 25);
      expect(weightEntryNew.date, DateTime(2021, 1, 1));
      expect(weightEntryNew.weight, 80);
    });

    test('Test deleting an existing weight entry', () async {
      final client = MockClient();

      // Mock the server response
      when(client.delete(
        'https://localhost/api/v2/weightentry/4/',
        headers: {
          HttpHeaders.authorizationHeader: 'Token ${testAuth.token}',
          HttpHeaders.userAgentHeader: 'wger Workout Manager App',
        },
      )).thenAnswer((_) async => http.Response('', 200));

      // DELETE the data from the server
      final BodyWeight provider = BodyWeight(
        testAuth,
        [
          WeightEntry(id: 4, weight: 80, date: DateTime(2021, 1, 1)),
          WeightEntry(id: 2, weight: 100, date: DateTime(2021, 2, 2)),
          WeightEntry(id: 5, weight: 60, date: DateTime(2021, 2, 2))
        ],
        client,
      );
      await provider.deleteEntry(4);

      // Check that the entry was removed from the entry list
      expect(provider.items.length, 2);
    });
  });
}
