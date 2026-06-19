/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/date.dart';
import 'package:wger/widgets/measurements/charts.dart';

extension MeasurementChartEntryListExtensions on List<MeasurementChartEntry> {
  List<MeasurementChartEntry> whereDate(DateTime start, DateTime? end) {
    return where((e) => e.date.isAfter(start) && (end == null || e.date.isBefore(end))).toList();
  }

  // assures values on the start (and optionally end) dates exist, by interpolating if needed
  // this is used for when you are looking at a specific time frame (e.g. for a nutrition plan)
  // while gaps in the middle of a chart can be "visually interpolated", it's good to have a clearer
  // explicit interpolation for the start and end dates (if needed)
  // this also helps with computing delta's across the entire window
  List<MeasurementChartEntry> whereDateWithInterpolation(DateTime start, DateTime? end) {
    // Make sure our list is sorted by date
    // Avoid mutating the original list (it may be unmodifiable/const). Work on a copy.
    final List<MeasurementChartEntry> sorted = [...this];
    sorted.sort((a, b) => a.date.compareTo(b.date));

    // Initialize result list
    final List<MeasurementChartEntry> result = [];

    // Check if we have any entries on the same day as start/end
    bool hasEntryOnStartDay = false;
    bool hasEntryOnEndDay = false;

    // Track entries for potential interpolation
    MeasurementChartEntry? lastBeforeStart;
    MeasurementChartEntry? lastBeforeEnd;

    // Single pass through the data
    for (final entry in sorted) {
      if (entry.date.isSameDayAs(start)) {
        hasEntryOnStartDay = true;
      }
      if (end != null && entry.date.isSameDayAs(end)) {
        hasEntryOnEndDay = true;
      }

      if (end != null && entry.date.isBefore(end)) {
        lastBeforeEnd = entry;
      }

      if (entry.date.isBefore(start)) {
        lastBeforeStart = entry;
      } else {
        // insert interpolated start value if needed
        if (!hasEntryOnStartDay && lastBeforeStart != null) {
          result.insert(0, interpolateBetween(lastBeforeStart, entry, start));
          hasEntryOnStartDay = true;
        }

        if (end == null || entry.date.isBefore(end)) {
          result.add(entry);
        }
        if (end != null && entry.date.isAfter(end)) {
          // insert interpolated end value if needed
          // note: we only interpolate end if we have data going beyond end
          // if let's say your plan ends in a week from now, we wouldn't want to fake data until next week.
          if (!hasEntryOnEndDay && lastBeforeEnd != null) {
            result.add(interpolateBetween(lastBeforeEnd, entry, end));
            hasEntryOnEndDay = true;
          }
          // we added all our values and did all interpolations
          // surely all input values from here on are irrelevant.
          return result;
        }
      }
    }
    return result;
  }
}

// caller needs to make sure that before.date < date < after.date
MeasurementChartEntry interpolateBetween(
  MeasurementChartEntry before,
  MeasurementChartEntry after,
  DateTime date,
) {
  final totalDuration = after.date.difference(before.date).inMilliseconds;
  final startDuration = date.difference(before.date).inMilliseconds;

  // Create a special DateTime with milliseconds ending in 123 to mark it as interpolated
  // which we leverage in the UI
  final markedDate = DateTime(
    date.year,
    date.month,
    date.day,
    date.hour,
    date.minute,
    date.second,
    INTERPOLATION_MARKER,
  );

  return MeasurementChartEntry(
    before.value + (after.value - before.value) * (startDuration / totalDuration),
    markedDate,
  );
}
