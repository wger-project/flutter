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
import 'package:wger/features/nutrition/models/nutritional_plan.dart';

import '../body_weight.dart';

/// A year of body weight ending today, shaped like a real log: a slow drift
/// up, a successful cut over the period of [getScreenshotWeightPlans]' first
/// plan, a short maintenance phase, and a fresh cut under the active plan.
/// The cut and the active plan fall inside the last three months, so the
/// story is visible in every chart range.
///
/// Deterministic (fixed random seed); only the dates move with today.
MeasurementCategory getScreenshotBodyWeightCategory() {
  final random = Random(42);
  final today = DateTime.now();

  // Piecewise linear phases over the last year, oldest first
  double weightAt(int daysAgo) {
    double phase(int from, int to, double start, double end) =>
        start + (end - start) * (from - daysAgo) / (from - to);

    if (daysAgo > 100) {
      return phase(365, 100, 85.8, 87.5);
    }
    if (daysAgo > 75) {
      return phase(100, 75, 87.5, 87.6);
    }
    if (daysAgo > 25) {
      return phase(75, 25, 87.6, 82.5);
    }
    if (daysAgo > 10) {
      return phase(25, 10, 82.5, 82.9);
    }
    return phase(10, 0, 82.9, 82.3);
  }

  final entries = <MeasurementEntry>[];
  // Weigh-ins every two to three days, in the morning, with scale-level noise
  for (var daysAgo = 365; daysAgo >= 0; daysAgo -= 2 + random.nextInt(2)) {
    final value = weightAt(daysAgo) + (random.nextDouble() - 0.5) * 0.7;
    entries.add(
      MeasurementEntry(
        id: 'screenshot-weight-${entries.length}',
        categoryId: testBodyWeightCategoryId,
        value: double.parse(value.toStringAsFixed(1)),
        date: DateTime(today.year, today.month, today.day - daysAgo, 7, 30),
        notes: '',
      ),
    );
  }

  // newest first, matching the repository's watchAll() order
  return getBodyWeightCategory(entries.reversed.toList());
}

/// The nutrition plans behind the weight phases of
/// [getScreenshotBodyWeightCategory]: a finished cut covering the big drop
/// and a currently active plan. Shown as period bands in the weight chart.
List<NutritionalPlan> getScreenshotWeightPlans() {
  final today = DateTime.now();
  DateTime daysAgo(int days) => DateTime(today.year, today.month, today.day - days);

  return [
    NutritionalPlan(
      id: 'bb000000-0000-4000-8000-000000000001',
      description: 'Summer cut',
      startDate: daysAgo(75),
      endDate: daysAgo(25),
      onlyLogging: true,
    ),
    NutritionalPlan(
      id: 'bb000000-0000-4000-8000-000000000002',
      description: 'Mini cut',
      startDate: daysAgo(10),
      onlyLogging: true,
    ),
  ];
}
