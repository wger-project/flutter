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

/// Timeline a single platform query covers unless the metric says otherwise,
/// see [HealthMetric.readWindow].
const defaultReadWindow = Duration(days: 30);

/// Query window for the metrics a wearable writes continuously.
///
/// Measured on a Pixel 7 Pro with a watch worn daily: a week of heart rate
/// peaked at 134 MB of a 256 MB heap, i.e. half the budget for a history that
/// is not unusually dense. Three days leave room for someone recording several
/// times as densely, and cost almost nothing: the windows before the first
/// record return in about 6 ms each, and the ones with data take as long as
/// their data does, however it is sliced.
const highVolumeReadWindow = Duration(days: 3);

/// How a day's samples are condensed into the single value stored for it.
enum DailyAggregation {
  /// The day's mean, e.g. heart rate.
  average,

  /// The day's total, for cumulative counters like steps.
  sum,

  /// The time the day's samples cover, overlapping ones counted once, e.g.
  /// sleep. Adding the durations up instead would double-count a night that
  /// two sources both reported (a phone writing undifferentiated sleep while
  /// a watch writes the stages of the very same night).
  mergedDuration,
}

/// A body metric that can be imported from Apple Health / Health Connect into a
/// measurement category.
///
/// [metricType] is stored on the created category; it drives the mapping back
/// to a category on the next import.
class HealthMetric {
  const HealthMetric({
    required this.metricType,
    required HealthDataType this.dataType,
    required this.toCategoryValue,
    this.dailyAggregation,
    this.dayRollsOverAtHour,
    this.enabled = false,
    this.disabledReason,
    this.readWindow = defaultReadWindow,
  }) : components = const [];

  /// A metric whose readings are split over several categories, e.g. blood
  /// pressure. It has no platform type of its own: what it reads is what its
  /// [components] read.
  const HealthMetric.group({
    required this.metricType,
    required this.components,
    required this.toCategoryValue,
    this.dailyAggregation,
    this.dayRollsOverAtHour,
    this.enabled = false,
    this.disabledReason,
    this.readWindow = defaultReadWindow,
  }) : dataType = null;

  /// Metric type stored on the category, e.g. [MetricType.bodyFat].
  final MetricType metricType;

  /// Health platform type this metric reads, null for a group, whose
  /// components carry theirs.
  final HealthDataType? dataType;

  /// Name and unit the category is created under. They belong to the metric
  /// type, so a category the user creates by hand looks the same.
  String get canonicalName => metricType.canonicalName;

  String get unit => metricType.defaultUnit;

  /// Converts the platform's numeric value (in its native unit) into [unit].
  final double Function(double raw) toCategoryValue;

  /// Components of a multi-value metric. Non-empty marks the metric as a
  /// group: readings go into one child category per component, matched by
  /// in-group position (this list's order), and the group category itself
  /// stays measurement-free.
  final List<HealthMetricComponent> components;

  /// How samples are condensed into one entry per day. `null` imports every
  /// sample as its own entry. Set for metrics whose individual samples are
  /// not meaningful on their own (high-frequency ones like heart rate, or
  /// segmented ones like sleep); re-reads then update the day in place as
  /// further samples arrive.
  final DailyAggregation? dailyAggregation;

  /// Hour at which a sample starts counting towards the *next* calendar day.
  /// Sleep is attributed to the day the user wakes up, so a night starting at
  /// 23:30 belongs to the following day. `null` buckets by plain calendar day.
  final int? dayRollsOverAtHour;

  /// Whether V1 imports this metric. Disabled ones are declared for visibility
  /// and blocked on further groundwork (see [disabledReason]).
  final bool enabled;

  /// Why a declared metric is not imported yet.
  final String? disabledReason;

  /// How much of the timeline one platform query may cover for this metric.
  ///
  /// The plugin materialises every record it reads and then serialises the
  /// whole batch for the method channel, so the query size decides the peak
  /// memory, against an Android app heap capped at 256 MB. A scale writes a
  /// handful of values a month, a watch writes heart rate around the clock:
  /// measured on a real device, a month of heart rate needs ~240 MB, a week
  /// well under a hundred.
  final Duration readWindow;

  /// All platform types this metric reads (the components' for a group), each
  /// one once even when several components read it.
  List<HealthDataType> get dataTypes {
    final type = dataType;
    return type != null ? [type] : components.expand((c) => c.dataTypes).toSet().toList();
  }
}

/// One component of a multi-value metric (e.g. systolic), imported into its
/// own child category of the group.
class HealthMetricComponent {
  const HealthMetricComponent({required this.dataTypes});

  /// Health platform types this component reads. More than one where the
  /// component is a roll-up of several platform types, e.g. total sleep.
  final List<HealthDataType> dataTypes;
}

/// Apple Health / Health Connect report body fat as a fraction on iOS (0.15)
/// but as a percentage on Health Connect (15). A real body fat percentage is
/// never below ~1.5, and a fraction is always below 1, so the magnitude tells
/// the two apart without branching on platform.
double _bodyFatToPercent(double raw) => raw <= 1.5 ? raw * 100 : raw;

/// Height is reported in meters on both platforms (~1.75). Guard against a
/// value that already arrived in centimeters.
double _heightToCm(double raw) => raw < 3 ? raw * 100 : raw;

/// Blood oxygen has the same fraction-vs-percent split as body fat, with even
/// more room between the two: a saturation worth recording is above 70, a
/// fraction never reaches 1.01.
double _saturationToPercent(double raw) => raw <= 1.5 ? raw * 100 : raw;

