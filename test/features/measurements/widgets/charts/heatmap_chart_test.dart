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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/widgets/charts/chart_series.dart';
import 'package:wger/features/measurements/widgets/charts/heatmap_chart.dart';
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
}
