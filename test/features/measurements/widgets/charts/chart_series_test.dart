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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/widgets/charts/chart_series.dart';

void main() {
  MeasurementChartEntry entry(num value, DateTime date) => MeasurementChartEntry(value, date);

  group('MeasurementChartEntry', () {
    test('only counts as a range when both bounds are set', () {
      expect(entry(60, DateTime(2026, 1, 1)).hasRange, isFalse);
      expect(MeasurementChartEntry(60, DateTime(2026, 1, 1), min: 50).hasRange, isFalse);
      expect(
        MeasurementChartEntry(60, DateTime(2026, 1, 1), min: 50, max: 70).hasRange,
        isTrue,
      );
    });
  });

  group('clampPeriods', () {
    final bounds = DateTimeRange(start: DateTime(2026, 1, 10), end: DateTime(2026, 1, 20));

    test('keeps a period inside the bounds untouched', () {
      final period = DateTimeRange(start: DateTime(2026, 1, 12), end: DateTime(2026, 1, 15));
      expect(clampPeriods([period], bounds), [period]);
    });

    test('clamps overlapping periods to the bounds', () {
      final result = clampPeriods([
        DateTimeRange(start: DateTime(2026, 1, 1), end: DateTime(2026, 1, 12)),
        DateTimeRange(start: DateTime(2026, 1, 15), end: DateTime(2026, 2, 1)),
      ], bounds);

      expect(result, [
        DateTimeRange(start: DateTime(2026, 1, 10), end: DateTime(2026, 1, 12)),
        DateTimeRange(start: DateTime(2026, 1, 15), end: DateTime(2026, 1, 20)),
      ]);
    });

    test('drops periods outside the bounds, including touching ones', () {
      final result = clampPeriods([
        DateTimeRange(start: DateTime(2026, 1, 1), end: DateTime(2026, 1, 5)),
        // ends exactly at the bounds' start: zero width, nothing to draw
        DateTimeRange(start: DateTime(2026, 1, 1), end: DateTime(2026, 1, 10)),
        DateTimeRange(start: DateTime(2026, 2, 1), end: DateTime(2026, 2, 5)),
      ], bounds);

      expect(result, isEmpty);
    });
  });

  group('movingAverage', () {
    test('returns an empty list for no entries', () {
      expect(movingAverage([]), isEmpty);
    });

    test('averages over everything within the preceding 7 days', () {
      final result = movingAverage([
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 2)),
        entry(30, DateTime(2026, 1, 3)),
      ]);

      expect(result.map((e) => e.value), [10, 15, 20]);
      expect(result.map((e) => e.date), [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 3),
      ]);
    });

    test('drops points that fell out of the window', () {
      final result = movingAverage([
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 20)),
      ]);

      // the january 1st entry is far outside the 7 days before january 20th
      expect(result.last.value, 20);
    });

    test('sorts unordered input by date first', () {
      final result = movingAverage([
        entry(30, DateTime(2026, 1, 3)),
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 2)),
      ]);

      expect(result.map((e) => e.value), [10, 15, 20]);
    });

    test('stays accurate over a long dense series', () {
      // The window total is carried along rather than re-summed, so this
      // guards against drift piling up
      final result = movingAverage([
        for (var i = 0; i < 5000; i++) entry(100, DateTime(2026, 1, 1).add(Duration(minutes: i))),
      ]);

      expect(result.every((e) => (e.value - 100).abs() < 0.000001), isTrue);
    });

    test('a wider window reaches further back', () {
      final points = [
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 12)),
      ];

      // the january 1st entry is outside 7 days but inside 14
      expect(movingAverage(points, days: 7).last.value, 20);
      expect(movingAverage(points, days: 14).last.value, 15);
    });
  });

  group('aggregatePerDay', () {
    test('returns an empty list for no entries', () {
      expect(aggregatePerDay([]), isEmpty);
    });

    test('sums entries sharing a calendar day into one point', () {
      final result = aggregatePerDay([
        entry(1000, DateTime(2026, 1, 1, 8)),
        entry(2500, DateTime(2026, 1, 1, 20)),
      ]);

      expect(result.length, 1);
      expect(result.single.value, 3500);
      // time-of-day is stripped to the day boundary
      expect(result.single.date, DateTime(2026, 1, 1));
    });

    test('keeps separate days apart and sorts them ascending', () {
      final result = aggregatePerDay([
        entry(30, DateTime(2026, 1, 3)),
        entry(10, DateTime(2026, 1, 1, 6)),
        entry(5, DateTime(2026, 1, 1, 23)),
        entry(20, DateTime(2026, 1, 2)),
      ]);

      expect(result.map((e) => e.date), [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 3),
      ]);
      expect(result.map((e) => e.value), [15, 20, 30]);
    });
  });

  group('averagePerDay', () {
    test('returns an empty list for no entries', () {
      expect(averagePerDay([]), isEmpty);
    });

    test('averages entries sharing a calendar day into one point', () {
      final result = averagePerDay([
        entry(80, DateTime(2026, 1, 1, 8)),
        entry(82, DateTime(2026, 1, 1, 20)),
      ]);

      expect(result.single.value, 81);
      expect(result.single.date, DateTime(2026, 1, 1));
    });

    test('keeps separate days apart and sorts them ascending', () {
      final result = averagePerDay([
        entry(30, DateTime(2026, 1, 3)),
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 2)),
      ]);

      expect(result.map((e) => e.date), [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 3),
      ]);
      expect(result.map((e) => e.value), [10, 20, 30]);
    });
  });

  group('weeklyDeltas', () {
    // 5 January 2026 is a Monday
    final monday = DateTime(2026, 1, 5);
    DateTime week(int index) => monday.add(Duration(days: 7 * index));

    test('returns an empty list for no entries', () {
      expect(weeklyDeltas([]), isEmpty);
    });

    test('has no bar for a single week, which has nothing to compare against', () {
      expect(
        weeklyDeltas([entry(80, monday), entry(81, monday.add(const Duration(days: 2)))]),
        isEmpty,
      );
    });

    test('subtracts the previous week, dated on the week it belongs to', () {
      final result = weeklyDeltas([
        entry(80, monday),
        entry(79, week(1)),
        entry(79.5, week(2)),
      ]);

      expect(result.map((e) => e.date), [week(1), week(2)]);
      expect(result.map((e) => e.value), [-1, 0.5]);
    });

    test('compares the weeks by their average, not by single readings', () {
      // the low reading is an outlier within its week and must not decide the bar
      final result = weeklyDeltas([
        entry(80, monday),
        entry(82, monday.add(const Duration(days: 3))),
        entry(75, week(1)),
        entry(87, week(1).add(const Duration(days: 3))),
      ]);

      expect(result.single.value, 0);
    });

    test('sums the weeks of a metric that is read as a total', () {
      final result = weeklyDeltas([
        entry(3000, monday),
        entry(4000, monday.add(const Duration(days: 1))),
        entry(9000, week(1)),
      ], summed: true);

      expect(result.single.value, 2000);
    });

    test('takes the week after a gap against the last week that has readings', () {
      final result = weeklyDeltas([entry(80, monday), entry(77, week(3))]);

      // one bar on the week that was measured, holding the whole change, so the
      // bars still add up to the change across the range
      expect(result.single.date, week(3));
      expect(result.single.value, -3);
    });

    test('sorts unordered input by week first', () {
      final result = weeklyDeltas([entry(79, week(1)), entry(80, monday)]);

      expect(result.single.value, -1);
    });

    test('leaves the running week out of a summed metric', () {
      // its total is still growing and would read as a drop until Sunday
      final result = weeklyDeltas(
        [entry(7000, monday), entry(3000, week(1))],
        summed: true,
        today: week(1).add(const Duration(days: 2)),
      );

      expect(result, isEmpty);
    });

    test('keeps the running week of an averaged metric', () {
      final result = weeklyDeltas(
        [entry(80, monday), entry(79, week(1))],
        today: week(1).add(const Duration(days: 2)),
      );

      expect(result.single.value, -1);
    });
  });

  group('smoothedTrendline', () {
    test('returns an empty list for no entries', () {
      expect(smoothedTrendline([]), isEmpty);
    });

    test('seeds the first point with the raw value and keeps the dates', () {
      final input = [
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 2)),
        entry(30, DateTime(2026, 1, 3)),
      ];
      final result = smoothedTrendline(input, period: 10);

      expect(result.length, 3);
      expect(result.first.value, 10); // seed == first raw value
      expect(result.map((e) => e.date), input.map((e) => e.date));
    });

    test('EMA follows a rising series but lags behind the raw values', () {
      final result = smoothedTrendline([
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 2)),
        entry(30, DateTime(2026, 1, 3)),
      ], period: 10);

      // smoothing k = 2 / (10 + 1) ~= 0.1818
      // point 2: 20*k + 10*(1-k) = 11.818...
      expect(result[1].value, closeTo(11.818, 0.001));
      // point 3: 30*k + 11.818*(1-k) = 15.123...
      expect(result[2].value, closeTo(15.123, 0.001));
      // trend trails the raw climb
      expect(result[2].value, lessThan(30));
    });

    test('sorts unordered input by date before smoothing', () {
      final result = smoothedTrendline([
        entry(30, DateTime(2026, 1, 3)),
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 2)),
      ], period: 10);

      expect(result.first.date, DateTime(2026, 1, 1));
      expect(result.first.value, 10);
      expect(result.last.date, DateTime(2026, 1, 3));
    });
  });
}
