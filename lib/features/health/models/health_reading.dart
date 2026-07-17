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

import 'package:health_bridge/health.dart';

/// A single reading pulled from a health platform, reduced to the fields the
/// importer needs. Keeps the `health` package's [HealthDataPoint] out of the
/// notifier so the sync logic can be tested with plain values.
class HealthReading {
  const HealthReading({
    required this.type,
    required this.value,
    required this.date,
    this.externalId,
  });

  /// The platform type this reading belongs to (matched against
  /// `HealthMetric.dataType`).
  final HealthDataType type;

  /// Numeric value in the platform's native unit.
  final double value;

  /// Start of the reading.
  final DateTime date;

  /// Platform record UUID for deduplication; `null` when the platform gives none.
  final String? externalId;

  /// Builds a reading from a platform data point, or `null` for a non-numeric
  /// point (which the importer cannot store).
  static HealthReading? fromDataPoint(HealthDataPoint point) {
    final value = point.value;
    if (value is! NumericHealthValue) {
      return null;
    }
    return HealthReading(
      type: point.type,
      value: value.numericValue.toDouble(),
      date: point.dateFrom,
      externalId: point.uuid.isEmpty ? null : point.uuid,
    );
  }
}