double _identity(double raw) => raw;

/// Both platforms report a distance in meters, the category stores kilometers.
double _metersToKm(double raw) => raw / 1000;

/// The V1 metric set (see `plan-measurements-health-v27.md`).
///
/// Only [HealthMetric.enabled] entries are imported. A disabled one stays
/// declared so the mapping is visible in one place, with the groundwork it
/// waits for in its [HealthMetric.disabledReason].
const List<HealthMetric> healthMetrics = [
  HealthMetric(
    metricType: MetricType.bodyFat,
    dataType: HealthDataType.BODY_FAT_PERCENTAGE,
    toCategoryValue: _bodyFatToPercent,
    enabled: true,
  ),
  HealthMetric(
    metricType: MetricType.height,
    dataType: HealthDataType.HEIGHT,
    toCategoryValue: _heightToCm,
    enabled: true,
  ),
  HealthMetric(
    metricType: MetricType.bodyWeight,
    dataType: HealthDataType.WEIGHT,
    toCategoryValue: _identity,
    enabled: true,
  ),
  HealthMetric.group(
    metricType: MetricType.bloodPressure,
    toCategoryValue: _identity,
    // Both platforms report mmHg; a reading is the systolic/diastolic pair
    // sharing one timestamp.
    components: [
      HealthMetricComponent(
        dataTypes: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
      ),
      HealthMetricComponent(
        dataTypes: [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
      ),
    ],
    enabled: true,
  ),
  HealthMetric(
    metricType: MetricType.heartRate,
    dataType: HealthDataType.HEART_RATE,
    toCategoryValue: _identity,
    dailyAggregation: DailyAggregation.average,
    enabled: true,
    readWindow: highVolumeReadWindow,
  ),
  HealthMetric(
    // Both platforms compute this themselves and write (typically) one value
    // per day, so it is imported raw: no aggregation on our side, and the
    // platform record uuid stays available for dedup.
    metricType: MetricType.restingHeartRate,
    dataType: HealthDataType.RESTING_HEART_RATE,
    toCategoryValue: _identity,
    enabled: true,
  ),
  HealthMetric(
    // A single saturation says little on its own, and a wearable measures it
    // through the night, so the day's mean is what is stored. The window is
    // the small one until the log says how densely it actually arrives.
    metricType: MetricType.bloodOxygen,
    dataType: HealthDataType.BLOOD_OXYGEN,
    toCategoryValue: _saturationToPercent,
    dailyAggregation: DailyAggregation.average,
    enabled: true,
    readWindow: highVolumeReadWindow,
  ),
  HealthMetric.group(
    // SLEEP_ASLEEP is not the whole night, it is the coarsest stage: the
    // plugin filters it down to HealthKit's asleepUnspecified and to Health
    // Connect's STAGE_TYPE_SLEEPING. Anything writing a real hypnogram (an
    // Apple Watch, Samsung Health, Fitbit) writes light/deep/REM instead, so
    // reading only SLEEP_ASLEEP imports nothing for exactly those users. The
    // total therefore rolls the stages up, and each stage also gets its own
    // category. All types report minutes on both platforms.
    metricType: MetricType.sleep,
    toCategoryValue: _identity,
    components: [
      HealthMetricComponent(
        dataTypes: [
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_REM,
        ],
      ),
      HealthMetricComponent(
        dataTypes: [HealthDataType.SLEEP_LIGHT],
      ),
      HealthMetricComponent(dataTypes: [HealthDataType.SLEEP_DEEP]),
      HealthMetricComponent(dataTypes: [HealthDataType.SLEEP_REM]),
      // Time awake during the night completes the picture but is not sleep,
      // so it stays out of the total above
      HealthMetricComponent(dataTypes: [HealthDataType.SLEEP_AWAKE]),
    ],
    dailyAggregation: DailyAggregation.mergedDuration,
    dayRollsOverAtHour: 18,
    enabled: true,
  ),
  // The three cumulative types below are counters, not measurements: a single
  // record covers a few minutes and means nothing on its own, so only the
  // day's total is stored. Both platforms can aggregate them themselves, which
  // would replace the raw read with one row per day; until the importer has
  // that path, they are read raw in small windows and summed here.
  HealthMetric(
    metricType: MetricType.steps,
    dataType: HealthDataType.STEPS,
    toCategoryValue: _identity,
    dailyAggregation: DailyAggregation.sum,
    enabled: true,
    readWindow: highVolumeReadWindow,
  ),
  HealthMetric(
    metricType: MetricType.distance,
    dataType: HealthDataType.DISTANCE_DELTA,
    toCategoryValue: _metersToKm,
    dailyAggregation: DailyAggregation.sum,
    enabled: true,
    readWindow: highVolumeReadWindow,
  ),
  HealthMetric(
    // Active energy only: the basal part is a platform estimate the user never
    // recorded, and adding it in would make the day's number depend on which
    // platform wrote it.
    metricType: MetricType.energy,
    dataType: HealthDataType.ACTIVE_ENERGY_BURNED,
    toCategoryValue: _identity,
    dailyAggregation: DailyAggregation.sum,
    enabled: true,
    readWindow: highVolumeReadWindow,
  ),
];

/// The enabled subset that the importer actually pulls.
List<HealthMetric> get enabledHealthMetrics => healthMetrics.where((m) => m.enabled).toList();

/// Every platform data type the enabled metrics are made of, i.e. what
/// permissions are asked for and what is checked as readable.
List<HealthDataType> get enabledHealthDataTypes =>
    enabledHealthMetrics.expand((m) => m.dataTypes).toList();
