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

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SizedBox(width: 400, height: 300, child: child),
  ),
);

void main() {
  MeasurementChartEntry entry(num value, DateTime date) => MeasurementChartEntry(value, date);

  group('MeasurementBarChartWidgetFl', () {
    testWidgets('renders without error for empty entries', (tester) async {
      await tester.pumpWidget(
        _wrap(const MeasurementBarChartWidgetFl([], 'steps')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MeasurementBarChartWidgetFl), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BarChart is present for non-empty entries', (tester) async {
      final entries = [
        entry(1000, DateTime(2026, 1, 1)),
        entry(2000, DateTime(2026, 1, 2)),
        entry(1500, DateTime(2026, 1, 3)),
      ];
      await tester.pumpWidget(_wrap(MeasurementBarChartWidgetFl(entries, 'steps')));
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('only labels a few dates on the x axis', (tester) async {
      final entries = List.generate(
        40,
        (i) => entry(1000 + i, DateTime(2026, 1, 1).add(Duration(days: i))),
      );
      await tester.pumpWidget(_wrap(MeasurementBarChartWidgetFl(entries, 'steps')));
      await tester.pumpAndSettle();

      final dateLabels = find.byWidgetPredicate(
        (w) => w is Text && RegExp(r'^\d+/\d+$').hasMatch(w.data ?? ''),
      );
      expect(dateLabels, findsNWidgets(4));
      // the labels are spread out and kept away from the axis edges
      expect(find.text('1/6'), findsOneWidget);
      expect(find.text('2/5'), findsOneWidget);
      expect(find.text('1/1'), findsNothing);
    });
  });

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

  group('MeasurementChartWidgetFl series', () {
    /// The chart data fl_chart actually receives
    LineChartData chartData(WidgetTester tester) =>
        tester.widget<LineChart>(find.byType(LineChart)).data;

    final points = [
      entry(60, DateTime(2026, 1, 1)),
      entry(70, DateTime(2026, 1, 2)),
    ];

    testWidgets('singleMeasurement draws one line per given role', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl.singleMeasurement(
            points,
            'kg',
            avgs: points,
            trend: points,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(chartData(tester).lineBarsData, hasLength(3));
      expect(chartData(tester).betweenBarsData, isEmpty);
    });

    testWidgets('omits the lines it was not given', (tester) async {
      await tester.pumpWidget(
        _wrap(MeasurementChartWidgetFl.singleMeasurement(points, 'kg')),
      );
      await tester.pumpAndSettle();

      expect(chartData(tester).lineBarsData, hasLength(1));
    });

    testWidgets('draws one line per component, in distinct colours', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl([
            MeasurementChartSeries(points, MeasurementSeriesRole.component, label: 'Systolic'),
            MeasurementChartSeries(points, MeasurementSeriesRole.component, label: 'Diastolic'),
          ], 'mmHg'),
        ),
      );
      await tester.pumpAndSettle();

      final bars = chartData(tester).lineBarsData;
      expect(bars, hasLength(2));
      expect(bars.first.color, isNot(bars.last.color));
    });

    testWidgets('a range series adds a band between two invisible bounds', (tester) async {
      final ranged = [
        MeasurementChartEntry(60, DateTime(2026, 1, 1), min: 50, max: 80),
        MeasurementChartEntry(70, DateTime(2026, 1, 2), min: 55, max: 95),
      ];
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl([
            MeasurementChartSeries(ranged, MeasurementSeriesRole.raw),
          ], 'bpm'),
        ),
      );
      await tester.pumpAndSettle();

      final data = chartData(tester);
      // lower bound, upper bound, and the line itself
      expect(data.lineBarsData, hasLength(3));
      expect(data.betweenBarsData, hasLength(1));
      expect(data.betweenBarsData.single.fromIndex, 0);
      expect(data.betweenBarsData.single.toIndex, 1);
      // the bounds carry the range, not the value
      expect(data.lineBarsData[0].spots.map((s) => s.y), [50, 55]);
      expect(data.lineBarsData[1].spots.map((s) => s.y), [80, 95]);
      expect(data.lineBarsData[2].spots.map((s) => s.y), [60, 70]);
    });

    testWidgets('only the measured series gets a band, not its average', (tester) async {
      // Condensing attaches a range to every point, so a downsampled average
      // would otherwise be drawn with a band of its own. The band means "this
      // is the spread of the measurements", which a smoothed line has not.
      final ranged = [
        MeasurementChartEntry(60, DateTime(2026, 1, 1), min: 50, max: 80),
        MeasurementChartEntry(70, DateTime(2026, 1, 2), min: 55, max: 95),
      ];
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl([
            MeasurementChartSeries(ranged, MeasurementSeriesRole.raw),
            MeasurementChartSeries(ranged, MeasurementSeriesRole.average),
            MeasurementChartSeries(ranged, MeasurementSeriesRole.trend),
          ], 'bpm'),
        ),
      );
      await tester.pumpAndSettle();

      expect(chartData(tester).betweenBarsData, hasLength(1));
    });

    testWidgets('no band when only some points carry a range', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl([
            MeasurementChartSeries([
              MeasurementChartEntry(60, DateTime(2026, 1, 1), min: 50, max: 80),
              entry(70, DateTime(2026, 1, 2)),
            ], MeasurementSeriesRole.raw),
          ], 'bpm'),
        ),
      );
      await tester.pumpAndSettle();

      expect(chartData(tester).betweenBarsData, isEmpty);
      expect(chartData(tester).lineBarsData, hasLength(1));
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

  group('MeasurementChartWidgetFl plan periods', () {
    LineChartData chartData(WidgetTester tester) =>
        tester.widget<LineChart>(find.byType(LineChart)).data;

    final points = [
      entry(60, DateTime(2026, 1, 1)),
      entry(70, DateTime(2026, 1, 10)),
    ];

    testWidgets('periods become vertical bands clamped to the data', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl.singleMeasurement(
            points,
            'kg',
            planPeriods: [
              (
                range: DateTimeRange(start: DateTime(2025, 12, 20), end: DateTime(2026, 1, 5)),
                name: 'Cut',
              ),
              (
                range: DateTimeRange(start: DateTime(2026, 2, 1), end: DateTime(2026, 2, 10)),
                name: 'Bulk',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final annotations = chartData(tester).rangeAnnotations.verticalRangeAnnotations;
      // the february plan does not overlap the data and draws nothing
      expect(annotations, hasLength(1));
      expect(annotations.single.x1, DateTime(2026, 1, 1).millisecondsSinceEpoch.toDouble());
      expect(annotations.single.x2, DateTime(2026, 1, 5).millisecondsSinceEpoch.toDouble());
    });

    testWidgets('no bands without periods', (tester) async {
      await tester.pumpWidget(_wrap(MeasurementChartWidgetFl.singleMeasurement(points, 'kg')));
      await tester.pumpAndSettle();

      expect(chartData(tester).rangeAnnotations.verticalRangeAnnotations, isEmpty);
    });

    testWidgets('tooltip names the plan once, below the last line', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl.singleMeasurement(
            points,
            'kg',
            avgs: points,
            trend: points,
            planPeriods: [
              (
                range: DateTimeRange(start: DateTime(2025, 12, 20), end: DateTime(2026, 1, 5)),
                name: 'Prep Sommer 2026',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final data = chartData(tester);
      // a touch on the first point, which every series has a spot for
      final touched = [
        for (final (i, bar) in data.lineBarsData.indexed) LineBarSpot(bar, i, bar.spots.first),
      ];
      final items = data.lineTouchData.touchTooltipData.getTooltipItems(touched).nonNulls.toList();

      expect(items, hasLength(3));
      final mentions = [
        for (final item in items) ...?item.children,
      ].whereType<TextSpan>().where((s) => s.text!.contains('Prep Sommer 2026'));
      expect(mentions, hasLength(1));
      expect(items.take(2).every((i) => i.children == null || i.children!.isEmpty), isTrue);
    });

    testWidgets('no plan name for a point outside every period', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl.singleMeasurement(
            points,
            'kg',
            planPeriods: [
              (
                range: DateTimeRange(start: DateTime(2025, 12, 20), end: DateTime(2026, 1, 5)),
                name: 'Cut',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final data = chartData(tester);
      // the second point (january 10th) lies after the period's end
      final touched = [
        LineBarSpot(data.lineBarsData.single, 0, data.lineBarsData.single.spots.last),
      ];
      final items = data.lineTouchData.touchTooltipData.getTooltipItems(touched).nonNulls.toList();

      expect(items.single.children, anyOf(isNull, isEmpty));
    });
  });

  group('MeasurementBarChartWidgetFl ranges', () {
    BarChartData chartData(WidgetTester tester) =>
        tester.widget<BarChart>(find.byType(BarChart)).data;

    testWidgets('a range entry becomes a bar spanning its bounds', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeasurementBarChartWidgetFl([
            MeasurementChartEntry(100, DateTime(2026, 1, 1), min: 80, max: 120),
          ], 'mmHg'),
        ),
      );
      await tester.pumpAndSettle();

      final rod = chartData(tester).barGroups.single.barRods.single;
      expect(rod.fromY, 80);
      expect(rod.toY, 120);
    });

    testWidgets('a plain entry still grows from zero', (tester) async {
      await tester.pumpWidget(
        _wrap(MeasurementBarChartWidgetFl([entry(1500, DateTime(2026, 1, 1))], 'steps')),
      );
      await tester.pumpAndSettle();

      final rod = chartData(tester).barGroups.single.barRods.single;
      expect(rod.fromY, 0);
      expect(rod.toY, 1500);
    });

    testWidgets('bars get thinner the more of them share the width', (tester) async {
      Future<double> barWidthFor(int count) async {
        await tester.pumpWidget(
          _wrap(
            MeasurementBarChartWidgetFl(
              List.generate(count, (i) => entry(100, DateTime(2026, 1, 1).add(Duration(days: i)))),
              'steps',
            ),
          ),
        );
        await tester.pumpAndSettle();
        return chartData(tester).barGroups.first.barRods.single.width;
      }

      // a handful of bars stay comfortably wide, a season of readings must not
      // overflow into a solid block
      expect(await barWidthFor(5), 12.0);
      expect(await barWidthFor(120), lessThan(4));
      expect(await barWidthFor(120), greaterThanOrEqualTo(1));
    });
  });

  group('moving7dAverage', () {
    test('returns an empty list for no entries', () {
      expect(moving7dAverage([]), isEmpty);
    });

    test('averages over everything within the preceding 7 days', () {
      final result = moving7dAverage([
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
      final result = moving7dAverage([
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 20)),
      ]);

      // the january 1st entry is far outside the 7 days before january 20th
      expect(result.last.value, 20);
    });

    test('sorts unordered input by date first', () {
      final result = moving7dAverage([
        entry(30, DateTime(2026, 1, 3)),
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 2)),
      ]);

      expect(result.map((e) => e.value), [10, 15, 20]);
    });

    test('stays accurate over a long dense series', () {
      // The window total is carried along rather than re-summed, so this
      // guards against drift piling up
      final result = moving7dAverage([
        for (var i = 0; i < 5000; i++) entry(100, DateTime(2026, 1, 1).add(Duration(minutes: i))),
      ]);

      expect(result.every((e) => (e.value - 100).abs() < 0.000001), isTrue);
    });
  });

  group('downsample', () {
    /// A day of heart-rate-like sampling: every 5 minutes, alternating between
    /// a resting and an exerting value
    List<MeasurementChartEntry> samples(int days) => [
      for (var day = 0; day < days; day++)
        for (var i = 0; i < 288; i++)
          entry(
            i.isEven ? 50 : 150,
            DateTime(2026, 1, 1).add(Duration(days: day, minutes: i * 5)),
          ),
    ];

    test('leaves a series that already fits untouched', () {
      final input = samples(1).take(50).toList();
      expect(downsample(input), same(input));
    });

    test('condenses a season of samples into one point per day', () {
      // The case from a real import: two months of raw samples must not be
      // cut into slices that ignore the daily rhythm
      final result = downsample(samples(61));

      expect(result, hasLength(61));
      expect(result.first.date, DateTime(2026, 1, 1));
      expect(result[1].date, DateTime(2026, 1, 2));
    });

    test('uses the finest unit that fits, hours for a few days', () {
      final result = downsample(samples(3));

      // 3 days of hours is 72 points, well under the limit, so no need to
      // drop all the way to whole days
      expect(result, hasLength(72));
      expect(result.first.date, DateTime(2026, 1, 1));
      expect(result[1].date, DateTime(2026, 1, 1, 1));
    });

    test('falls back to coarser units for long histories', () {
      final result = downsample(samples(400));

      // days would be 400 points, so it steps up to weeks
      expect(result.length, lessThanOrEqualTo(200));
      expect(result.length, greaterThan(50));
    });

    test('keeps the extremes as a range instead of averaging them away', () {
      final result = downsample(samples(61));

      expect(result.every((e) => e.hasRange), isTrue);
      expect(result.first.min, 50);
      expect(result.first.max, 150);
      expect(result.first.value, closeTo(100, 1));
    });

    test('stays in chronological order', () {
      final dates = downsample(samples(61)).map((e) => e.date).toList();
      expect(dates.isSorted((a, b) => a.compareTo(b)), isTrue);
    });

    test('carries the bounds of entries that are already ranges', () {
      final input = [
        for (var i = 0; i < 1000; i++)
          MeasurementChartEntry(
            100,
            DateTime(2026, 1, 1).add(Duration(minutes: i)),
            min: 40,
            max: 190,
          ),
      ];

      final result = downsample(input);
      // condensing an aggregate must not shrink it to its averages
      expect(result.first.min, 40);
      expect(result.first.max, 190);
    });

    test('condenses entries that all share one timestamp into one point', () {
      final input = List.generate(500, (i) => entry(i, DateTime(2026, 1, 1)));
      final result = downsample(input);

      expect(result, hasLength(1));
      expect(result.single.min, 0);
      expect(result.single.max, 499);
    });
  });

  group('MeasurementChartWidgetFl dot size', () {
    double dotRadius(WidgetTester tester) {
      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      final painter = data.lineBarsData.first.dotData.getDotPainter(
        FlSpot.zero,
        0,
        data.lineBarsData.first,
        0,
      );
      return (painter as FlDotCirclePainter).radius;
    }

    Future<double> radiusFor(WidgetTester tester, int count) async {
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl.singleMeasurement(
            List.generate(count, (i) => entry(60, DateTime(2026, 1, 1).add(Duration(days: i)))),
            'kg',
          ),
        ),
      );
      await tester.pumpAndSettle();
      return dotRadius(tester);
    }

    testWidgets('dots shrink as the points get denser', (tester) async {
      expect(await radiusFor(tester, 5), 4.0);
      expect(await radiusFor(tester, 300), lessThan(1.5));
      // but never vanish
      expect(await radiusFor(tester, 5000), greaterThanOrEqualTo(0.5));
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

  group('MeasurementHeatmapWidgetFl', () {
    testWidgets('renders without error for empty entries', (tester) async {
      await tester.pumpWidget(_wrap(const MeasurementHeatmapWidgetFl([], 'steps')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('reads out the day that was tapped', (tester) async {
      final today = DateTime.now();
      final day = DateTime(today.year, today.month, today.day);
      await tester.pumpWidget(_wrap(MeasurementHeatmapWidgetFl([entry(500, day)], 'steps')));
      await tester.pumpAndSettle();

      // A single day is a one-column grid, so its cell sits in the row of its
      // weekday. The read-out is what the tooltip is on the other charts.
      expect(buildHeatmapGrid([entry(500, day)]).weeks, 1);

      // Mirrors the widget's own layout: the read-out line above the grid, the
      // weekday labels to its left, the month labels on top, and the square
      // cells centred in what is left
      const readoutHeight = 20.0;
      const labelWidth = 22.0;
      const labelHeight = 12.0;
      final box = tester.getRect(find.byType(MeasurementHeatmapWidgetFl));
      final gridHeight = box.height - readoutHeight - labelHeight;
      final step = min(box.width - labelWidth, gridHeight / DateTime.daysPerWeek);
      final top =
          box.top + readoutHeight + labelHeight + (gridHeight - step * DateTime.daysPerWeek) / 2;

      await tester.tapAt(
        Offset(box.left + labelWidth + step / 2, top + step * (day.weekday - 1) + step / 2),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('500'), findsOneWidget);
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
