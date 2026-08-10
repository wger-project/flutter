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
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/charts/spark.dart';
import 'package:wger/features/measurements/widgets/charts/spark_charts.dart';

Widget _wrap(Widget spark) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 150, height: 40, child: spark)),
);

void main() {
  final start = DateTime(2026, 8, 1);

  group('SparkLineChart', () {
    testWidgets('paints a line for a series, and nothing for an empty one', (tester) async {
      final entries = [
        MeasurementChartEntry(80, DateTime(2026, 8, 1)),
        MeasurementChartEntry(81, DateTime(2026, 8, 3)),
        MeasurementChartEntry(80.5, DateTime(2026, 8, 7)),
      ];

      await tester.pumpWidget(_wrap(SparkLineChart(entries, start: start, days: 7)));
      expect(find.byType(SparkLineChart), findsOneWidget);

      // An empty series paints nothing, but the widget itself never fails
      await tester.pumpWidget(_wrap(SparkLineChart(const [], start: start, days: 7)));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a flat series stays paintable instead of dividing by zero', (tester) async {
      final entries = [
        MeasurementChartEntry(80, DateTime(2026, 8, 1)),
        MeasurementChartEntry(80, DateTime(2026, 8, 5)),
      ];

      await tester.pumpWidget(_wrap(SparkLineChart(entries, start: start, days: 7)));

      expect(tester.takeException(), isNull);
    });

    testWidgets('dots mode renders for a sparse series', (tester) async {
      final entries = [MeasurementChartEntry(38.5, DateTime(2026, 8, 1))];

      await tester.pumpWidget(
        _wrap(SparkLineChart(entries, start: start, days: 91, dots: true)),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('SparkBarChart', () {
    testWidgets('paints plain, floating, stacked and signed data', (tester) async {
      final variants = [
        sparkBars(
          [
            MeasurementChartEntry(8000, DateTime(2026, 8, 2)),
          ],
          start: start,
          slotCount: 7,
        ),
        sparkFloatingBars(
          [
            MeasurementChartEntry(100, DateTime(2026, 8, 2), min: 79, max: 122),
          ],
          start: start,
          slotCount: 7,
        ),
        sparkStackedBars(
          [
            MeasurementStackedEntry(DateTime(2026, 8, 2), const [240, 60]),
          ],
          start: start,
          slotCount: 7,
        ),
        sparkDeltaBars(
          [
            MeasurementChartEntry(-0.4, DateTime(2026, 8, 3)),
          ],
          start: start,
          slotCount: 9,
        ),
      ];

      for (final data in variants) {
        await tester.pumpWidget(_wrap(SparkBarChart(data)));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('an empty spark paints nothing without failing', (tester) async {
      await tester.pumpWidget(
        _wrap(SparkBarChart(sparkBars(const [], start: start, slotCount: 7))),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('SparkHeatmap', () {
    testWidgets('paints the four-week strip', (tester) async {
      final today = DateTime(2026, 8, 7);
      final days = [
        for (var day = 0; day < 14; day++)
          MeasurementChartEntry(day.isEven ? 8000 : 0, DateTime(2026, 8, 7 - day)),
      ];

      await tester.pumpWidget(_wrap(SparkHeatmap(days, weeks: 4, today: today)));

      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty history paints the empty grid', (tester) async {
      await tester.pumpWidget(_wrap(SparkHeatmap(const [], weeks: 4, today: DateTime(2026, 8, 7))));

      expect(tester.takeException(), isNull);
    });
  });
}
