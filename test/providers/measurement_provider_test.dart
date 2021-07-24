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
import 'package:mockito/mockito.dart';
import 'package:wger/providers/measurements.dart';

import '../base_provider_test.mocks.dart';
import '../utils.dart';

void main() {
  group('Test the measurement provider', () {
    final categoryResponse = '''{
    "count": 2,
    "next": null,
    "previous": null,
    "results": [
      {"id": 1, "name": "Strength", "unit": "kN"},
      {"id": 2, "name": "Biceps", "unit": "cm"}
    ]
    }''';

    final entriesResponse = '''{
    "count": 6,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "category": 1,
            "date": "2021-07-21",
            "value": 10,
            "notes": "Some important notes"
        },
        {
            "id": 2,
            "category": 1,
            "date": "2021-07-10",
            "value": 15.00,
            "notes": ""
        },
        {
            "id": 6,
            "category": 2,
            "date": "2021-07-10",
            "value": 85,
            "notes": ""
        },
        {
            "id": 5,
            "category": 2,
            "date": "2021-07-01",
            "value": 80,
            "notes": ""
        },
        {
            "id": 3,
            "category": 1,
            "date": "2021-06-20",
            "value": 18.80,
            "notes": ""
        },
        {
            "id": 4,
            "category": 1,
            "date": "2021-06-01",
            "value": 5.00,
            "notes": ""
        }
    ]
    }''';

    final mockHttp = MockClient();

    when(mockHttp.get(Uri.parse('https://localhost/api/v2/measurement-category/'),
            headers: anyNamed('headers')))
        .thenAnswer((_) => Future.value(http.Response(categoryResponse, 200)));

    when(mockHttp.get(Uri.parse('https://localhost/api/v2/measurement/?category=1'),
            headers: anyNamed('headers')))
        .thenAnswer((_) => Future.value(http.Response(entriesResponse, 200)));

    var mockMeasurement = MeasurementProvider(testAuthProvider, mockHttp);

    test('Test fetching categories', () async {
      await mockMeasurement.fetchAndSetCategories();
      expect(mockMeasurement.categories.length, 2);

      final category = mockMeasurement.categories.first;
      expect(category.id, 1);
      expect(category.name, 'Strength');
      expect(category.unit, 'kN');
    });

    test('Test fetching entries', () async {
      await mockMeasurement.fetchAndSetCategories();
      var category = mockMeasurement.categories.first;
      expect(category.entries.length, 0);

      category = await mockMeasurement.fetchAndSetCategoryEntries(category.id);
      expect(category.entries.length, 6);
      final entry = category.entries.first;

      expect(entry.id, 1);
      expect(entry.category, 1);
      expect(entry.value, 10);
      expect(entry.date, DateTime(2021, 7, 21));
      expect(entry.notes, 'Some important notes');
    });
  });
}
