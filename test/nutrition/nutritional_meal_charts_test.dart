/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/widgets/nutrition/charts.dart';

void main() {
  Widget createMealBarChartScreen(NutritionalValues logged, NutritionalValues planned) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            height: 300,
            width: 300,
            child: MealDiaryBarChartWidget(
              logged: logged,
              planned: planned,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('MealDiaryBarChart renders correctly with valid data', (WidgetTester tester) async {
    final logged = NutritionalValues.values(
      500,
      50,
      50,
      1,
      10,
      1,
      1,
      1,
    );
    final planned = NutritionalValues.values(
      1000,
      100,
      100,
      1,
      20,
      1,
      1,
      1,
    );

    await tester.pumpWidget(createMealBarChartScreen(logged, planned));
    await tester.pumpAndSettle();

    final barChartFinder = find.byType(BarChart);
    expect(barChartFinder, findsOneWidget, reason: 'BarChart should be visible');

    // Verify the chart calculated 50% for energy (500 / 1000)
    final barChart = tester.widget<BarChart>(barChartFinder);
    final energyRod = barChart.data.barGroups.firstWhere((group) => group.x == 3).barRods.first;
    expect(energyRod.toY, 50.0, reason: 'Energy bar should calculate to 50%');
  });

  testWidgets('MealDiaryBarChart does not crash when logged meal data are zero', (
    WidgetTester tester,
  ) async {
    final loggedZero = NutritionalValues.values(
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    );

    final planned = NutritionalValues.values(
      2000,
      150,
      200,
      1,
      70,
      1,
      1,
      1,
    );

    await tester.pumpWidget(createMealBarChartScreen(loggedZero, planned));
    await tester.pumpAndSettle();

    final barChartFinder = find.byType(BarChart);
    expect(
      barChartFinder,
      findsOneWidget,
      reason: 'BarChart should render safely even with 0 logged values',
    );

    final barChart = tester.widget<BarChart>(barChartFinder);

    // Verify all bars are 0.0 as nothing has been logged
    for (var group in barChart.data.barGroups) {
      expect(
        group.barRods.first.toY,
        0.0,
        reason:
            'Bar at index ${group.x} should fallback to 0.0 when logged data is empty to prevent Infinity crashes',
      );
    }
  });

  testWidgets('MealDiaryBarChart does not crash when planned macros are zero', (
    WidgetTester tester,
  ) async {
    final logged = NutritionalValues.values(
      100,
      10,
      10,
      1,
      5,
      1,
      1,
      1,
    );

    final plannedZero = NutritionalValues.values(
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    );

    await tester.pumpWidget(createMealBarChartScreen(logged, plannedZero));
    await tester.pumpAndSettle();

    final barChartFinder = find.byType(BarChart);
    expect(
      barChartFinder,
      findsOneWidget,
      reason: 'BarChart should render safely even with 0 planned values',
    );

    final barChart = tester.widget<BarChart>(barChartFinder);

    // Verify all bars fallback to 0.0 safely instead of Infinity
    for (var group in barChart.data.barGroups) {
      expect(
        group.barRods.first.toY,
        0.0,
        reason: 'Bar at index ${group.x} should fallback to 0.0 to prevent Infinity crashes',
      );
    }
  });

  testWidgets('MealDiaryBarChart does not crash when both planned and logged are zero', (
    WidgetTester tester,
  ) async {
    final emptyValues = NutritionalValues.values(
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    );

    await tester.pumpWidget(createMealBarChartScreen(emptyValues, emptyValues));
    await tester.pumpAndSettle();

    final barChartFinder = find.byType(BarChart);
    expect(barChartFinder, findsOneWidget);

    final barChart = tester.widget<BarChart>(barChartFinder);
    for (var group in barChart.data.barGroups) {
      expect(group.barRods.first.toY, 0.0);
    }
  });
}
