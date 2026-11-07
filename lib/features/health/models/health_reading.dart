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
    this.unit = HealthDataUnit.NO_UNIT,
    this.dateTo,
    this.recordingMethod = RecordingMethod.unknown,
    this.sourceName,
    this.sourceId,
    this.deviceModel,
    this.sourceDeviceId,
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

  /// Unit [value] is reported in by the platform.
  final HealthDataUnit unit;

  /// End of the reading's interval; `null` when it equals [date] (a sample
  /// rather than a duration record).
  final DateTime? dateTo;

  /// How the platform recorded the point (manual entry, automatic, ...).
  final RecordingMethod recordingMethod;

  /// Human-readable source ("Withings Body+"); `null` when not reported.
  final String? sourceName;

  /// Bundle id of the app that wrote the point; `null` when not reported.
  final String? sourceId;

  /// Recording device ("Watch"), iOS only; `null` elsewhere.
  final String? deviceModel;

  /// Device identifier; `null` when not reported.
  final String? sourceDeviceId;

  /// Builds a reading from a platform data point, or `null` for a non-numeric
  /// point (which the importer cannot store).
  static HealthReading? fromDataPoint(HealthDataPoint point) {
    final value = point.value;
    if (value is! NumericHealthValue) {
      return null;
    }
    String? nonEmpty(String? s) => (s == null || s.isEmpty) ? null : s;

    return HealthReading(
      type: point.type,
      value: value.numericValue.toDouble(),
      date: point.dateFrom,
      // HealthKit reports UUIDs in uppercase, but the server's UUIDField
      // normalizes to lowercase. Lowercase here so the dedup key stays stable
      // once the entry round-trips through the server.
      externalId: point.uuid.isEmpty ? null : point.uuid.toLowerCase(),
      unit: point.unit,
      dateTo: point.dateTo == point.dateFrom ? null : point.dateTo,
      recordingMethod: point.recordingMethod,
      sourceName: nonEmpty(point.sourceName),
      sourceId: nonEmpty(point.sourceId),
      deviceModel: nonEmpty(point.deviceModel),
      sourceDeviceId: nonEmpty(point.sourceDeviceId),
    );
  }
}
