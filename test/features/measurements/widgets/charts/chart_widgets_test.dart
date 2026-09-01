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

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/widgets/charts/bar_chart.dart';
import 'package:wger/features/measurements/widgets/charts/line_chart.dart';
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

    testWidgets('the tooltip stays inside the chart', (tester) async {
      // Without this the reading at either end shows a tooltip that is cut
      // off by the chart edge, or lies outside it altogether
      await tester.pumpWidget(
        _wrap(MeasurementBarChartWidgetFl([entry(1000, DateTime(2026, 1, 1))], 'steps')),
      );
      await tester.pumpAndSettle();

      final tooltip = tester
          .widget<BarChart>(find.byType(BarChart))
          .data
          .barTouchData
          .touchTooltipData;
      expect(tooltip.fitInsideHorizontally, isTrue);
      expect(tooltip.fitInsideVertically, isTrue);
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

  group('a series that does not move', () {
    testWidgets('gets a value axis with room in it', (tester) async {
      // Every reading the same weight. fl_chart derives its own bounds from
      // the spots, lands on a range of nothing, and then walks the axis in
      // steps smaller than the value's own precision: the walk never advances
      // and it builds labels until the heap gives out. Without the bounds set
      // here this test hangs rather than fails.
      final flat = [
        for (var day = 1; day <= 5; day++) entry(111.18, DateTime(2026, 1, day)),
      ];

      await tester.pumpWidget(
        _wrap(MeasurementChartWidgetFl.singleMeasurement(flat, 'kg')),
      );
      await tester.pumpAndSettle();

      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      expect(data.minY, lessThan(111.18));
      expect(data.maxY, greaterThan(111.18));
      expect(tester.takeException(), isNull);
    });

    testWidgets('and so does a bar chart of one repeated value', (tester) async {
      final flat = [
        for (var day = 1; day <= 5; day++) entry(8000, DateTime(2026, 1, day)),
      ];

      await tester.pumpWidget(_wrap(MeasurementBarChartWidgetFl(flat, 'steps')));
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsOneWidget);
      expect(tester.takeException(), isNull);
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

    testWidgets('a point without a spread pinches the band to the line', (tester) async {
      // A day with a single measurement has no range of its own; the band
      // narrows to the line there instead of vanishing for the whole series
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

      final data = chartData(tester);
      expect(data.betweenBarsData, hasLength(1));
      expect(data.lineBarsData, hasLength(3));
      // The bounds fall back to the value where the point has no range
      expect(data.lineBarsData[0].spots.map((s) => s.y), [50, 70]);
      expect(data.lineBarsData[1].spots.map((s) => s.y), [80, 70]);
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

  group('MeasurementBarChartWidgetFl changes', () {
    BarChartData chartData(WidgetTester tester) =>
        tester.widget<BarChart>(find.byType(BarChart)).data;

    Future<BarChartData> pumpSigned(
      WidgetTester tester,
      List<MeasurementChartEntry> entries,
    ) async {
      await tester.pumpWidget(_wrap(MeasurementBarChartWidgetFl(entries, 'kg', signed: true)));
      await tester.pumpAndSettle();
      return chartData(tester);
    }

    testWidgets('a decrease hangs below the zero line, an increase above it', (tester) async {
      final data = await pumpSigned(tester, [
        entry(-1.5, DateTime(2026, 1, 5)),
        entry(0.5, DateTime(2026, 1, 12)),
      ]);

      expect(data.barGroups.map((g) => g.barRods.single.fromY), [0, 0]);
      expect(data.barGroups.map((g) => g.barRods.single.toY), [-1.5, 0.5]);
      // the rounded end is the one away from the baseline
      expect(data.barGroups.first.barRods.single.borderRadius?.bottomLeft, isNot(Radius.zero));
      expect(data.barGroups.last.barRods.single.borderRadius?.topLeft, isNot(Radius.zero));
    });

    testWidgets('the two directions are told apart by colour', (tester) async {
      final data = await pumpSigned(tester, [
        entry(-1.5, DateTime(2026, 1, 5)),
        entry(0.5, DateTime(2026, 1, 12)),
      ]);

      final colors = data.barGroups.map((g) => g.barRods.single.color).toList();
      expect(colors.first, isNot(colors.last));
    });

    testWidgets('the zero line is drawn, so a chart of only decreases reads right', (
      tester,
    ) async {
      final data = await pumpSigned(tester, [entry(-1.5, DateTime(2026, 1, 5))]);

      expect(data.extraLinesData.horizontalLines.single.y, 0);
    });

    testWidgets('an amount chart has no zero line', (tester) async {
      await tester.pumpWidget(
        _wrap(MeasurementBarChartWidgetFl([entry(1500, DateTime(2026, 1, 5))], 'steps')),
      );
      await tester.pumpAndSettle();

      expect(chartData(tester).extraLinesData.horizontalLines, isEmpty);
    });

    testWidgets('the tooltip quotes a change with its sign', (tester) async {
      await pumpSigned(tester, [entry(0.5, DateTime(2026, 1, 12))]);

      final data = chartData(tester);
      final rod = data.barGroups.single.barRods.single;
      final item = data.barTouchData.touchTooltipData.getTooltipItem(
        data.barGroups.single,
        0,
        rod,
        0,
      );

      expect(item!.text, contains('+0.5'));
    });
  });
}
