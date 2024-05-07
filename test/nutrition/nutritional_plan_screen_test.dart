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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import '../../test_data/nutritional_plans.dart';
import '../fixtures/fixture_reader.dart';
import 'helper.dart';
import 'nutritional_plan_screen_test.mocks.dart';

@GenerateMocks([WgerBaseProvider, AuthProvider, http.Client])
void main() {
  // makeUrl('nutritionplan', {id: 1, objectMethod: null, query: null})
  // Add a stub for this method using Mockito's 'when' API, or generate the MockWgerBaseProvider mock with the @GenerateNiceMocks annotation (see https://pub.dev/documentation/mockito/latest/annotations/MockSpec-class.html).)

  late NutritionPlansProvider nutritionProvider;
  late MockWgerBaseProvider mockWgerBaseProvider;

  setUp(() {
    mockWgerBaseProvider = MockWgerBaseProvider();
    nutritionProvider = NutritionPlansProvider(mockWgerBaseProvider, []);

    const String planInfoUrl = 'nutritionplaninfo';
    const String planUrl = 'nutritionplan';
    const String diaryUrl = 'nutritiondiary';
    const String ingredientUrl = 'ingredient';

    final Map<String, dynamic> nutritionalPlanInfoResponse = jsonDecode(
      fixture('nutrition/nutritional_plan_info_detail_response.json'),
    );
    final Map<String, dynamic> nutritionalPlanDetailResponse = jsonDecode(
      fixture('nutrition/nutritional_plan_detail_response.json'),
    );
    final List<dynamic> nutritionDiaryResponse = jsonDecode(
      fixture('nutrition/nutrition_diary_response.json'),
    )['results'];
    final Map<String, dynamic> ingredient59887Response = jsonDecode(
      fixture('nutrition/ingredient_59887_response.json'),
    );
    final Map<String, dynamic> ingredient10065Response = jsonDecode(
      fixture('nutrition/ingredient_10065_response.json'),
    );
    final Map<String, dynamic> ingredient58300Response = jsonDecode(
      fixture('nutrition/ingredient_58300_response.json'),
    );

    final ingredientList = [
      Ingredient.fromJson(ingredient59887Response),
      Ingredient.fromJson(ingredient10065Response),
      Ingredient.fromJson(ingredient58300Response),
    ];

    nutritionProvider.ingredients = ingredientList;

    final Uri planInfoUri = Uri(
      scheme: 'http',
      host: 'localhost',
      path: 'api/v2/$planInfoUrl/1',
    );
    final Uri planUri = Uri(
      scheme: 'http',
      host: 'localhost',
      path: 'api/v2/$planUrl',
    );
    final Uri diaryUri = Uri(
      scheme: 'http',
      host: 'localhost',
      path: 'api/v2/$diaryUrl',
    );
    when(mockWgerBaseProvider.makeUrl(planInfoUrl, id: anyNamed('id'))).thenReturn(planInfoUri);
    when(mockWgerBaseProvider.makeUrl(planUrl, id: anyNamed('id'))).thenReturn(planUri);
    when(mockWgerBaseProvider.makeUrl(diaryUrl, query: anyNamed('query'))).thenReturn(diaryUri);
    when(mockWgerBaseProvider.fetch(planInfoUri)).thenAnswer(
      (realInvocation) => Future.value(nutritionalPlanInfoResponse),
    );
    when(mockWgerBaseProvider.fetch(planUri)).thenAnswer(
      (realInvocation) => Future.value(nutritionalPlanDetailResponse),
    );
    when(mockWgerBaseProvider.fetchPaginated(diaryUri)).thenAnswer(
      (realInvocation) => Future.value(nutritionDiaryResponse),
    );
  });

/*
  late MockWgerBaseProvider mockBaseProvider;
//  late ExercisesProvider provider;

  const String npPlanUrl = 'nutritionplan';

  final Uri tNpPlanEntriesUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/$npPlanUrl/',
  );
*/
  Widget createNutritionalPlan({locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();
    final mockBaseProvider = MockWgerBaseProvider();

    final plan = getNutritionalPlan();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NutritionPlansProvider>(
          create: (context) => NutritionPlansProvider(mockBaseProvider, []),
        ),
        ChangeNotifierProvider<BodyWeightProvider>(
          create: (context) => BodyWeightProvider(mockBaseProvider),
        ),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: RouteSettings(arguments: plan),
              builder: (_) => NutritionalPlanScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
      ),
    );
  }

  testGoldens(
    'Test the widgets on the nutritional plan screen',
    (tester) async {
      await loadAppFonts();
      await tester.takeScreenshot(name: 'die1');
      final globalKey = GlobalKey();
      await tester.pumpWidgetBuilder(
        Material(
          key: globalKey,
        ),
        wrapper: materialAppWrapper(
          localizations: [
            AppLocalizations.delegate,
          ],
        ),
        surfaceSize: const Size(500, 1000),
      );
      await tester.pumpWidget(createNutritionalPlan());
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'nutritional_plan_1_default_view');

      // Default view shows plan description, info button, and no ingredients
      expect(find.text('Less fat, more protein'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsNWidgets(3)); // 2 meals, 1 "other logs"
      expect(find.byIcon(Icons.info), findsNothing);
      expect(find.text('100g Water'), findsNothing);
      expect(find.text('75g Burger soup'), findsNothing);

      // tap the first info button changes it and reveals ingredients for the first meal
      var infoOutlineButtons = find.byIcon(Icons.info_outline);
      await tester.tap(infoOutlineButtons.first); // 2nd button shows up also, but is off-screen
      await tester.pumpAndSettle();
      await tester.takeScreenshot(name: 'die2');
      await screenMatchesGolden(tester, 'nutritional_plan_2_one_meal_with_ingredients');

      // Ingredients show up now
      expect(find.text('100g Water'), findsOneWidget);
      expect(find.text('75g Burger soup'), findsOneWidget);

      // .. and the button icon has changed
      expect(find.byIcon(Icons.info_outline), findsNWidgets(2));
      expect(find.byIcon(Icons.info), findsOneWidget);

      // the goals widget pushes this content down a bit.
      // let's first find our icon (note: the previous icon no longer matches)
      infoOutlineButtons = find.byIcon(Icons.info_outline);

      await tester.scrollUntilVisible(infoOutlineButtons.first, 30);
      expect(find.text('300g Broccoli cake'), findsNothing);

      await tester.tap(infoOutlineButtons.first);
      await tester.pumpAndSettle();
      await screenMatchesGolden(tester, 'nutritional_plan_3_both_meals_with_ingredients');
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.info), findsNWidgets(2));

      await tester.scrollUntilVisible(find.text('300g Broccoli cake'), 30);
      expect(find.text('300g Broccoli cake'), findsOneWidget);

      expect(find.byType(Card), findsNWidgets(3));
    },
  );

  testWidgets('Tests the localization of times - EN', (WidgetTester tester) async {
    await tester.pumpWidget(createNutritionalPlan());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('5:00 PM'), findsOneWidget);
  });

  testWidgets('Tests the localization of times - DE', (WidgetTester tester) async {
    await tester.pumpWidget(createNutritionalPlan(locale: 'de'));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('17:00'), findsOneWidget);
  });
}
