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

  group('isOfficialBodyWeight', () {
    test('is true only for the official body weight category', () {
      final official = MeasurementCategory(
        metricType: MetricType.bodyWeight,
        isOfficial: true,
      );
      expect(official.isOfficialBodyWeight, isTrue);

      // A user-created category with the same metric type is not official
      expect(MeasurementCategory(metricType: MetricType.bodyWeight).isOfficialBodyWeight, isFalse);
      // Other official metric types are not body weight
      expect(
        MeasurementCategory(metricType: MetricType.height, isOfficial: true).isOfficialBodyWeight,
        isFalse,
      );
    });
  });

  group('ChartType', () {
    test('fromWire maps null, the server default, to no override', () {
      expect(ChartType.fromWire(null), ChartType.auto);
    });

    test('fromWire defaults to auto for a type this release does not know', () {
      expect(ChartType.fromWire('sunburst'), ChartType.auto);
    });

    test('wireValue round-trips through fromWire for every case', () {
      for (final type in ChartType.values) {
        expect(ChartType.fromWire(type.wireValue), type);
      }
    });

    test('the offered types follow the metric type', () {
      expect(MetricType.steps.availableChartTypes, [ChartType.bar, ChartType.heatmap]);
      expect(MetricType.custom.availableChartTypes, [ChartType.line, ChartType.heatmap]);

      // a group is drawn by what its components are to each other
      expect(MetricType.bloodPressure.availableChartTypes, isEmpty);
    });

    test('a type that does not fit falls back to the derived chart', () {
      expect(MetricType.custom.resolveChartType(ChartType.bar), ChartType.line);
      expect(MetricType.steps.resolveChartType(ChartType.line), ChartType.bar);
      expect(MetricType.custom.resolveChartType(ChartType.auto), ChartType.line);
    });

    test('a type that fits is kept', () {
      expect(MetricType.custom.resolveChartType(ChartType.heatmap), ChartType.heatmap);
      expect(MetricType.steps.resolveChartType(ChartType.bar), ChartType.bar);
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

    test('limits are per unit for body weight only', () {
      expect(MetricType.bodyWeight.limits('kg').max, 350);
      expect(MetricType.bodyWeight.limits('lb').max, 770);

      // every other type has one unit, so the argument changes nothing
      expect(MetricType.heartRate.limits('bpm').max, MetricType.heartRate.limits().max);
    });

    test('limits of the components differ from each other', () {
      expect(MetricType.bloodPressureSystolic.limits().max, 250);
      expect(MetricType.bloodPressureDiastolic.limits().max, 150);
    });

    test('limits of an untyped category are the column itself', () {
      expect(MetricType.custom.limits().min, 0);
      expect(MetricType.custom.limits().max, measurementSchemaMaxValue);
    });

    test('contains is inclusive', () {
      final limits = MetricType.steps.limits();

      expect(limits.contains(0), isTrue);
      expect(limits.contains(100000), isTrue);
      expect(limits.contains(100001), isFalse);
    });

    test('correlatesWithNutrition is true for body composition and custom', () {
      expect(MetricType.bodyWeight.correlatesWithNutrition, isTrue);
      expect(MetricType.bodyFat.correlatesWithNutrition, isTrue);
      expect(MetricType.custom.correlatesWithNutrition, isTrue);

      // the typed health metrics don't get nutrition plan context
      expect(MetricType.heartRate.correlatesWithNutrition, isFalse);
      expect(MetricType.bloodPressure.correlatesWithNutrition, isFalse);
      expect(MetricType.steps.correlatesWithNutrition, isFalse);
      expect(MetricType.sleep.correlatesWithNutrition, isFalse);
    });
  });
}
