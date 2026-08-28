/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

/// The calendar rules of a daily aggregate: which day a sample counts towards
/// when the metric rolls over (sleep lands on the day the user wakes up),
/// where a read window has to start so a day is never recomputed from a
/// fraction of itself, and how overlapping samples add up.
library;

import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/health/models/health_reading.dart';

/// The time [samples] cover in minutes, counting overlapping stretches once.
///
/// Adding the durations up would report a night twice when two sources both
/// recorded it, which is the normal case for sleep: a phone writes the night
/// as undifferentiated sleep while a watch writes the same night as its
/// stages. A sample without an end is taken to last as long as its value
/// says.
double mergedDurationMinutes(Iterable<HealthReading> samples) {
  final intervals =
      samples
          .map(
            (r) => (
              r.date,
              r.dateTo ?? r.date.add(Duration(microseconds: (r.value * 60 * 1000000).round())),
            ),
          )
          .toList()
        ..sort((a, b) => a.$1.compareTo(b.$1));

  var total = Duration.zero;
  DateTime? start;
  DateTime? end;
  for (final (from, to) in intervals) {
    if (end == null || from.isAfter(end)) {
      if (start != null) {
        total += end!.difference(start);
      }
      start = from;
      end = to;
      continue;
    }
    if (to.isAfter(end)) {
      end = to;
    }
  }
  if (start != null) {
    total += end!.difference(start);
  }
  return total.inMicroseconds / Duration.microsecondsPerMinute;
}

/// Where the read window starts for [metric].
///
/// A daily aggregate is recomputed from what the window returns, so a start
/// inside a day would overwrite it with a fraction of it.
DateTime windowStartFor(DateTime start, HealthMetric metric) {
  if (metric.dailyAggregation == null) {
    return start;
  }

  final rollover = metric.dayRollsOverAtHour;
  if (rollover == null) {
    return DateTime(start.year, start.month, start.day);
  }

  // Before the rollover hour the current day began on the previous one
  final dayBegan = start.hour >= rollover ? start.day : start.day - 1;
  return DateTime(start.year, start.month, dayBegan, rollover);
}

/// The day a sample is attributed to. Plain calendar day, unless the metric
/// rolls over: samples at or after [HealthMetric.dayRollsOverAtHour] then
/// count towards the next day, so a night of sleep lands on the day the user
/// wakes up instead of being split at midnight.
DateTime dayOf(DateTime date, HealthMetric metric) {
  final rollover = metric.dayRollsOverAtHour;
  final rollsOver = rollover != null && date.hour >= rollover;

  // Calendar arithmetic, not +24h: a DST day is 23 or 25 hours long
  return DateTime(date.year, date.month, date.day + (rollsOver ? 1 : 0));
}

/// The first instant no longer attributed to [day], i.e. from when on no
/// later read window can add samples to it.
DateTime dayEnd(DateTime day, HealthMetric metric) {
  final rollover = metric.dayRollsOverAtHour;
  return rollover == null
      ? DateTime(day.year, day.month, day.day + 1)
      : DateTime(day.year, day.month, day.day, rollover);
}

DateTime earlier(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

DateTime later(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
