/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/exceptions/no_such_entry_exception.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

void main() {
  final List<MeasurementEntry> tMeasurementEntries = [
    MeasurementEntry(
      uuid: 1234,
      categoryId: 123,
      date: DateTime(2021, 7, 22),
      value: 83,
      notes: 'notes',
    ),
  ];

  final MeasurementEntry tMeasurementEntry = MeasurementEntry(
    uuid: 1234,
    categoryId: 123,
    date: DateTime(2021, 7, 22),
    value: 83,
    notes: 'notes',
  );
  const int tMeasurementEntryId = 1234;

  final MeasurementCategory tMeasurementCategory = MeasurementCategory(
    uuid: 123,
    name: 'Bizeps',
    unit: 'cm',
    entries: tMeasurementEntries,
  );

  final Map<String, dynamic> tMeasurementEntryMap = {
    'id': 1234,
    'category': 123,
    'date': '2021-07-22',
    'value': 83,
    'notes': 'notes',
  };

  final Map<String, dynamic> tMeasurementCategoryMap = {
    'id': 123,
    'name': 'Bizeps',
    'unit': 'cm',
    'entries': [tMeasurementEntryMap],
  };

  final Map<String, dynamic> tMeasurementCategoryMaptoJson = {
    'id': 123,
    'name': 'Bizeps',
    'unit': 'cm',
    'entries': null,
  };

  group('fromJson()', () {
    test('should convert a JSON map to a MeasurementCategory object', () {
      // act
      final result = MeasurementCategory.fromJson(tMeasurementCategoryMap);

      // assert
      expect(result, tMeasurementCategory);
    });
  });

  group('toJson()', () {
    test('should convert a MeasurementCategory object to a JSON map', () {
      // act
      final result = tMeasurementCategory.toJson();

      // assert
      expect(result, tMeasurementCategoryMaptoJson);
    });
  });

  group('copyWith()', () {
    test('should copyWith objects of this class', () {
      // arrange

      final MeasurementCategory tMeasurementCategoryCopied = MeasurementCategory(
        uuid: 1234,
        name: 'Coolness',
        unit: 'lp',
        entries: tMeasurementEntries,
      );

      // act
      final result = tMeasurementCategory.copyWith(
        uuid: 1234,
        name: 'Coolness',
        unit: 'lp',
        entries: tMeasurementEntries,
      );

      // assert
      expect(result, tMeasurementCategoryCopied);
    });
  });

  group('findEntryById()', () {
    test('should find an entry in the entries list', () {
      // arrange

      // act
      final result = tMeasurementCategory.findEntryByUuid(tMeasurementEntryId);

      // assert
      expect(result, tMeasurementEntry);
    });

    test('should throw a NoSuchEntryException if no MeasurementEntry was found', () {
      // act & assert
      expect(() => tMeasurementCategory.findEntryByUuid(83), throwsA(isA<NoSuchEntryException>()));
    });
  });
}
