import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/ingredient_api.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/nutrition/forms.dart';

import '../../test_data/nutritional_plans.dart';
import '../fixtures/fixture_reader.dart';
import '../measurements/measurement_provider_test.mocks.dart';
import '../other/base_provider_test.mocks.dart';
import 'nutritional_plan_form_test.mocks.dart';

void main() {
  final ingredient = Ingredient(
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

  late MockWgerBaseProvider mockWgerBaseProvider;

  var mockNutrition = MockNutritionPlansProvider();
  final client = MockClient();

  setUp(() {
    mockWgerBaseProvider = MockWgerBaseProvider();
  });

  var plan1 = NutritionalPlan.empty();
  var meal1 = Meal();

  final Uri tUriRightCode = Uri.parse('https://localhost/api/v2/ingredient/?code=123');
  final Uri tUriEmptyCode = Uri.parse('https://localhost/api/v2/ingredient/?code="%20"');
  final Uri tUriBadCode = Uri.parse('https://localhost/api/v2/ingredient/?code=222');

  when(client.get(tUriRightCode, headers: anyNamed('headers'))).thenAnswer(
    (_) => Future.value(http.Response(fixture('nutrition/search_ingredient_right_code.json'), 200)),
  );

  when(client.get(tUriEmptyCode, headers: anyNamed('headers'))).thenAnswer(
    (_) => Future.value(http.Response(fixture('nutrition/search_ingredient_wrong_code.json'), 200)),
  );

  when(client.get(tUriBadCode, headers: anyNamed('headers'))).thenAnswer(
    (_) => Future.value(http.Response(fixture('nutrition/search_ingredient_wrong_code.json'), 200)),
  );

  setUp(() {
    plan1 = getNutritionalPlan();
    meal1 = plan1.meals.first;
    final MealItem mealItem = MealItem(ingredientId: ingredient.id, amount: 2);
    mockNutrition = MockNutritionPlansProvider();

    when(mockNutrition.searchIngredientWithCode('123')).thenAnswer((_) => Future.value(ingredient));
    when(mockNutrition.searchIngredientWithCode('')).thenAnswer((_) => Future.value(null));
    when(mockNutrition.searchIngredientWithCode('222')).thenAnswer((_) => Future.value(null));
    when(mockNutrition.searchIngredient(any,
            languageCode: anyNamed('languageCode'), searchEnglish: anyNamed('searchEnglish')))
        .thenAnswer(
      (_) => Future.value(
          IngredientApiSearch.fromJson(json.decode(fixture('nutrition/ingredient_suggestions')))
              .suggestions),
    );

    when(mockNutrition.addMealItem(any, meal1)).thenAnswer((_) => Future.value(mealItem));
  });

  Widget createMealItemFormScreen(Meal meal, String code, bool test, {locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ChangeNotifierProvider<NutritionPlansProvider>(
      create: (context) => mockNutrition,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: Scaffold(
          body: Scrollable(
            viewportBuilder: (BuildContext context, ViewportOffset position) =>
                MealItemForm(meal, const [], code, test),
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

    expect(find.byType(TypeAheadField<IngredientApiSearchEntry>), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byKey(const Key('scan-button')), findsOneWidget);
    expect(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)), findsOneWidget);

    expect(meal1.mealItems.length, 2);
  });

  group('Test the AlertDialogs for scanning result', () {
    testWidgets('with empty code', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '', true));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('with correct code', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('found-dialog')), findsOneWidget);
    });

    testWidgets('with incorrect code', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '222', true));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('notFound-dialog')), findsOneWidget);
    });
  });

  /*
  group('Test searchIngredientWithCode() function', () {
    test('with correct code', () async {
      final Ingredient? ingredient = await mockNutritionWithClient.searchIngredientWithCode('123');
      expect(ingredient!.id, 9436);
    });

    test('with incorrect code', () async {
      final Ingredient? ingredient = await mockNutritionWithClient.searchIngredientWithCode('222');
      expect(ingredient, null);
    });

    test('with empty code', () async {
      final Ingredient? ingredient = await mockNutritionWithClient.searchIngredientWithCode('');
      expect(ingredient, null);
    });
  });

   */

  group('Test weight formfield', () {
    testWidgets('add empty weight', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.enterText(find.byKey(const Key('field-weight')), '');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('add correct weight type', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.enterText(find.byKey(const Key('field-weight')), '2');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid number'), findsNothing);
    });
    testWidgets('add incorrect weight type', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.enterText(find.byKey(const Key('field-weight')), 'test');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid number'), findsOneWidget);
    });
  });

  group('Test ingredient found dialog', () {
    testWidgets('confirm found ingredient dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      final IngredientFormState formState = tester.state(find.byType(IngredientForm));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('found-dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('found-dialog-confirm-button')));
      await tester.pumpAndSettle();

      expect(formState.ingredientIdController.text, '1');
    });

    testWidgets('close found ingredient dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('found-dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('found-dialog-close-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('found-dialog')), findsNothing);
    });
  });

  group('Test the adding a new item to meal', () {
    testWidgets('save empty ingredient', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      expect(find.text('Please select an ingredient'), findsOneWidget);

      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('save ingredient without weight', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('found-dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('found-dialog-confirm-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('save ingredient with incorrect weight input type', (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('found-dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('found-dialog-confirm-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('save complete ingredient with correct weight input type',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMealItemFormScreen(meal1, '123', true));

      final IngredientFormState formState = tester.state(find.byType(IngredientForm));

      await tester.tap(find.byKey(const Key('scan-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('found-dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('found-dialog-confirm-button')));
      await tester.pumpAndSettle();

      expect(formState.ingredientIdController.text, '1');

      // once ID and weight are set, it'll fetchIngredient and show macros preview
      when(mockNutrition.fetchIngredient(1)).thenAnswer((_) => Future.value(
            Ingredient.fromJson(jsonDecode(fixture('nutrition/ingredient_59887_response.json'))),
          ));

      await tester.enterText(find.byKey(const Key('field-weight')), '2');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('found-dialog')), findsNothing);

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      expect(formState.mealItem.amount, 2);

      verify(mockNutrition.addMealItem(any, meal1));
    });
  });
}
