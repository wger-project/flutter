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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_bridge/health.dart';
import 'package:wger/features/health/models/health_metric.dart';

/// The Health Connect read permission each imported type needs declared, as
/// `HealthPermission.getReadPermission` derives it from the record class.
/// Deliberately covers the parked types too, so enabling one fails with a
/// missing manifest entry rather than with an unknown type.
const _readPermissions = {
  HealthDataType.WEIGHT: 'android.permission.health.READ_WEIGHT',
  HealthDataType.BODY_FAT_PERCENTAGE: 'android.permission.health.READ_BODY_FAT',
  HealthDataType.LEAN_BODY_MASS: 'android.permission.health.READ_LEAN_BODY_MASS',
  HealthDataType.HEIGHT: 'android.permission.health.READ_HEIGHT',
  HealthDataType.BLOOD_PRESSURE_SYSTOLIC: 'android.permission.health.READ_BLOOD_PRESSURE',
  HealthDataType.BLOOD_PRESSURE_DIASTOLIC: 'android.permission.health.READ_BLOOD_PRESSURE',
  HealthDataType.HEART_RATE: 'android.permission.health.READ_HEART_RATE',
  HealthDataType.RESTING_HEART_RATE: 'android.permission.health.READ_RESTING_HEART_RATE',
  HealthDataType.BLOOD_OXYGEN: 'android.permission.health.READ_OXYGEN_SATURATION',
  // Every sleep type is a SleepSessionRecord, so they share one permission
  HealthDataType.SLEEP_ASLEEP: 'android.permission.health.READ_SLEEP',
  HealthDataType.SLEEP_LIGHT: 'android.permission.health.READ_SLEEP',
  HealthDataType.SLEEP_DEEP: 'android.permission.health.READ_SLEEP',
  HealthDataType.SLEEP_REM: 'android.permission.health.READ_SLEEP',
  HealthDataType.SLEEP_AWAKE: 'android.permission.health.READ_SLEEP',
  HealthDataType.STEPS: 'android.permission.health.READ_STEPS',
  HealthDataType.DISTANCE_DELTA: 'android.permission.health.READ_DISTANCE',
  HealthDataType.ACTIVE_ENERGY_BURNED: 'android.permission.health.READ_ACTIVE_CALORIES_BURNED',
};

void main() {
  group('Android manifest', () {
    late String manifest;

    setUpAll(() {
      manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    });

    test('declares a read permission for every imported type', () {
      // Health Connect can only grant what the manifest declares, and it
      // reports an undeclared type as not granted rather than as an error, so
      // a forgotten entry costs that metric its import without a trace
      for (final metric in healthMetrics) {
        for (final type in metric.dataTypes) {
          final permission = _readPermissions[type];
          expect(
            permission,
            isNotNull,
            reason: 'No known Health Connect permission for ${type.name}, add it here',
          );
          expect(
            manifest,
            contains('android:name="$permission"'),
            reason:
                '${metric.metricType.name} imports ${type.name}, '
                'which needs $permission in the manifest',
          );
        }
      }
    });

    test('declares the history permission', () {
      // Without it Health Connect silently caps every read at 30 days, which
      // makes the first import look complete while missing everything before
      expect(
        manifest,
        contains('android:name="android.permission.health.READ_HEALTH_DATA_HISTORY"'),
      );
    });
  });
}
