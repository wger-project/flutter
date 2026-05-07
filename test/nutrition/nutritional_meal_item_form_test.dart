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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/providers/nutrition_repository.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/nutrition/forms.dart';

import '../../test_data/nutritional_plans.dart';
import '../fake_connectivity.dart';
import '../fixtures/fixture_reader.dart';
import '../other/base_provider_test.mocks.dart';
import 'nutritional_plan_form_test.mocks.dart';

void main() {
  installFakeConnectivity();

  final ingredient = Ingredient(
    remoteId: '1',
    sourceName: 'Built-in testdata',
    sourceUrl: 'https://example.com/ingredient/1',
    id: 1,
    code: '123456787',
    name: 'Water',
    created: DateTime(2021, 5, 1),
    energy: 500,
    carbohydrates: 10,
    carbohydratesSugar: 2,
    protein: 5,
    fat: 20,
    fatSaturated: 7,
    fiber: 12,
    sodium: 0.5,
  );

  late MockNutritionRepository mockRepo;
  late MockIngredientRepository mockIngredientRepo;
  late ProviderContainer container;

  final client = MockClient();

  var plan1 = NutritionalPlan.empty();
  var meal1 = Meal();

  final Uri tUriRightCode = Uri.parse('https://localhost/api/v2/ingredientinfo/?code=123');
  final Uri tUriEmptyCode = Uri.parse('https://localhost/api/v2/ingredientinfo/?code="%20"');
  final Uri tUriBadCode = Uri.parse('https://localhost/api/v2/ingredientinfo/?code=222');

  when(client.get(tUriRightCode, headers: anyNamed('headers'))).thenAnswer(
    (_) => Future.value(http.Response(fixture('nutrition/ingredientinfo_right_code.json'), 200)),
  );

  when(client.get(tUriEmptyCode, headers: anyNamed('headers'))).thenAnswer(
    (_) => Future.value(http.Response(fixture('nutrition/ingredientinfo_wrong_code.json'), 200)),
  );

  when(client.get(tUriBadCode, headers: anyNamed('headers'))).thenAnswer(
    (_) => Future.value(http.Response(fixture('nutrition/ingredientinfo_wrong_code.json'), 200)),
  );

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    plan1 = getNutritionalPlan();
    meal1 = plan1.meals.first;
    final MealItem mealItem = MealItem(
      id: 'bb000000-0000-4000-8000-000000000010',
      mealId: 'aa000000-0000-4000-8000-000000000001',
      ingredientId: ingredient.id,
      amount: 2,
    );
    // Silence unused-local warning while we keep the fixture for documentation.
    // ignore: unnecessary_statements
    mealItem;

    mockRepo = MockNutritionRepository();
    mockIngredientRepo = MockIngredientRepository();

    when(
      mockIngredientRepo.searchIngredientByBarcode('123'),
    ).thenAnswer((_) => Future.value(ingredient));
    when(
      mockIngredientRepo.searchIngredientByBarcode(''),
    ).thenAnswer((_) => Future.value(null));
    when(
      mockIngredientRepo.searchIngredientByBarcode('222'),
    ).thenAnswer((_) => Future.value(null));
    when(
      mockIngredientRepo.searchIngredientServer(
        any,
        languageCode: anyNamed('languageCode'),
        searchLanguage: anyNamed('searchLanguage'),
        isVegan: anyNamed('isVegan'),
        isVegetarian: anyNamed('isVegetarian'),
        nutriscoreMax: anyNamed('nutriscoreMax'),
      ),
    ).thenAnswer(
      (_) => Future.value([ingredient1, ingredient2]),
    );

    when(mockRepo.addMealItemLocalDrift(any)).thenAnswer((_) async => Future.value());
    // Ingredient lookups go through PowerSync. Weight units now travel with
    // the Ingredient (inlined by REST or JOINed by the repository), so no
    // separate stub is needed.
    when(mockIngredientRepo.getById(any)).thenAnswer((_) async => ingredient);
    // NutritionNotifier.build() subscribes to three Drift streams (plans,
    // meals, diary entries) — emit the seed plan and meals so the combined
    // stream produces a value.
    when(mockRepo.watchAllDrift()).thenAnswer((_) => Stream.value([plan1]));
    when(mockRepo.watchAllMealsHydrated()).thenAnswer((_) => Stream.value(plan1.meals));
    when(mockRepo.watchAllLogsHydrated()).thenAnswer((_) => Stream.value(const []));

    container = ProviderContainer(
      overrides: [
        nutritionRepositoryProvider.overrideWithValue(mockRepo),
        ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
      ],
    );
    // Explicit listener keeps the provider element alive while we wait for
    // the Drift-stream emission ([plan1]) to land in state. Required so that
    // the form widget sees the seeded plan in state when it builds.
    container.listen(nutritionProvider, (_, _) {});
    await pumpEventQueue();
  });

  tearDown(() {
    container.dispose();
  });

  Widget createMealItemFormScreen(Meal meal, String code, bool test, {locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: Scaffold(
          body: Scrollable(
            viewportBuilder: (BuildContext context, ViewportOffset position) =>
                getMealItemForm(meal, const [], code, test),
          ),
        ),
        routes: {
          NutritionalPlanScreen.routeName: (ctx) => const NutritionalPlanScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the meal item form', (WidgetTester tester) async {
    await tester.pumpWidget(createMealItemFormScreen(meal1, '', true));
    await tester.pumpAndSettle();

    expect(find.byType(TypeAheadField<Ingredient>), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byKey(const Key('scan-button')), findsOneWidget);
    expect(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)), findsOneWidget);

    expect(meal1.mealItems.length, 2);
  });

  group('Test the AlertDialogs for scanning result', () {
    // TODO: why do we need to support empty barcodes?
    testWidgets('with empty code', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '', true));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ingredient-scan-result-dialog')), findsOneWidget);
      expect(find.byKey(const Key('ingredient-scan-result-dialog-confirm-button')), findsNothing);
    });

    testWidgets('with correct code', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ingredient-scan-result-dialog')), findsOneWidget);
      expect(find.byKey(const Key('ingredient-scan-result-dialog-confirm-button')), findsOneWidget);
    });

    testWidgets('with incorrect code', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '222', true));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ingredient-scan-result-dialog')), findsOneWidget);
      expect(find.byKey(const Key('ingredient-scan-result-dialog-confirm-button')), findsNothing);
    });
  });

  group('Test weight formfield', () {
    testWidgets('add empty weight', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.enterText(find.byKey(const Key('field-weight')), '');
      await tester.pump();

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pump();

      expect(find.text('Please enter a value'), findsOneWidget);
    });

    testWidgets('add correct weight type', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.enterText(find.byKey(const Key('field-weight')), '2');
      await tester.pump();

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pump();

      expect(find.text('Please enter a valid number'), findsNothing);
    });
    testWidgets('add incorrect weight type', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.enterText(find.byKey(const Key('field-weight')), 'test');
      await tester.pump();

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pump();

      expect(find.text('Please enter a valid number'), findsOneWidget);
    });
  });

  group('Test ingredient found dialog', () {
    testWidgets('confirm found ingredient dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      final IngredientFormState formState = tester.state(find.byType(IngredientForm));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ingredient-scan-result-dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('ingredient-scan-result-dialog-confirm-button')));
      await tester.pumpAndSettle();

      expect(formState.ingredientIdController.text, '1');
    });

    testWidgets('close found ingredient dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ingredient-scan-result-dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('ingredient-scan-result-dialog-close-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ingredient-scan-result-dialog')), findsNothing);
    });
  });

  group('Test the adding a new item to meal', () {
    testWidgets('save empty ingredient', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pump();

      expect(find.text('Please select an ingredient'), findsOneWidget);
      expect(find.text('Please enter a value'), findsOneWidget);
    });

    testWidgets('save ingredient without weight', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ingredient-scan-result-dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('ingredient-scan-result-dialog-confirm-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pump();

      expect(find.text('Please enter a value'), findsOneWidget);
    });

    testWidgets(
      'save complete ingredient with correct weight input type',
      (WidgetTester tester) async {
        await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

        final IngredientFormState formState = tester.state(find.byType(IngredientForm));

        await tester.tap(find.byKey(const Key('scan-button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('ingredient-scan-result-dialog')), findsOneWidget);

        await tester.tap(find.byKey(const Key('ingredient-scan-result-dialog-confirm-button')));
        await tester.pumpAndSettle();

        expect(formState.ingredientIdController.text, '1');

        await tester.enterText(find.byKey(const Key('field-weight')), '2');

        // once ID and weight are set, the macros preview renders directly from
        // the ingredient that selectIngredient stored on the form's MealItem.
        when(mockIngredientRepo.getById(1)).thenAnswer(
          (_) => Future.value(
            Ingredient.fromJson(jsonDecode(fixture('nutrition/ingredientinfo_59887.json'))),
          ),
        );
        await mockNetworkImagesFor(() => tester.pumpAndSettle());

        expect(find.byKey(const Key('ingredient-scan-result-dialog')), findsNothing);

        await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
        await tester.pump();

        expect(formState.mealItem.amount, 2);

        verify(mockRepo.addMealItemLocalDrift(any));
      },
    );
  });
}
