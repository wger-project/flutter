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
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/nutritional_plans_screen.dart';
import 'package:wger/widgets/nutrition/forms.dart';

import 'nutritional_plan_screen_test.mocks.dart';

@GenerateMocks([AuthProvider, WgerBaseProvider, http.Client])
void main() {
  final mockAuthProvider = MockAuthProvider();
  final mockBaseProvider = MockWgerBaseProvider();
  final client = MockClient();

  Widget createHomeScreen({locale = 'en'}) {
    when(client.delete(
      any,
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response('', 200));

    when(mockBaseProvider.deleteRequest(any, any)).thenAnswer(
      (_) async => http.Response('', 200),
    );

    when(mockAuthProvider.token).thenReturn('1234');
    when(mockAuthProvider.serverUrl).thenReturn('http://localhost');
    when(mockAuthProvider.getAppNameHeader()).thenReturn('wger app');

    return ChangeNotifierProvider<NutritionPlansProvider>(
      create: (context) => NutritionPlansProvider(
        mockBaseProvider,
        [
          NutritionalPlan(
            id: 1,
            description: 'test plan 1',
            creationDate: DateTime(2021, 01, 01),
          ),
          NutritionalPlan(
            id: 2,
            description: 'test plan 2',
            creationDate: DateTime(2021, 01, 10),
          ),
        ],
      ),
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const NutritionalPlansScreen(),
        routes: {
          FormScreen.routeName: (ctx) => const FormScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the nutritional plans screen', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    //debugDumpApp();
    expect(find.text('Nutritional plans'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('Test deleting an item using the Delete button', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    await tester.tap(find.byIcon(Icons.delete).first);

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
