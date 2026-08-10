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
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/charts/spark.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';

void main() {
  group('sparkKindFor', () {
    test('honors the picked chart type where it survives miniaturisation', () {
      expect(sparkKindFor(MetricType.restingHeartRate, ChartType.line), SparkKind.line);
      expect(sparkKindFor(MetricType.steps, ChartType.bar), SparkKind.bars);
      expect(sparkKindFor(MetricType.steps, ChartType.heatmap), SparkKind.heatmap);
      expect(sparkKindFor(MetricType.restingHeartRate, ChartType.delta), SparkKind.delta);
    });

    test('auto derives the default spark from the metric type', () {
      expect(sparkKindFor(MetricType.restingHeartRate, ChartType.auto), SparkKind.line);
      expect(sparkKindFor(MetricType.steps, ChartType.auto), SparkKind.bars);
      expect(sparkKindFor(MetricType.custom, ChartType.auto), SparkKind.line);
    });

    test('a distribution falls back to the default spark of the type', () {
      expect(sparkKindFor(MetricType.restingHeartRate, ChartType.distribution), SparkKind.line);
      expect(sparkKindFor(MetricType.steps, ChartType.distribution), SparkKind.bars);
    });

    test('a pick that does not fit the type falls back like the full chart', () {
      // A summed type has no line chart to shrink, see resolveChartType
      expect(sparkKindFor(MetricType.steps, ChartType.line), SparkKind.bars);
    });
  });

  group('sparkWindowFor', () {
    // A Friday; its Monday is 2026-08-03
    final today = DateTime(2026, 8, 7);

    test('a line follows the filter cutoff as it is', () {
      final window = sparkWindowFor(
        SparkKind.line,
        cutoff: DateTime(2026, 7, 8),
        today: today,
      );

      expect(window.start, DateTime(2026, 7, 8));
      expect(window.days, 31);
      expect(window.weekly, isFalse);
    });

    test('a full-history line has no fixed start, the data provides it', () {
      final window = sparkWindowFor(SparkKind.line, cutoff: null, today: today);

      expect(window.start, isNull);
      expect(window.days, isNull);
    });

    test('bars stay daily up to the weekly threshold', () {
      final window = sparkWindowFor(
        SparkKind.bars,
        cutoff: DateTime(2026, 7, 8),
        today: today,
      );

      expect(window.weekly, isFalse);
      expect(window.slotCount, 31);
    });

    test('bars switch to Monday-aligned calendar weeks beyond it', () {
      final window = sparkWindowFor(
        SparkKind.bars,
        cutoff: DateTime(2026, 5, 9),
        today: today,
      );

      expect(window.weekly, isTrue);
      expect(window.start!.weekday, DateTime.monday);
      expect(window.slotCount, 13);
      // 13 week columns, the newest being the running one
      expect(window.start, DateTime(2026, 5, 11));
    });

    test('the unlimited range is capped at a year of weekly slots', () {
      final window = sparkWindowFor(SparkKind.bars, cutoff: null, today: today);

      expect(window.weekly, isTrue);
      expect(window.slotCount, sparkMaxWeeks);
    });

    test('the delta window gets one slot beyond its weeks for the running week', () {
      final window = sparkWindowFor(
        SparkKind.delta,
        cutoff: DateTime(2026, 5, 9),
        today: today,
      );

      expect(window.start, DateTime(2026, 5, 4));
      expect(window.slotCount, 14);
    });

    test('the heatmap follows the filter within its legibility bounds', () {
      // A month is five week columns, ending in the running week
      final month = sparkWindowFor(
        SparkKind.heatmap,
        cutoff: DateTime(2026, 7, 8),
        today: today,
      );
      expect(month.slotCount, 5);
      expect(month.start, DateTime(2026, 7, 6));

      // A week is below what a heatmap says anything about
      final week = sparkWindowFor(
        SparkKind.heatmap,
        cutoff: DateTime(2026, 8, 1),
        today: today,
      );
      expect(week.slotCount, sparkHeatmapMinWeeks);

      // The unlimited range is capped where the columns stop fitting
      final all = sparkWindowFor(SparkKind.heatmap, cutoff: null, today: today);
      expect(all.slotCount, sparkHeatmapMaxWeeks);
    });
  });

  group('sparkWeeklyPoints', () {
    test('one point per calendar week, keeping the daily level', () {
      final means = sparkWeeklyPoints([
        MeasurementChartEntry(8000, DateTime(2026, 8, 3)),
        MeasurementChartEntry(6000, DateTime(2026, 8, 5)),
        MeasurementChartEntry(10000, DateTime(2026, 7, 29)),
      ]);

      expect(means.map((e) => e.date), [DateTime(2026, 7, 27), DateTime(2026, 8, 3)]);
      expect(means.map((e) => e.value), [10000, 7000]);
    });

    test('carries the span of everything measured in the week', () {
      final ranges = sparkWeeklyPoints([
        MeasurementChartEntry(100, DateTime(2026, 8, 3), min: 79, max: 122),
        MeasurementChartEntry(105, DateTime(2026, 8, 5), min: 82, max: 128),
      ]);

      final week = ranges.single;
      expect(week.date, DateTime(2026, 8, 3));
      expect(week.min, 79);
      expect(week.max, 128);
    });
  });

  group('sparkWeeklyStacks', () {
    test('per component the mean over the days it reported', () {
      final stacks = sparkWeeklyStacks([
        MeasurementStackedEntry(DateTime(2026, 8, 3), const [400, 90]),
        MeasurementStackedEntry(DateTime(2026, 8, 4), const [440, null]),
      ]);

      final week = stacks.single;
      expect(week.date, DateTime(2026, 8, 3));
      expect(week.values, [420, 90]);
    });
  });

  group('sparkBars', () {
    final start = DateTime(2026, 8, 1);

    test('lays each day into its slot, one segment from zero', () {
      final data = sparkBars(
        [
          MeasurementChartEntry(10, DateTime(2026, 8, 1)),
          MeasurementChartEntry(20, DateTime(2026, 8, 3)),
        ],
        start: start,
        slotCount: 7,
      );

      expect(data.bars.map((b) => b.slot), [0, 2]);
      expect(data.bars.first.segments.single, (from: 0, to: 10, colorIndex: 0));
      expect(data.minValue, 0);
      expect(data.maxValue, 20);
    });

    test('weekly slots hold a calendar week each', () {
      final monday = DateTime(2026, 5, 11);
      final data = sparkBars(
        [
          MeasurementChartEntry(7000, DateTime(2026, 5, 11)),
          MeasurementChartEntry(9000, DateTime(2026, 8, 3)),
        ],
        start: monday,
        slotCount: 13,
        slotDays: 7,
      );

      expect(data.bars.map((b) => b.slot), [0, 12]);
    });

    test('drops what falls outside the window instead of misplacing it', () {
      final data = sparkBars(
        [
          MeasurementChartEntry(10, DateTime(2026, 7, 31)),
          MeasurementChartEntry(20, DateTime(2026, 8, 8)),
        ],
        start: start,
        slotCount: 7,
      );

      expect(data.isEmpty, isTrue);
    });
  });

  group('sparkFloatingBars', () {
    test('spans the reading, and holds a single value as a point-sized bar', () {
      final data = sparkFloatingBars(
        [
          MeasurementChartEntry(100, DateTime(2026, 8, 1), min: 79, max: 122),
          MeasurementChartEntry(110, DateTime(2026, 8, 2)),
        ],
        start: DateTime(2026, 8, 1),
        slotCount: 7,
      );

      expect(data.bars.first.segments.single, (from: 79, to: 122, colorIndex: 0));
      expect(data.bars.last.segments.single, (from: 110, to: 110, colorIndex: 0));
      // The bars float: the axis follows the readings, not zero
      expect(data.minValue, 79);
    });
  });

  group('sparkStackedBars', () {
    test('one segment per component, coloured by its position', () {
      final data = sparkStackedBars(
        [
          MeasurementStackedEntry(DateTime(2026, 8, 2), const [240, null, 60]),
        ],
        start: DateTime(2026, 8, 1),
        slotCount: 7,
      );

      expect(data.bars.single.slot, 1);
      expect(data.bars.single.segments, [
        (from: 0.0, to: 240.0, colorIndex: 0),
        (from: 240.0, to: 300.0, colorIndex: 2),
      ]);
    });
  });

  group('sparkDeltaBars', () {
    test('one signed bar per week, slotted by its Monday', () {
      final start = DateTime(2026, 6, 8);
      final data = sparkDeltaBars(
        [
          MeasurementChartEntry(-0.4, DateTime(2026, 6, 15)),
          MeasurementChartEntry(0.2, DateTime(2026, 8, 3)),
        ],
        start: start,
        slotCount: 9,
      );

      expect(data.signed, isTrue);
      expect(data.bars.map((b) => b.slot), [1, 8]);
      // Signed bars hang off zero, so the bounds always include it
      expect(data.minValue, -0.4);
      expect(data.maxValue, 0.2);
    });
  });

  group('sparkIsSparse', () {
    test('below the minimum the line spark switches to dots', () {
      final days = [
        MeasurementChartEntry(1, DateTime(2026, 8, 1)),
        MeasurementChartEntry(2, DateTime(2026, 8, 2)),
      ];

      expect(sparkIsSparse(days), isTrue);
      expect(sparkIsSparse([...days, MeasurementChartEntry(3, DateTime(2026, 8, 3))]), isFalse);
    });
  });
}
