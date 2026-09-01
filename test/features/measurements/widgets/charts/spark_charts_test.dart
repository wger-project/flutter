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
import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/charts/spark.dart';
import 'package:wger/features/measurements/widgets/charts/spark_charts.dart';

const _size = Size(150, 40);

Widget _wrap(Widget spark) => MaterialApp(
  home: Scaffold(
    body: SizedBox(width: _size.width, height: _size.height, child: spark),
  ),
);

void main() {
  final start = DateTime(2026, 8, 1);

  group('SparkLineChart', () {
    testWidgets('a series is drawn as one line ending in the dot of today', (tester) async {
      final entries = [
        MeasurementChartEntry(80, DateTime(2026, 8, 1)),
        MeasurementChartEntry(81, DateTime(2026, 8, 3)),
        MeasurementChartEntry(80.5, DateTime(2026, 8, 7)),
      ];

      await tester.pumpWidget(_wrap(SparkLineChart(entries, start: start, days: 7)));

      // One polyline through the readings, plus the dot that marks today
      expect(find.byType(SparkLineChart), paintsExactlyCountTimes(#drawPoints, 1));
      expect(find.byType(SparkLineChart), paintsExactlyCountTimes(#drawCircle, 1));
    });

    testWidgets('an empty series paints nothing', (tester) async {
      await tester.pumpWidget(_wrap(SparkLineChart(const [], start: start, days: 7)));

      expect(find.byType(SparkLineChart), paintsNothing);
    });

    testWidgets('a flat series sits at mid height instead of dividing by zero', (tester) async {
      final entries = [
        MeasurementChartEntry(80, DateTime(2026, 8, 1)),
        MeasurementChartEntry(80, DateTime(2026, 8, 5)),
      ];

      await tester.pumpWidget(_wrap(SparkLineChart(entries, start: start, days: 7)));

      // The window fixes the x axis: the second reading sits four of six days in
      expect(
        find.byType(SparkLineChart),
        paints..something((symbol, arguments) {
          if (symbol != #drawPoints) {
            return false;
          }
          expect(arguments[0], PointMode.polygon);
          expect(arguments[1], const [Offset(0, 20), Offset(100, 20)]);
          return true;
        }),
      );
    });

    testWidgets('dots mode draws a dot per reading and no line', (tester) async {
      final entries = [
        MeasurementChartEntry(38.5, DateTime(2026, 8, 1)),
        MeasurementChartEntry(39, DateTime(2026, 8, 40)),
      ];

      await tester.pumpWidget(
        _wrap(SparkLineChart(entries, start: start, days: 91, dots: true)),
      );

      expect(find.byType(SparkLineChart), paintsExactlyCountTimes(#drawCircle, 2));
      expect(find.byType(SparkLineChart), paintsExactlyCountTimes(#drawPoints, 0));
    });

    testWidgets('a single reading is a dot, a line of one point would be invisible', (
      tester,
    ) async {
      final entries = [MeasurementChartEntry(38.5, DateTime(2026, 8, 1))];

      await tester.pumpWidget(_wrap(SparkLineChart(entries, start: start, days: 7)));

      expect(find.byType(SparkLineChart), paintsExactlyCountTimes(#drawCircle, 1));
      expect(find.byType(SparkLineChart), paintsExactlyCountTimes(#drawPoints, 0));
    });
  });

  group('SparkBarChart', () {
    testWidgets('a plain and a floating bar are one shape each', (tester) async {
      final plain = sparkBars(
        [MeasurementChartEntry(8000, DateTime(2026, 8, 2))],
        start: start,
        slotCount: 7,
      );
      final floating = sparkFloatingBars(
        [MeasurementChartEntry(100, DateTime(2026, 8, 2), min: 79, max: 122)],
        start: start,
        slotCount: 7,
      );

      await tester.pumpWidget(_wrap(SparkBarChart(plain)));
      expect(find.byType(SparkBarChart), paintsExactlyCountTimes(#drawRRect, 1));

      await tester.pumpWidget(_wrap(SparkBarChart(floating)));
      expect(find.byType(SparkBarChart), paintsExactlyCountTimes(#drawRRect, 1));
    });

    testWidgets('a stacked bar is one shape per component', (tester) async {
      final stacked = sparkStackedBars(
        [
          MeasurementStackedEntry(DateTime(2026, 8, 2), const [240, 60]),
        ],
        start: start,
        slotCount: 7,
      );

      await tester.pumpWidget(_wrap(SparkBarChart(stacked)));

      expect(find.byType(SparkBarChart), paintsExactlyCountTimes(#drawRRect, 2));
    });

    testWidgets('a signed spark hangs its bar off a zero line', (tester) async {
      final delta = sparkDeltaBars(
        [MeasurementChartEntry(-0.4, DateTime(2026, 8, 3))],
        start: start,
        slotCount: 9,
      );

      await tester.pumpWidget(_wrap(SparkBarChart(delta)));

      expect(
        find.byType(SparkBarChart),
        paints
          ..line()
          ..rrect(),
      );
    });

    testWidgets('an empty spark paints nothing', (tester) async {
      await tester.pumpWidget(
        _wrap(SparkBarChart(sparkBars(const [], start: start, slotCount: 7))),
      );

      expect(find.byType(SparkBarChart), paintsNothing);
    });
  });

  group('SparkHeatmap', () {
    final today = DateTime(2026, 8, 7);

    /// Cells of a strip [weeks] columns wide: one per day up to today, the
    /// rest of the current week is not yet history
    int cells(int weeks) => weeks * DateTime.daysPerWeek - (DateTime.daysPerWeek - today.weekday);

    List<MeasurementChartEntry> history(int days) => [
      for (var day = 0; day < days; day++)
        MeasurementChartEntry(day.isEven ? 8000 : 0, DateTime(2026, 8, 7 - day)),
    ];

    testWidgets('the strip covers the weeks the history spans', (tester) async {
      // Two weeks of readings fall into three calendar weeks
      await tester.pumpWidget(_wrap(SparkHeatmap(history(14), weeks: 4, today: today)));

      expect(find.byType(SparkHeatmap), paintsExactlyCountTimes(#drawRRect, cells(3)));
    });

    testWidgets('a longer history is cut to the weeks it was given', (tester) async {
      await tester.pumpWidget(_wrap(SparkHeatmap(history(60), weeks: 4, today: today)));

      expect(find.byType(SparkHeatmap), paintsExactlyCountTimes(#drawRRect, cells(4)));
    });

    testWidgets('an empty history still paints the grid', (tester) async {
      await tester.pumpWidget(_wrap(SparkHeatmap(const [], weeks: 4, today: today)));

      expect(find.byType(SparkHeatmap), paintsExactlyCountTimes(#drawRRect, cells(4)));
    });
  });
}
