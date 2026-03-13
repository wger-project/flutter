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
import 'package:wger/models/measurements/measurement_entry.dart';

void main() {
  final MeasurementEntry tMeasurementEntry = MeasurementEntry(
    uuid: 1234,
    categoryId: 123,
    date: DateTime(2021, 7, 22),
    value: 83,
    notes: 'notes',
  );

  final Map<String, dynamic> tMeasurementEntryMap = {
    'id': 1234,
    'category': 123,
    'date': '2021-07-22',
    'value': 83,
    'notes': 'notes',
  };

  test('should convert a JSON map to a MeasurementEntry object', () {
    // act
    final result = MeasurementEntry.fromJson(tMeasurementEntryMap);

    // assert
    expect(result, tMeasurementEntry);
  });

  test('should convert a MeasurementEntry object to a JSON map', () {
    // act
    final result = tMeasurementEntry.toJson();

    // assert
    expect(result, tMeasurementEntryMap);
  });

  test('should copyWith objects of this class', () {
    // arrange

    final MeasurementEntry tMeasurementEntryCopied = MeasurementEntry(
      uuid: 83,
      categoryId: 17,
      date: DateTime(1960),
      value: 93,
      notes: 'Interesting',
    );

    // act
    final result = tMeasurementEntry.copyWith(
      uuid: 83,
      category: 17,
      date: DateTime(1960),
      value: 93,
      notes: 'Interesting',
    );

    // assert
    expect(result, tMeasurementEntryCopied);
  });
}
