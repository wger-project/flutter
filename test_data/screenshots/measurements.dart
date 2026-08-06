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

/// Measurement categories for the store screenshots: three months of daily
/// steps and of blood pressure readings, ending today, shaped like a health
/// import. Deterministic (fixed random seed); only the dates move with today.
///
/// The categories come as the flat parent-first list the repository emits,
/// with the group's children attached to their parent; the entries alongside
/// them, keyed by the category holding them, since a category carries none.
({List<MeasurementCategory> categories, Map<String, List<MeasurementEntry>> entries})
getScreenshotMeasurements() {
  final random = Random(7);
  final today = DateTime.now();

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
    stepEntries.add(
      MeasurementEntry(
        id: 'screenshot-steps-$daysAgo',
        categoryId: 'screenshot-steps',
        value: steps,
        date: DateTime(today.year, today.month, today.day - daysAgo, 22),
        notes: '',
        source: 'apple_health',
      ),
    );
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
    final date = DateTime(today.year, today.month, today.day - daysAgo, 8, 5);
    final systolic = (123 + 11 * daysAgo / 90 + (random.nextDouble() - 0.5) * 8).roundToDouble();
    final diastolic = (systolic - 46 + (random.nextDouble() - 0.5) * 6).roundToDouble();
    systolicEntries.add(
      MeasurementEntry(
        id: 'screenshot-sys-$daysAgo',
        categoryId: 'screenshot-sys',
        value: systolic,
        date: date,
        notes: '',
        source: 'apple_health',
      ),
    );
    diastolicEntries.add(
      MeasurementEntry(
        id: 'screenshot-dia-$daysAgo',
        categoryId: 'screenshot-dia',
        value: diastolic,
        date: date,
        notes: '',
        source: 'apple_health',
      ),
    );
  }

  final systolic = MeasurementCategory(
    id: 'screenshot-sys',
    name: 'Systolic',
    unit: 'mmHg',
    parentId: 'screenshot-bp',
    order: 0,
  );
  final diastolic = MeasurementCategory(
    id: 'screenshot-dia',
    name: 'Diastolic',
    unit: 'mmHg',
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

  return (
    categories: [steps, bloodPressure, systolic, diastolic],
    entries: {
      steps.id!: stepEntries.reversed.toList(),
      systolic.id!: systolicEntries.reversed.toList(),
      diastolic.id!: diastolicEntries.reversed.toList(),
    },
  );
}
