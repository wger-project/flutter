/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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
import 'package:health_bridge/health.dart';
import 'package:wger/features/health/models/health_reading.dart';

HealthDataPoint dataPoint({String uuid = 'abc-123', HealthValue? value}) {
  return HealthDataPoint(
    uuid: uuid,
    value: value ?? NumericHealthValue(numericValue: 1.8),
    type: HealthDataType.HEIGHT,
    unit: HealthDataUnit.METER,
    dateFrom: DateTime(2026, 1, 1, 8, 30),
    dateTo: DateTime(2026, 1, 1, 8, 30),
    sourcePlatform: HealthPlatformType.appleHealth,
    sourceDeviceId: 'device',
    sourceId: 'source',
    sourceName: 'test',
  );
}

void main() {
  group('fromDataPoint', () {
    test('extracts the numeric value, type and start date', () {
      final reading = HealthReading.fromDataPoint(dataPoint())!;

      expect(reading.type, HealthDataType.HEIGHT);
      expect(reading.value, 1.8);
      expect(reading.date, DateTime(2026, 1, 1, 8, 30));
      expect(reading.externalId, 'abc-123');
    });

    test('returns null for a non-numeric value', () {
      final point = dataPoint(value: NutritionHealthValue());

      expect(HealthReading.fromDataPoint(point), isNull);
    });

    test('lowercases the platform UUID to match the server normalization', () {
      final point = dataPoint(uuid: '1A2B3C4D-C36C-495A-93FC-0C247A3E6E5F');

      expect(
        HealthReading.fromDataPoint(point)!.externalId,
        '1a2b3c4d-c36c-495a-93fc-0c247a3e6e5f',
      );
    });

    test('maps an empty UUID to null', () {
      final point = dataPoint(uuid: '');

      expect(HealthReading.fromDataPoint(point)!.externalId, isNull);
    });
  });
}
