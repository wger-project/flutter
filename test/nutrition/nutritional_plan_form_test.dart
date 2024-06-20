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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/nutrition/forms.dart';

import './nutritional_plan_form_test.mocks.dart';

@GenerateMocks([NutritionPlansProvider])
void main() {
  var mockNutrition = MockNutritionPlansProvider();

  final plan1 = NutritionalPlan(
    id: 1,
    creationDate: DateTime(2021, 1, 1),
    description: 'test plan 1',
  );
  final plan2 = NutritionalPlan.empty();

  when(mockNutrition.editPlan(any)).thenAnswer((_) => Future.value(plan1));
  when(mockNutrition.addPlan(any)).thenAnswer((_) => Future.value(plan2));

  setUp(() {
    mockNutrition = MockNutritionPlansProvider();
  });

  Widget createHomeScreen(NutritionalPlan plan, {locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ChangeNotifierProvider<NutritionPlansProvider>(
      create: (context) => mockNutrition,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: Scaffold(
          body: PlanForm(plan),
        ),
        routes: {
          NutritionalPlanScreen.routeName: (ctx) => const NutritionalPlanScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the nutritional plan form', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(plan1));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)), findsOneWidget);
  });

  testWidgets('Test editing an existing nutritional plan', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(plan1));
    await tester.pumpAndSettle();

    expect(
      find.text('test plan 1'),
      findsOneWidget,
      reason: 'Description of existing nutritional plan is filled in',
    );
    await tester.enterText(find.byKey(const Key('field-description')), 'New description');
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));

    // Correct method was called
    verify(mockNutrition.editPlan(any));
    verifyNever(mockNutrition.addPlan(any));

    // TODO(x): edit calls Navigator.pop(), since the form can only be reached from the
    //       detail page. The test needs to add the detail page to the stack so that
    //       this can be checked.
    // https://stackoverflow.com/questions/50704647/how-to-test-navigation-via-navigator-in-flutter

    // Detail page
    //await tester.pumpAndSettle();
    //expect(
    // find.text(('New description')),
    //findsOneWidget,
    //reason: 'Nutritional plan detail page',
    //);
  });

  testWidgets('Test creating a new nutritional plan', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(plan2));
    await tester.pumpAndSettle();

    expect(find.text(''), findsOneWidget, reason: 'New nutritional plan has no description');
    await tester.enterText(find.byKey(const Key('field-description')), 'New cool plan');
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));

    // Correct method was called
    verifyNever(mockNutrition.editPlan(any));
    verify(mockNutrition.addPlan(any));

    // Detail page
    await tester.pumpAndSettle();
    expect(find.text('New cool plan'), findsOneWidget, reason: 'Nutritional plan detail page');
  });
}
