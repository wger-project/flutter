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

/// Pumps a MaterialApp whose body is the widget list built by [builder].
Future<void> _pumpWidgetList(
  WidgetTester tester,
  List<Widget> Function(BuildContext context) builder,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (ctx) => Scaffold(
          body: SingleChildScrollView(child: Column(children: builder(ctx))),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final rawEntries = [
    MeasurementChartEntry(10, DateTime(2026, 1, 1)),
    MeasurementChartEntry(20, DateTime(2026, 1, 10)),
  ];
  final avgEntries = moving7dAverage(rawEntries);

  group('buildChartForMetricType routing', () {
    final entries = [
      MeasurementChartEntry(1000, DateTime(2026, 1, 1)),
      MeasurementChartEntry(2000, DateTime(2026, 1, 2)),
    ];

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

  group('getOverviewWidgets', () {
    testWidgets('empty raw shows no-data placeholder', (tester) async {
      await _pumpWidgetList(tester, (ctx) => getOverviewWidgets('Test', [], [], 'cm', ctx));

      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('non-empty avg includes MeasurementOverallChangeWidget', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => getOverviewWidgets('Test', rawEntries, avgEntries, 'cm', ctx),
      );

      expect(find.byType(MeasurementOverallChangeWidget), findsOneWidget);
    });
  });

  group('getOverviewWidgetsSeries legend', () {
    testWidgets('three Indicator widgets for non-summed metric (custom)', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => getOverviewWidgetsSeries(
          'Weight',
          rawEntries,
          avgEntries,
          [],
          'kg',
          ctx,
          metricType: MetricType.custom,
        ),
      );

      expect(find.byType(Indicator), findsNWidgets(3));
    });

    testWidgets('two Indicator widgets for summed metric (steps, no trend)', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => getOverviewWidgetsSeries(
          'Steps',
          rawEntries,
          avgEntries,
          [],
          'steps',
          ctx,
          metricType: MetricType.steps,
        ),
      );

      // isSummedPerDay -> trend indicator is hidden
      expect(find.byType(Indicator), findsNWidgets(2));
    });
  });
}
