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
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

Widget _wrapChart(Widget chart) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SizedBox(width: 400, height: 300, child: chart),
  ),
);

void main() {
  final entries = [
    MeasurementChartEntry(1000, DateTime(2026, 1, 1)),
    MeasurementChartEntry(2000, DateTime(2026, 1, 2)),
  ];

  group('buildChartForMetricType routing', () {
    testWidgets('steps -> MeasurementBarChartWidgetFl', (tester) async {
      final widget = buildChartForMetricType(MetricType.steps, entries, [], 'steps');
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementBarChartWidgetFl), findsOneWidget);
      expect(find.byType(MeasurementChartWidgetFl), findsNothing);
    });

    testWidgets('custom -> MeasurementChartWidgetFl', (tester) async {
      final widget = buildChartForMetricType(MetricType.custom, entries, [], 'cm');
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);
      expect(find.byType(MeasurementBarChartWidgetFl), findsNothing);
    });

    testWidgets('energy -> MeasurementBarChartWidgetFl', (tester) async {
      final widget = buildChartForMetricType(MetricType.energy, entries, [], 'kcal');
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementBarChartWidgetFl), findsOneWidget);
    });
  });
}
