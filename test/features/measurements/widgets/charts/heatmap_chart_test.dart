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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/charts/series.dart';
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
