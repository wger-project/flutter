/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/nutritional_diary_detail.dart';

import '../../test_data/nutritional_plans.dart';

void main() {
  Widget getWidget({locale = 'en'}) {
    return MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SingleChildScrollView(
        child: Card(
          child: NutritionalDiaryDetailWidget(getNutritionalPlan(), DateTime(2021, 6, 1)),
        ),
      ),
    );
  }

  testWidgets('Test the detail view for the nutritional plan', (WidgetTester tester) async {
    await tester.pumpWidget(getWidget());

    expect(find.byType(FlNutritionalPlanPieChartWidget), findsOneWidget);
    expect(find.byType(Table), findsOneWidget);

    expect(find.text('519 kcal'), findsOneWidget, reason: 'find total energy');
    expect(find.text('6 g'), findsOneWidget, reason: 'find grams of protein');
    expect(find.text('18 g'), findsOneWidget, reason: 'find grams of carbs');
    expect(find.text('4 g'), findsOneWidget, reason: 'find grams of sugar');
    expect(find.text('29 g'), findsOneWidget, reason: 'find grams of fat');
    expect(find.text('14 g'), findsOneWidget, reason: 'find grams of saturated fat');
    expect(find.text('50 g'), findsOneWidget, reason: 'find grams of fiber');

    expect(find.text('100 g Water'), findsOneWidget, reason: 'Name of ingredient');
    expect(find.text('75 g Burger soup'), findsOneWidget, reason: 'Name of ingredient');
    expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
  });
}
