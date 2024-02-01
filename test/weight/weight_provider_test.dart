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

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/body_weight.dart';

import '../fixtures/fixture_reader.dart';
import 'weight_provider_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late MockWgerBaseProvider mockBaseProvider;

  setUp(() {
    mockBaseProvider = MockWgerBaseProvider();
  });

  group('test body weight provider', () {
    test('Test that the weight entries are correctly loaded', () async {
      final uri = Uri(
        scheme: 'https',
        host: 'localhost',
        path: 'api/v2/weightentry/',
      );
      when(mockBaseProvider.makeUrl(any, query: anyNamed('query'))).thenReturn(uri);
      final Map<String, dynamic> weightEntries = jsonDecode(
        fixture('weight/weight_entries.json'),
      );

      when(mockBaseProvider.fetchPaginated(uri)).thenAnswer(
        (_) => Future.value(weightEntries['results']),
      );

      // Load the entries
      final BodyWeightProvider provider = BodyWeightProvider(mockBaseProvider);
      await provider.fetchAndSetEntries();

      // Check that everything is ok
      expect(provider.items, isA<List<WeightEntry>>());
      expect(provider.items.length, 11);
    });

    test('Test adding a new weight entry', () async {
      // Arrange
      final uri = Uri(
        scheme: 'https',
        host: 'localhost',
        path: 'api/v2/weightentry/',
      );
      when(mockBaseProvider.makeUrl(any, query: anyNamed('query'))).thenReturn(uri);
      when(mockBaseProvider.post({'id': null, 'weight': '80', 'date': '2021-01-01'}, uri))
          .thenAnswer((_) => Future.value({'id': 25, 'date': '2021-01-01', 'weight': '80'}));

      // Act
      final BodyWeightProvider provider = BodyWeightProvider(mockBaseProvider);
      final WeightEntry weightEntry = WeightEntry(date: DateTime(2021, 1, 1), weight: 80);
      final WeightEntry weightEntryNew = await provider.addEntry(weightEntry);

      // Assert
      expect(weightEntryNew.id, 25);
      expect(weightEntryNew.date, DateTime(2021, 1, 1));
      expect(weightEntryNew.weight, 80);
    });

    test('Test deleting an existing weight entry', () async {
      // Arrange
      final uri = Uri(
        scheme: 'https',
        host: 'localhost',
        path: 'api/v2/weightentry/4/',
      );
      when(mockBaseProvider.makeUrl(any, query: anyNamed('query'))).thenReturn(uri);
      when(mockBaseProvider.deleteRequest('weightentry', 4)).thenAnswer(
          (_) => Future.value(Response("{'id': 4, 'date': '2021-01-01', 'weight': '80'}", 204)));

      // DELETE the data from the server
      final BodyWeightProvider provider = BodyWeightProvider(mockBaseProvider);
      provider.items = [
        WeightEntry(id: 4, weight: 80, date: DateTime(2021, 1, 1)),
        WeightEntry(id: 2, weight: 100, date: DateTime(2021, 2, 2)),
        WeightEntry(id: 5, weight: 60, date: DateTime(2021, 2, 2))
      ];
      await provider.deleteEntry(4);

      // Check that the entry was removed from the entry list
      expect(provider.items.length, 2);
    });
  });
}
