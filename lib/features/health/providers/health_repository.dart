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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:wger/features/health/models/health_reading.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository();
});

/// Wraps the `health` plugin so the rest of the app talks to a small, mockable
/// surface instead of Apple Health / Health Connect directly.
class HealthRepository {
  HealthRepository([Health? health]) : _health = health ?? Health();

  final Health _health;
  final _logger = Logger('HealthRepository');

  /// The measurement `source` value for readings from this platform: `apple`
  /// for Apple Health, `google` for Health Connect.
  String get sourceName => Platform.isIOS ? 'apple' : 'google';

  /// Whether a health platform is usable on this device.
  Future<bool> isAvailable() async {
    if (Platform.isAndroid) {
      await _health.configure();
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable;
    }
    return Platform.isIOS;
  }

  /// Ensures READ access to [types] (requesting it if needed) and, on Android,
  /// access to historical data. Returns whether access is granted.
  Future<bool> ensureAuthorized(List<HealthDataType> types) async {
    await _health.configure();
    final access = List.filled(types.length, HealthDataAccess.READ);

    final hasPerms = await _health.hasPermissions(types, permissions: access);
    if (hasPerms != true) {
      final granted = await _health.requestAuthorization(types, permissions: access);
      if (!granted) {
        _logger.warning('Health permissions not granted');
        return false;
      }
    }

    if (Platform.isAndroid) {
      await _health.requestHealthDataHistoryAuthorization();
    }
    return true;
  }

  /// Reads all [types] between [start] and [end], platform-deduplicated and
  /// reduced to numeric [HealthReading]s.
  Future<List<HealthReading>> read({
    required List<HealthDataType> types,
    required DateTime start,
    required DateTime end,
  }) async {
    final points = _health.removeDuplicates(
      await _health.getHealthDataFromTypes(types: types, startTime: start, endTime: end),
    );
    return points.map(HealthReading.fromDataPoint).whereType<HealthReading>().toList();
  }
}
