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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/nutrition_repository.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/nutrition/forms.dart';

import './nutritional_plan_form_test.mocks.dart';

@GenerateMocks([NutritionRepository, IngredientRepository])
void main() {
  late MockNutritionRepository mockRepo;
  late MockIngredientRepository mockIngredientRepo;

  final plan1 = NutritionalPlan(
    id: 1,
    creationDate: DateTime(2021, 1, 1),
    startDate: DateTime(2021, 1, 1),
    endDate: DateTime(2021, 2, 10),
    description: 'test plan 1',
  );
  final plan2 = NutritionalPlan.empty();

  setUp(() {
    mockRepo = MockNutritionRepository();
    mockIngredientRepo = MockIngredientRepository();

    when(mockRepo.updatePlan(any, any)).thenAnswer((_) async {});
    when(mockRepo.createPlan(any)).thenAnswer((_) async => plan1.toJson());
  });

  Widget createHomeScreen(NutritionalPlan plan, {locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ProviderScope(
      overrides: [
        nutritionRepositoryProvider.overrideWithValue(mockRepo),
        ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: Scaffold(body: PlanForm(plan)),
        routes: {
          NutritionalPlanScreen.routeName: (ctx) => const NutritionalPlanScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the nutritional plan form', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(plan1));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)), findsOneWidget);
  });

  testWidgets('Test editing an existing nutritional plan', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(plan1));
    await tester.pumpAndSettle();

    expect(find.text('test plan 1'), findsOneWidget, reason: 'Description is filled in');
    expect(find.text('1/1/2021'), findsOneWidget, reason: 'Start date is filled in');
    expect(find.text('2/10/2021'), findsOneWidget, reason: 'End date is filled in');

    await tester.enterText(find.byKey(const Key('field-description')), 'New description');
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));

    // Correct method was called
    verify(mockRepo.updatePlan(any, any));
    verifyNever(mockRepo.createPlan(any));
  });

  testWidgets('Test creating a new nutritional plan', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(plan2));
    await tester.pumpAndSettle();

    expect(
      find.text(''),
      findsNWidgets(2),
      reason: 'New nutritional plan needs description, and end date',
    );
    // there's also the start date, but it will have a value depending on 'now'
    await tester.enterText(find.byKey(const Key('field-description')), 'New cool plan');
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));

    // Correct method was called
    verifyNever(mockRepo.updatePlan(any, any));
    verify(mockRepo.createPlan(any));
  });
}
