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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/helpers/shared_preferences.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/nutrition/widgets.dart';

import '../../test_data/nutritional_plans.dart';
import 'nutritional_plan_form_test.mocks.dart';

void main() {
  late MockNutritionPlansProvider mockNutrition;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    await PreferenceHelper.instance.migrationSupportFunctionForSharedPreferences();
    mockNutrition = MockNutritionPlansProvider();
    when(
      mockNutrition.searchIngredient(
        any,
        languageCode: anyNamed('languageCode'),
        searchLanguage: anyNamed('searchLanguage'),
        isVegan: anyNamed('isVegan'),
        isVegetarian: anyNamed('isVegetarian'),
        nutriscoreMax: anyNamed('nutriscoreMax'),
      ),
    ).thenAnswer(
      (invocation) => Future.value([
        Ingredient(
          id: 1,
          name: 'Test Ingredient',
          remoteId: '1',
          sourceName: 'Test',
          sourceUrl: 'http://test.com',
          code: '123',
          energy: 100,
          protein: 10,
          carbohydrates: 10,
          carbohydratesSugar: 10,
          fat: 10,
          fatSaturated: 1,
          fiber: 1,
          sodium: 1,
          created: DateTime.now(),
        ),
      ]),
    );

    // Mock cacheIngredient as it might be called
    when(mockNutrition.cacheIngredient(any)).thenAnswer((_) => Future.value());
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      child: ChangeNotifierProvider<NutritionPlansProvider>.value(
        value: mockNutrition,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: IngredientTypeahead(
              TextEditingController(),
              TextEditingController(),
              selectIngredient: (id, name, amount) {},
              onDeselectIngredient: () {},
              onUpdateSearchQuery: (query) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Filter dialog opens and shows switches', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());

    final filterButtonFinder = find.byIcon(Icons.tune);
    expect(filterButtonFinder, findsOneWidget);
    await tester.tap(filterButtonFinder);
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Vegan'), findsOneWidget); // Assuming English locale
    expect(find.text('Vegetarian'), findsOneWidget);

    final veganSwitchFinder = find.widgetWithText(SwitchListTile, 'Vegan');
    final vegetarianSwitchFinder = find.widgetWithText(SwitchListTile, 'Vegetarian');

    expect(tester.widget<SwitchListTile>(veganSwitchFinder).value, isFalse);
    expect(tester.widget<SwitchListTile>(vegetarianSwitchFinder).value, isFalse);

    await tester.tap(veganSwitchFinder);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(veganSwitchFinder).value, isTrue);

    await tester.tap(vegetarianSwitchFinder);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(vegetarianSwitchFinder).value, isTrue);
  });

  testWidgets('Shows only Vegan chip when ingredient is vegan', (WidgetTester tester) async {
    // ingredient1 (Water) is vegan + vegetarian
    when(
      mockNutrition.searchIngredient(
        any,
        languageCode: anyNamed('languageCode'),
        searchLanguage: anyNamed('searchLanguage'),
        isVegan: anyNamed('isVegan'),
        isVegetarian: anyNamed('isVegetarian'),
        nutriscoreMax: anyNamed('nutriscoreMax'),
      ),
    ).thenAnswer((_) => Future.value([ingredient1]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextFormField), 'Water');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Vegan'), findsOneWidget);
    expect(find.text('Vegetarian'), findsNothing);
  });

  testWidgets('Shows Vegetarian chip when ingredient is only vegetarian', (
    WidgetTester tester,
  ) async {
    // milk is vegetarian but not vegan
    when(
      mockNutrition.searchIngredient(
        any,
        languageCode: anyNamed('languageCode'),
        searchLanguage: anyNamed('searchLanguage'),
        isVegan: anyNamed('isVegan'),
        isVegetarian: anyNamed('isVegetarian'),
        nutriscoreMax: anyNamed('nutriscoreMax'),
      ),
    ).thenAnswer((_) => Future.value([milk]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextFormField), 'Milk');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Vegetarian'), findsOneWidget);
    expect(find.text('Vegan'), findsNothing);
  });

  testWidgets('Shows no dietary chips when ingredient has no info', (WidgetTester tester) async {
    // ingredient2 (Burger soup) has no dietary info
    when(
      mockNutrition.searchIngredient(
        any,
        languageCode: anyNamed('languageCode'),
        searchLanguage: anyNamed('searchLanguage'),
        isVegan: anyNamed('isVegan'),
        isVegetarian: anyNamed('isVegetarian'),
        nutriscoreMax: anyNamed('nutriscoreMax'),
      ),
    ).thenAnswer((_) => Future.value([ingredient2]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(TextFormField), 'Burger');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Vegan'), findsNothing);
    expect(find.text('Vegetarian'), findsNothing);
  });

  testWidgets('Search calls provider with correct filter values', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    // The dropdown should be visible
    expect(find.byType(DropdownButton<IngredientSearchLanguage>), findsOneWidget);

    // Toggle Vegan switch to ON
    await tester.tap(find.widgetWithText(SwitchListTile, 'Vegan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Act
    final textFieldFinder = find.byType(TypeAheadField<Ingredient>);
    expect(textFieldFinder, findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Apple');
    await tester.pump(const Duration(milliseconds: 600)); // wait for debounce

    // Assert
    verify(
      mockNutrition.searchIngredient(
        'Apple',
        languageCode: 'en',
        searchLanguage: IngredientSearchLanguage.current,
        isVegan: true,
        isVegetarian: false,
        nutriscoreMax: null,
      ),
    ).called(1);
  });

  testWidgets('Nutri-Score slider is always visible and defaults to Off', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    // Slider is rendered by default, at the Off position (value == 0)
    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);
    expect(tester.widget<Slider>(sliderFinder).value, 0.0);

    // The "No filter" helper text is shown
    expect(find.text('No filter'), findsOneWidget);
  });

  testWidgets('Moving the slider sends nutriscoreMax on subsequent search', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    // Move the slider off the Off position — index 1 is the first grade, A
    final sliderFinder = find.byType(Slider);
    final Slider slider = tester.widget<Slider>(sliderFinder);
    slider.onChanged!(1.0);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Act
    await tester.enterText(find.byType(TextFormField), 'Apple');
    await tester.pump(const Duration(milliseconds: 600));

    // Assert — index 1 maps to NutriScore.a
    verify(
      mockNutrition.searchIngredient(
        'Apple',
        languageCode: 'en',
        searchLanguage: IngredientSearchLanguage.current,
        isVegan: false,
        isVegetarian: false,
        nutriscoreMax: NutriScore.a,
      ),
    ).called(1);
  });

  testWidgets('Search omits nutriscoreMax when the slider is at Off', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(find.byType(TextFormField), 'Apple');
    await tester.pump(const Duration(milliseconds: 600));

    verify(
      mockNutrition.searchIngredient(
        'Apple',
        languageCode: 'en',
        searchLanguage: IngredientSearchLanguage.current,
        isVegan: false,
        isVegetarian: false,
        nutriscoreMax: null,
      ),
    ).called(1);
  });
}
