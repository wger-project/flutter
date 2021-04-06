/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/nutritional_plans_screen.dart';
import 'package:wger/widgets/nutrition/forms.dart';

import 'base_provider_test.mocks.dart';
import 'utils.dart';

void main() {
  Widget createHomeScreen({locale = 'en'}) {
    final client = MockClient();
    when(client.delete(
      any,
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response('', 200));

    return ChangeNotifierProvider<Nutrition>(
      create: (context) => Nutrition(
        testAuthProvider,
        [
          NutritionalPlan(id: 1, description: 'test plan 1', creationDate: DateTime(2021, 01, 01)),
          NutritionalPlan(id: 2, description: 'test plan 2', creationDate: DateTime(2021, 01, 10)),
        ],
        client,
      ),
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NutritionScreen(),
        routes: {
          FormScreen.routeName: (ctx) => FormScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the nutritional plans screen', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    //debugDumpApp();
    expect(find.text('Nutritional plans'), findsOneWidget);
    expect(find.byType(Dismissible), findsNWidgets(2));
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('Test deleting an item by dragging the dismissible', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    await tester.drag(find.byKey(Key('1')), Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    // Confirmation dialog
    expect(find.byType(AlertDialog), findsOneWidget);

    // Confirm
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets('Test the form on the nutritional plan screen', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    expect(find.byType(PlanForm), findsNothing);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(PlanForm), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - EN', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    expect(find.text('1/1/2021'), findsOneWidget);
    expect(find.text('1/10/2021'), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - DE', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(locale: 'de'));

    expect(find.text('1.1.2021'), findsOneWidget);
    expect(find.text('10.1.2021'), findsOneWidget);
  });
}
