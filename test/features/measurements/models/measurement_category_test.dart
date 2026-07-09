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
import 'package:wger/features/measurements/models/measurement_category.dart';

import '../../../../test_data/measurements.dart';

void main() {
  late MeasurementCategory category;

  setUp(() {
    category = getMeasurementCategories()[0];
  });

  group('findEntryById()', () {
    test('should find an entry in the entries list', () {
      // act
      final result = category.findEntryById('1');

      // assert
      expect(result.id, '1');
    });

    test('should throw a NoSuchEntryException if no MeasurementEntry was found', () {
      // act & assert
      expect(() => category.findEntryById('abc'), throwsA(isA<NoSuchEntryException>()));
    });
  });

  group('MetricType', () {
    test('fromWire maps a known wire value to its enum case', () {
      expect(MetricType.fromWire('body_fat'), MetricType.bodyFat);
      expect(MetricType.fromWire('blood_pressure'), MetricType.bloodPressure);
      expect(MetricType.fromWire('custom'), MetricType.custom);
    });

    test('fromWire defaults to custom for an unknown value', () {
      expect(MetricType.fromWire('something_new'), MetricType.custom);
      expect(MetricType.fromWire(''), MetricType.custom);
    });

    test('wireValue round-trips through fromWire for every case', () {
      for (final type in MetricType.values) {
        expect(MetricType.fromWire(type.wireValue), type);
      }
    });

    test('isSummedPerDay is true only for cumulative daily metrics', () {
      expect(MetricType.steps.isSummedPerDay, isTrue);
      expect(MetricType.distance.isSummedPerDay, isTrue);
      expect(MetricType.energy.isSummedPerDay, isTrue);
      expect(MetricType.sleep.isSummedPerDay, isTrue);

      expect(MetricType.custom.isSummedPerDay, isFalse);
      expect(MetricType.bodyWeight.isSummedPerDay, isFalse);
      expect(MetricType.heartRate.isSummedPerDay, isFalse);
    });
  });
}
