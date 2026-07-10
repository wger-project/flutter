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
import 'package:wger/features/measurements/models/measurement_category.dart';

/// A body metric that can be imported from Apple Health / Health Connect into a
/// measurement category.
///
/// [metricType] is stored on the created category; it drives the mapping back
/// to a category on the next import.
class HealthMetric {
  const HealthMetric({
    required this.metricType,
    required this.dataType,
    required this.canonicalName,
    required this.unit,
    required this.toCategoryValue,
    this.enabled = false,
    this.disabledReason,
  });

  /// Metric type stored on the category, e.g. [MetricType.bodyFat].
  final MetricType metricType;

  /// Health platform type this metric reads.
  final HealthDataType dataType;

  /// Stable, non-localized category name. Used to find-or-create the category,
  /// and as the fallback match for a category the user already created by hand
  /// (which carries [MetricType.custom], not this metric's type).
  final String canonicalName;

  /// Unit the value is stored in on the category.
  final String unit;

  /// Converts the platform's numeric value (in its native unit) into [unit].
  final double Function(double raw) toCategoryValue;

  /// Whether V1 imports this metric. Disabled ones are declared for visibility
  /// and blocked on further groundwork (see [disabledReason]).
  final bool enabled;

  /// Why a declared metric is not imported yet.
  final String? disabledReason;
}

/// Apple Health / Health Connect report body fat as a fraction on iOS (0.15)
/// but as a percentage on Health Connect (15). A real body fat percentage is
/// never below ~1.5, and a fraction is always below 1, so the magnitude tells
/// the two apart without branching on platform.
double _bodyFatToPercent(double raw) => raw <= 1.5 ? raw * 100 : raw;

/// Height is reported in meters on both platforms (~1.75). Guard against a
/// value that already arrived in centimeters.
double _heightToCm(double raw) => raw < 3 ? raw * 100 : raw;

double _identity(double raw) => raw;

/// The V1 metric set (see `plan-measurements-health-v27.md`).
///
/// Only [HealthMetric.enabled] entries are imported. The rest are declared so
/// the mapping is visible in one place; each is blocked on groundwork noted in
/// its [HealthMetric.disabledReason].
const List<HealthMetric> healthMetrics = [
  HealthMetric(
    metricType: MetricType.bodyFat,
    dataType: HealthDataType.BODY_FAT_PERCENTAGE,
    canonicalName: 'Body fat',
    unit: '%',
    toCategoryValue: _bodyFatToPercent,
    enabled: true,
  ),
  HealthMetric(
    metricType: MetricType.height,
    dataType: HealthDataType.HEIGHT,
    canonicalName: 'Height',
    unit: 'cm',
    toCategoryValue: _heightToCm,
    enabled: true,
  ),
  HealthMetric(
    metricType: MetricType.bodyWeight,
    dataType: HealthDataType.WEIGHT,
    canonicalName: 'Weight',
    unit: 'kg',
    toCategoryValue: _identity,
    disabledReason:
        'Body weight lives in its own feature until the '
        'weight/measurements merge (metric_type=body_weight).',
  ),
  HealthMetric(
    metricType: MetricType.bloodPressure,
    dataType: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    canonicalName: 'Blood pressure',
    unit: 'mmHg',
    toCategoryValue: _identity,
    disabledReason: 'Needs measurement grouping to pair systolic/diastolic.',
  ),
  HealthMetric(
    metricType: MetricType.heartRate,
    dataType: HealthDataType.HEART_RATE,
    canonicalName: 'Heart rate',
    unit: 'bpm',
    toCategoryValue: _identity,
    disabledReason: 'High-frequency; needs a per-day aggregation strategy.',
  ),
  HealthMetric(
    metricType: MetricType.steps,
    dataType: HealthDataType.STEPS,
    canonicalName: 'Steps',
    unit: 'count',
    toCategoryValue: _identity,
    disabledReason: 'High-volume cumulative type, parked behind a load test.',
  ),
];

/// The enabled subset that the importer actually pulls.
List<HealthMetric> get enabledHealthMetrics => healthMetrics.where((m) => m.enabled).toList();
