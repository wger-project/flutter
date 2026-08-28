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

import 'package:flutter_test/flutter_test.dart';
import 'package:health_bridge/health.dart';
import 'package:wger/features/health/models/daily_windows.dart';
import 'package:wger/features/health/models/health_metric.dart';
import 'package:wger/features/health/models/health_reading.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';

HealthMetric _metric(MetricType type) => healthMetrics.firstWhere((m) => m.metricType == type);

/// A slept stretch, the shape the platforms deliver it in
HealthReading _asleep(DateTime from, DateTime to) => HealthReading(
  type: HealthDataType.SLEEP_ASLEEP,
  value: to.difference(from).inMinutes.toDouble(),
  date: from,
  dateTo: to,
);

void main() {
  // Sleep rolls over at 18:00 and merges its stretches, steps are a plain
  // calendar day, and a weigh-in is imported as the sample it is
  final sleep = _metric(MetricType.sleep);
  final steps = _metric(MetricType.steps);
  final bodyWeight = _metric(MetricType.bodyWeight);

  group('mergedDurationMinutes', () {
    test('nothing recorded is no time at all', () {
      expect(mergedDurationMinutes(const []), 0);
    });

    test('separate stretches add up', () {
      final minutes = mergedDurationMinutes([
        _asleep(DateTime(2026, 5, 4, 23), DateTime(2026, 5, 5, 1)),
        _asleep(DateTime(2026, 5, 5, 2), DateTime(2026, 5, 5, 4)),
      ]);

      expect(minutes, 240);
    });

    test('a night two sources recorded is counted once', () {
      // The phone writes the night as one stretch, the watch as its stages:
      // adding them up would report the night twice
      final minutes = mergedDurationMinutes([
        _asleep(DateTime(2026, 5, 4, 23), DateTime(2026, 5, 5, 7)),
        _asleep(DateTime(2026, 5, 4, 23), DateTime(2026, 5, 5, 1)),
        _asleep(DateTime(2026, 5, 5, 1), DateTime(2026, 5, 5, 7)),
      ]);

      expect(minutes, 8 * 60);
    });

    test('overlapping stretches count the union', () {
      final minutes = mergedDurationMinutes([
        _asleep(DateTime(2026, 5, 4, 23), DateTime(2026, 5, 5, 2)),
        _asleep(DateTime(2026, 5, 5, 1), DateTime(2026, 5, 5, 4)),
      ]);

      expect(minutes, 5 * 60);
    });

    test('the order they arrive in does not matter', () {
      final late = _asleep(DateTime(2026, 5, 5, 2), DateTime(2026, 5, 5, 4));
      final early = _asleep(DateTime(2026, 5, 4, 23), DateTime(2026, 5, 5, 1));

      expect(mergedDurationMinutes([late, early]), mergedDurationMinutes([early, late]));
    });

    test('a sample without an end lasts as long as its value says', () {
      final minutes = mergedDurationMinutes([
        HealthReading(
          type: HealthDataType.SLEEP_ASLEEP,
          value: 90,
          date: DateTime(2026, 5, 4, 23),
        ),
      ]);

      expect(minutes, 90);
    });
  });

  group('dayOf', () {
    test('a metric without a rollover counts the plain calendar day', () {
      expect(dayOf(DateTime(2026, 5, 4, 23, 30), steps), DateTime(2026, 5, 4));
      expect(dayOf(DateTime(2026, 5, 4, 0, 30), steps), DateTime(2026, 5, 4));
    });

    test('sleep counts towards the day the user wakes up', () {
      // A night starting at 23:30 belongs to the next day, one ending at 07:00
      // to the day it ends on: both are the same night
      expect(dayOf(DateTime(2026, 5, 4, 23, 30), sleep), DateTime(2026, 5, 5));
      expect(dayOf(DateTime(2026, 5, 5, 7), sleep), DateTime(2026, 5, 5));
    });

    test('the rollover hour itself already belongs to the next day', () {
      expect(dayOf(DateTime(2026, 5, 4, 18), sleep), DateTime(2026, 5, 5));
      expect(dayOf(DateTime(2026, 5, 4, 17, 59), sleep), DateTime(2026, 5, 4));
    });

    test('a rollover at the end of a month lands in the next one', () {
      expect(dayOf(DateTime(2026, 5, 31, 23), sleep), DateTime(2026, 6, 1));
    });
  });

  group('dayEnd', () {
    test('a plain day ends at the next midnight', () {
      expect(dayEnd(DateTime(2026, 5, 4), steps), DateTime(2026, 5, 5));
    });

    test('a rolled-over day ends at the rollover hour', () {
      // From 18:00 on, samples count towards the day after
      expect(dayEnd(DateTime(2026, 5, 4), sleep), DateTime(2026, 5, 4, 18));
    });
  });

  group('windowStartFor', () {
    test('a metric read sample by sample starts where it is asked to', () {
      final start = DateTime(2026, 5, 4, 13, 45);

      expect(windowStartFor(start, bodyWeight), start);
    });

    test('a daily aggregate starts at the beginning of its day', () {
      // The day is recomputed from what the window returns, so a start inside
      // it would overwrite the day with a fraction of itself
      expect(windowStartFor(DateTime(2026, 5, 4, 13, 45), steps), DateTime(2026, 5, 4));
    });

    test('a rolled-over day starts at the rollover of the day it began on', () {
      expect(windowStartFor(DateTime(2026, 5, 5, 3), sleep), DateTime(2026, 5, 4, 18));
      expect(windowStartFor(DateTime(2026, 5, 4, 23), sleep), DateTime(2026, 5, 4, 18));
    });
  });

  group('earlier and later', () {
    test('pick the one they say', () {
      final first = DateTime(2026, 5, 4);
      final second = DateTime(2026, 5, 5);

      expect(earlier(first, second), first);
      expect(earlier(second, first), first);
      expect(later(first, second), second);
      expect(later(second, first), second);
    });
  });
}
