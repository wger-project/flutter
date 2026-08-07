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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';

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

  group('chartEntriesFor', () {
    test('converts the aggregate bounds along with the value', () {
      // Reading the value in lb but the bounds in kg would put the band a
      // factor 2.2 off the line it is supposed to wrap
      final points = chartEntriesFor(
        [
          MeasurementEntry(
            categoryId: 'c',
            date: DateTime(2026, 1, 1),
            value: 80,
            notes: '',
            extraData: const {'min': 70, 'max': 90},
          ),
        ],
        targetUnit: 'lb',
        categoryUnit: 'kg',
      );

      expect(points.single.value, 176.37);
      expect(points.single.min, 154.32);
      expect(points.single.max, 198.42);
    });

    test('leaves entries without bounds unranged', () {
      final points = chartEntriesFor(
        [
          MeasurementEntry(
            categoryId: 'c',
            date: DateTime(2026, 1, 1),
            value: 80,
            notes: '',
          ),
        ],
        targetUnit: 'kg',
        categoryUnit: 'kg',
      );

      expect(points.single.hasRange, isFalse);
    });
  });
  group('chartEntriesForBuckets', () {
    MeasurementBucket bucket(
      num sum, {
      int count = 1,
      String? unit,
      num? min,
      num? max,
      DateTime? start,
    }) => MeasurementBucket(
      start: start ?? DateTime(2026, 1, 1),
      unit: unit,
      count: count,
      sum: sum,
      min: min ?? sum / count,
      max: max ?? sum / count,
    );

    test('a bucket becomes its mean, spanning the values it stands for', () {
      final points = chartEntriesForBuckets(
        [bucket(300, count: 4, min: 60, max: 90)],
        targetUnit: 'bpm',
        categoryUnit: 'bpm',
      );

      expect(points.single.value, 75);
      expect(points.single.min, 60);
      expect(points.single.max, 90);
      // What the point stands for, which the distribution's threshold counts
      expect(points.single.count, 4);
    });

    test('a single reading gets no band', () {
      // A zero-width band is a line drawn twice
      final points = chartEntriesForBuckets(
        [bucket(80)],
        targetUnit: 'kg',
        categoryUnit: 'kg',
      );

      expect(points.single.value, 80);
      expect(points.single.hasRange, isFalse);
    });

    test('slices are converted before they are merged', () {
      // The kg and lb halves of one day: averaging the stored numbers first
      // would produce a value in neither unit
      final points = chartEntriesForBuckets(
        [
          bucket(80, unit: 'kg'),
          bucket(180, unit: 'lb'),
        ],
        targetUnit: 'kg',
        categoryUnit: 'kg',
      );

      // 180 lb is 81.65 kg, so the day averages the two
      expect(points.single.value, closeTo(80.83, 0.01));
      expect(points.single.min, 80);
      expect(points.single.max, 81.65);
    });

    test('the mean is weighted by how many readings each slice holds', () {
      final points = chartEntriesForBuckets(
        [
          bucket(300, count: 4, unit: 'kg'),
          bucket(100, count: 1, unit: 'kg'),
        ],
        targetUnit: 'kg',
        categoryUnit: 'kg',
      );

      // 400 over five readings, not the 87.5 an unweighted mean would give
      expect(points.single.value, 80);
    });

    test('a slice without a unit falls back to the category one', () {
      final points = chartEntriesForBuckets(
        [bucket(180)],
        targetUnit: 'kg',
        categoryUnit: 'lb',
      );

      expect(points.single.value, closeTo(81.65, 0.01));
    });

    test('a summed metric totals its slices and gets no band', () {
      // A band around a daily step count is a spread the total has not
      final points = chartEntriesForBuckets(
        [bucket(6000, count: 3, min: 1000, max: 3000)],
        targetUnit: 'steps',
        categoryUnit: 'steps',
        summed: true,
      );

      expect(points.single.value, 6000);
      expect(points.single.hasRange, isFalse);
    });

    test('buckets of different starts stay separate points', () {
      final points = chartEntriesForBuckets(
        [
          bucket(80, start: DateTime(2026, 1, 1)),
          bucket(81, start: DateTime(2026, 1, 2)),
        ],
        targetUnit: 'kg',
        categoryUnit: 'kg',
      );

      expect(points.map((p) => p.date), [DateTime(2026, 1, 1), DateTime(2026, 1, 2)]);
      expect(points.map((p) => p.value), [80, 81]);
    });
  });
  group('chartSeriesFor', () {
    test('cuts both series at the range, after averaging over all points', () {
      // The points reach back beyond the range so the first ones in it average
      // the days before them instead of starting over at the cutoff
      final points = [
        for (var day = 0; day < 20; day++)
          MeasurementChartEntry(
            day.isEven ? 70 : 80,
            DateTime.now().subtract(Duration(days: 19 - day)),
          ),
      ];

      final (:entries, :average) = chartSeriesFor(
        points,
        ChartRange.lastMonth,
        const ChartSettings(),
      );

      expect(entries, hasLength(20));
      expect(average, hasLength(20));
      // The last point averages a full window, not just itself
      expect(average.last.value, closeTo(75, 1));
    });
  });
  group('sensibleRange', () {
    test('averages over the window the category configured', () {
      final points = [
        MeasurementChartEntry(10, DateTime.now().subtract(const Duration(days: 11))),
        MeasurementChartEntry(20, DateTime.now()),
      ];

      // the older point is outside 7 days but inside 14
      expect(sensibleRange(points).$2.last.value, 20);
      expect(sensibleRange(points, averageDays: 14).$2.last.value, 15);
    });
  });

  group('niceBinWidth', () {
    test('rounds the span split into ~20 bins up to 1, 2 or 5 times a power of ten', () {
      // span 14.6 / 20 = 0.73 -> 1, not an edge like 59.3-61.3
      expect(niceBinWidth(59.3, 73.9), 1);
      // span 30000 / 20 = 1500 -> 2000
      expect(niceBinWidth(0, 30000), 2000);
      // span 9 / 20 = 0.45 -> 0.5
      expect(niceBinWidth(1, 10), 0.5);
    });

    test('a span of nothing still has a width', () {
      expect(niceBinWidth(80, 80), 1);
    });
  });
  group('buildWeightedHistogram', () {
    test('counts a value as often as it occurred', () {
      // What the aggregated query hands over: a year of readings arrives as
      // the distinct values it covers, with their counts
      final result = buildWeightedHistogram(
        [(value: 60, count: 30), (value: 61, count: 5)],
        latest: 61,
        binWidth: 1,
      );

      expect(result.counts, [30, 5]);
    });

    test('the median weighs the counts, not the distinct values', () {
      // Thirty readings at 60 and one at 90: the middle reading is a 60, which
      // an unweighted median over the two values would miss
      final result = buildWeightedHistogram(
        [(value: 60, count: 30), (value: 90, count: 1)],
        latest: 90,
        binWidth: 10,
      );

      expect(result.median, 60);
    });

    test('an even number of readings averages the two in the middle', () {
      final result = buildWeightedHistogram(
        [(value: 60, count: 1), (value: 70, count: 1)],
        latest: 70,
        binWidth: 10,
      );

      expect(result.median, 65);
    });
  });
  group('buildWeightedHistogram bins', () {
    test('aligns the bin edges to round multiples of the width', () {
      final result = buildWeightedHistogram(
        [
          (value: 79.7, count: 1),
          (value: 82.3, count: 1),
        ],
        latest: 0,
        binWidth: 0.5,
      );

      expect(result.firstEdge, 79.5);
      expect(result.lowerEdgeOf(1), 80);
      expect(result.upperEdgeOf(result.counts.length - 1), 82.5);
    });

    test('keeps empty bins between the occupied ones, a gap is information', () {
      final result = buildWeightedHistogram(
        [
          (value: 60, count: 1),
          (value: 61, count: 1),
          (value: 65, count: 1),
        ],
        latest: 0,
        binWidth: 2,
      );

      expect(result.counts, [2, 0, 1]);
    });

    test('takes the median of the values, odd and even', () {
      final odd = buildWeightedHistogram(
        [
          (value: 60, count: 1),
          (value: 62, count: 1),
          (value: 70, count: 1),
        ],
        latest: 0,
        binWidth: 2,
      );
      expect(odd.median, 62);

      final even = buildWeightedHistogram(
        [
          (value: 60, count: 1),
          (value: 63, count: 1),
          (value: 65, count: 1),
          (value: 70, count: 1),
        ],
        latest: 0,
        binWidth: 2,
      );
      expect(even.median, 64);
    });

    test('derives a width from the span when the type brings none', () {
      final result = buildWeightedHistogram([
        (value: 59.3, count: 1),
        (value: 73.9, count: 1),
      ], latest: 0);

      expect(result.binWidth, 1);
    });

    test('doubles the width until an outlier no longer stretches it into hundreds of bins', () {
      // 20 to 350 at 0.5 kg would be 661 bins; doubling keeps the edges round
      final result = buildWeightedHistogram(
        [
          (value: 20, count: 1),
          (value: 80, count: 1),
          (value: 350, count: 1),
        ],
        latest: 0,
        binWidth: 0.5,
      );

      expect(result.binWidth, 4);
      expect(result.counts.length, lessThanOrEqualTo(100));
      expect(result.counts.sum, 3);
    });
  });

  group('buildHeatmapGrid', () {
    // 2 March 2026 is a Monday, 18 March a Wednesday
    final monday = DateTime(2026, 3, 2);
    final wednesday = DateTime(2026, 3, 18);

    test('starts on the Monday of the oldest week and ends with today', () {
      final grid = buildHeatmapGrid(
        [entry(10, monday), entry(20, wednesday)],
        today: wednesday,
      );

      expect(grid.start, monday);
      expect(grid.weeks, 3);
      expect(grid.dayAt(0, 0), monday);
      expect(grid.dayAt(2, 2), wednesday);
    });

    test('leaves days without a measurement empty rather than zero', () {
      final grid = buildHeatmapGrid([entry(10, monday)], today: monday);

      expect(grid.valueAt(0, 0), 10);
      expect(grid.valueAt(0, 1), isNull);
    });

    test('runs up to today, so a stretch without measurements stays visible', () {
      final grid = buildHeatmapGrid([entry(10, monday)], today: wednesday);

      expect(grid.weeks, 3);
      expect(grid.valueAt(2, 2), isNull);
    });

    test('caps a long history at a year of week columns', () {
      final grid = buildHeatmapGrid(
        [entry(10, DateTime(2020, 1, 1)), entry(20, wednesday)],
        today: wednesday,
      );

      expect(grid.weeks, heatmapMaxWeeks);
      expect(grid.dayAt(grid.weeks - 1, 2), wednesday);
    });

    test('anchors on the last measurement when the history ended long ago', () {
      // Anchoring on today would put the whole history outside the grid and
      // draw an empty one
      final grid = buildHeatmapGrid(
        [entry(10, monday), entry(20, wednesday)],
        today: DateTime(2028, 1, 1),
      );

      expect(grid.dayAt(grid.weeks - 1, 2), wednesday);
      expect(grid.valueAt(grid.weeks - 1, 2), 20);
    });

    test('takes the top of the colour scale only from the days it shows', () {
      // A spike outside the window would scale the colours of every visible
      // cell without being visible itself, washing out the whole grid
      final grid = buildHeatmapGrid(
        [entry(45000, DateTime(2024, 1, 3)), entry(8000, wednesday)],
        today: wednesday,
      );

      expect(grid.maxValue, 8000);
      expect(grid.values.containsKey(DateTime(2024, 1, 3)), isFalse);
    });

    test('takes the top of the colour scale from the largest value', () {
      final grid = buildHeatmapGrid(
        [entry(10, monday), entry(8000, wednesday)],
        today: wednesday,
      );

      expect(grid.maxValue, 8000);
    });

    test('is a full grid of the last year when there is nothing to show', () {
      final grid = buildHeatmapGrid([]);

      expect(grid.weeks, heatmapMaxWeeks);
      expect(grid.maxValue, 0);
      expect(grid.valueAt(0, 0), isNull);
    });
  });
}
