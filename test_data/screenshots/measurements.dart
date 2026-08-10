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

import 'dart:math';

import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';

/// Measurement categories for the store screenshots: the account of someone
/// syncing daily, shaped like a health import, plus a hand-kept tape measure.
/// Three months of data ending today, so every tile of the overview grid has
/// something to show: the weight card on top, each spark form (line, dots,
/// bars, floating, stack, heatmap) and both footer kinds exactly once.
/// Deterministic (fixed random seed); only the dates move with today.
///
/// The categories come as the flat parent-first list the repository emits,
/// with the group's children attached to their parent; the entries alongside
/// them, keyed by the category holding them, since a category carries none.
({List<MeasurementCategory> categories, Map<String, List<MeasurementEntry>> entries})
getScreenshotMeasurements() {
  final random = Random(7);
  final today = DateTime.now();
  DateTime day(int daysAgo, {int hour = 0, int minute = 0}) =>
      DateTime(today.year, today.month, today.day - daysAgo, hour, minute);

  MeasurementEntry entry(
    String categoryId,
    Object key,
    num value,
    DateTime date, {
    String source = 'apple_health',
  }) => MeasurementEntry(
    id: '$categoryId-$key',
    categoryId: categoryId,
    value: value,
    date: date,
    notes: '',
    source: source,
  );

  // Body weight: the morning weigh-in, slowly losing. Feeds the full-width
  // card on top of the grid, not a tile.
  final weightEntries = <MeasurementEntry>[];
  for (var daysAgo = 90; daysAgo >= 0; daysAgo--) {
    final value = 84.2 - 0.02 * (90 - daysAgo) + (random.nextDouble() - 0.5) * 0.5;
    weightEntries.add(
      entry(
        'screenshot-weight',
        daysAgo,
        (value * 10).round() / 10,
        day(daysAgo, hour: 7, minute: 2),
        source: 'user',
      ),
    );
  }
  final weight = MeasurementCategory(
    id: 'screenshot-weight',
    name: 'Weight',
    unit: 'kg',
    metricType: MetricType.bodyWeight,
    isOfficial: true,
  );

  // Steps: quiet office days, active days, and the occasional long hike
  final stepEntries = <MeasurementEntry>[];
  for (var daysAgo = 90; daysAgo >= 0; daysAgo--) {
    final roll = random.nextDouble();
    final int steps;
    if (roll < 0.1) {
      steps = 15000 + random.nextInt(4000);
    } else if (roll < 0.5) {
      steps = 8500 + random.nextInt(3500);
    } else {
      steps = 4500 + random.nextInt(3000);
    }
    stepEntries.add(entry('screenshot-steps', daysAgo, steps, day(daysAgo, hour: 22)));
  }
  final steps = MeasurementCategory(
    id: 'screenshot-steps',
    name: 'Steps',
    unit: 'count',
    metricType: MetricType.steps,
    isOfficial: true,
  );

  // Blood pressure: a morning reading every two to three days, slowly
  // improving. Systolic and diastolic share their timestamp, which is how
  // the components of a reading are paired.
  final systolicEntries = <MeasurementEntry>[];
  final diastolicEntries = <MeasurementEntry>[];
  for (var daysAgo = 90; daysAgo >= 0; daysAgo -= 2 + random.nextInt(2)) {
    final date = day(daysAgo, hour: 8, minute: 5);
    final systolic = (123 + 11 * daysAgo / 90 + (random.nextDouble() - 0.5) * 8).roundToDouble();
    final diastolic = (systolic - 46 + (random.nextDouble() - 0.5) * 6).roundToDouble();
    systolicEntries.add(entry('screenshot-sys', daysAgo, systolic, date));
    diastolicEntries.add(entry('screenshot-dia', daysAgo, diastolic, date));
  }
  final systolic = MeasurementCategory(
    id: 'screenshot-sys',
    name: 'Systolic',
    unit: 'mmHg',
    metricType: MetricType.bloodPressureSystolic,
    parentId: 'screenshot-bp',
    order: 0,
  );
  final diastolic = MeasurementCategory(
    id: 'screenshot-dia',
    name: 'Diastolic',
    unit: 'mmHg',
    metricType: MetricType.bloodPressureDiastolic,
    parentId: 'screenshot-bp',
    order: 1,
  );
  final bloodPressure = MeasurementCategory(
    id: 'screenshot-bp',
    name: 'Blood pressure',
    unit: 'mmHg',
    metricType: MetricType.bloodPressure,
    isOfficial: true,
    children: [systolic, diastolic],
  );

  // Body fat: measured with the weigh-in, falling steadily. The line tile
  // with a downward weekly-rate chip.
  final bodyFatEntries = <MeasurementEntry>[];
  for (var daysAgo = 90; daysAgo >= 0; daysAgo--) {
    final value = 21.8 - 0.03 * (90 - daysAgo) + (random.nextDouble() - 0.5) * 0.3;
    bodyFatEntries.add(
      entry('screenshot-fat', daysAgo, (value * 10).round() / 10, day(daysAgo, hour: 7, minute: 3)),
    );
  }
  final bodyFat = MeasurementCategory(
    id: 'screenshot-fat',
    name: 'Body fat',
    unit: '%',
    metricType: MetricType.bodyFat,
  );

  // Resting heart rate: barely moves. The line tile with the "stable" chip.
  final restingEntries = <MeasurementEntry>[];
  for (var daysAgo = 90; daysAgo >= 0; daysAgo--) {
    restingEntries.add(
      entry(
        'screenshot-rhr',
        daysAgo,
        (58 + (random.nextDouble() - 0.5) * 2).roundToDouble(),
        day(daysAgo, hour: 6, minute: 45),
      ),
    );
  }
  final restingHeartRate = MeasurementCategory(
    id: 'screenshot-rhr',
    name: 'Resting heart rate',
    unit: 'bpm',
    metricType: MetricType.restingHeartRate,
  );

  // Sleep: a night per day, split into stages; the total leads the tile
  // ("7:12" for the last night) over the stacked stage bars
  final sleepTotalEntries = <MeasurementEntry>[];
  final sleepLightEntries = <MeasurementEntry>[];
  final sleepDeepEntries = <MeasurementEntry>[];
  final sleepRemEntries = <MeasurementEntry>[];
  for (var daysAgo = 90; daysAgo >= 0; daysAgo--) {
    final light = daysAgo == 0 ? 240 : 220 + random.nextInt(60) - 30;
    final deep = daysAgo == 0 ? 90 : 95 + random.nextInt(30) - 15;
    final rem = daysAgo == 0 ? 102 : 105 + random.nextInt(30) - 15;
    final date = day(daysAgo, hour: 7);

    sleepTotalEntries.add(entry('screenshot-sleep-total', daysAgo, light + deep + rem, date));
    sleepLightEntries.add(entry('screenshot-sleep-light', daysAgo, light, date));
    sleepDeepEntries.add(entry('screenshot-sleep-deep', daysAgo, deep, date));
    sleepRemEntries.add(entry('screenshot-sleep-rem', daysAgo, rem, date));
  }
  final sleepChildren = [
    MeasurementCategory(
      id: 'screenshot-sleep-total',
      name: 'Total sleep',
      unit: 'min',
      metricType: MetricType.sleepTotal,
      parentId: 'screenshot-sleep',
      order: 0,
    ),
    MeasurementCategory(
      id: 'screenshot-sleep-light',
      name: 'Light sleep',
      unit: 'min',
      metricType: MetricType.sleepLight,
      parentId: 'screenshot-sleep',
      order: 1,
    ),
    MeasurementCategory(
      id: 'screenshot-sleep-deep',
      name: 'Deep sleep',
      unit: 'min',
      metricType: MetricType.sleepDeep,
      parentId: 'screenshot-sleep',
      order: 2,
    ),
    MeasurementCategory(
      id: 'screenshot-sleep-rem',
      name: 'REM sleep',
      unit: 'min',
      metricType: MetricType.sleepRem,
      parentId: 'screenshot-sleep',
      order: 3,
    ),
  ];
  final sleep = MeasurementCategory(
    id: 'screenshot-sleep',
    name: 'Sleep',
    unit: 'min',
    metricType: MetricType.sleep,
    isOfficial: true,
    children: sleepChildren,
  );

  // Distance: configured as a heatmap, so the tile answers how regularly
  // rather than how much; the rest days stay visible as gaps
  final distanceEntries = <MeasurementEntry>[];
  for (var daysAgo = 90; daysAgo >= 0; daysAgo--) {
    if (random.nextDouble() < 0.3) {
      continue;
    }
    distanceEntries.add(
      entry(
        'screenshot-distance',
        daysAgo,
        ((2 + random.nextDouble() * 9) * 100).round() / 100,
        day(daysAgo, hour: 21),
      ),
    );
  }
  final distance = MeasurementCategory(
    id: 'screenshot-distance',
    name: 'Distance',
    unit: 'km',
    metricType: MetricType.distance,
    chartType: ChartType.heatmap,
  );

  // Biceps: the hand-kept tape measure, taken every few weeks. The sparse
  // tile (dots, last-measured date) and the one entry of the quick-add menu.
  final bicepsEntries = <MeasurementEntry>[];
  final bicepsReadings = [(88, 37.6), (67, 37.9), (46, 38.1), (28, 38.3), (21, 38.5)];
  for (final (daysAgo, value) in bicepsReadings) {
    bicepsEntries.add(
      entry('screenshot-biceps', daysAgo, value, day(daysAgo, hour: 9), source: 'user'),
    );
  }
  final biceps = MeasurementCategory(id: 'screenshot-biceps', name: 'Biceps', unit: 'cm');

  return (
    categories: [
      weight,
      bloodPressure,
      systolic,
      diastolic,
      bodyFat,
      restingHeartRate,
      sleep,
      ...sleepChildren,
      steps,
      distance,
      biceps,
    ],
    entries: {
      weight.id!: weightEntries,
      systolic.id!: systolicEntries,
      diastolic.id!: diastolicEntries,
      bodyFat.id!: bodyFatEntries,
      restingHeartRate.id!: restingEntries,
      'screenshot-sleep-total': sleepTotalEntries,
      'screenshot-sleep-light': sleepLightEntries,
      'screenshot-sleep-deep': sleepDeepEntries,
      'screenshot-sleep-rem': sleepRemEntries,
      steps.id!: stepEntries,
      distance.id!: distanceEntries,
      biceps.id!: bicepsEntries,
    },
  );
}
