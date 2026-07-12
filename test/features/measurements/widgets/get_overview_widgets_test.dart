/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

void main() {
  final rawEntries = [
    MeasurementChartEntry(10, DateTime(2026, 1, 1)),
    MeasurementChartEntry(20, DateTime(2026, 1, 10)),
  ];
  final avgEntries = moving7dAverage(rawEntries);

  group('getOverviewWidgets', () {
    testWidgets('empty raw shows no-data placeholder', (tester) async {
      late List<Widget> widgets;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (ctx) {
              widgets = getOverviewWidgets('Test', [], [], 'cm', ctx);
              return Scaffold(
                body: SingleChildScrollView(child: Column(children: widgets)),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('non-empty avg includes MeasurementOverallChangeWidget', (tester) async {
      late List<Widget> widgets;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (ctx) {
              widgets = getOverviewWidgets('Test', rawEntries, avgEntries, 'cm', ctx);
              return Scaffold(
                body: SingleChildScrollView(child: Column(children: widgets)),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementOverallChangeWidget), findsOneWidget);
    });
  });

  group('getOverviewWidgetsSeries — Indicator legend', () {
    testWidgets('three Indicator widgets for non-summed metric (custom)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (ctx) {
              final widgets = getOverviewWidgetsSeries(
                'Weight',
                rawEntries,
                avgEntries,
                [],
                'kg',
                ctx,
                metricType: MetricType.custom,
              );
              return Scaffold(
                body: SingleChildScrollView(child: Column(children: widgets)),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Indicator), findsNWidgets(3));
    });

    testWidgets('two Indicator widgets for summed metric (steps — no trend)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (ctx) {
              final widgets = getOverviewWidgetsSeries(
                'Steps',
                rawEntries,
                avgEntries,
                [],
                'steps',
                ctx,
                metricType: MetricType.steps,
              );
              return Scaffold(
                body: SingleChildScrollView(child: Column(children: widgets)),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // isSummedPerDay -> trend indicator is hidden
      expect(find.byType(Indicator), findsNWidgets(2));
    });
  });
}
