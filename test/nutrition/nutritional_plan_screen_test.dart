/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/body_weight_repository.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/nutrition_repository.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';

import '../../test_data/body_weight.dart';
import '../../test_data/nutritional_plans.dart';
import '../fixtures/fixture_reader.dart';
import 'nutritional_plan_screen_test.mocks.dart';

@GenerateMocks([
  NutritionRepository,
  IngredientRepository,
  http.Client,
  BodyWeightRepository,
])
void main() {
  late BodyWeightRepository mockBodyWeightRepository;
  late MockNutritionRepository mockNutritionRepo;
  late MockIngredientRepository mockIngredientRepo;

  late Map<String, dynamic> nutritionalPlanInfoResponse;
  late Map<String, dynamic> nutritionalPlanDetailResponse;
  late List<dynamic> nutritionDiaryResponse;
  late Ingredient fetchedIngredient;

  setUp(() {
    mockBodyWeightRepository = MockBodyWeightRepository();
    when(
      mockBodyWeightRepository.watchAllDrift(),
    ).thenAnswer((_) => Stream.value([testWeightEntry1]));

    mockNutritionRepo = MockNutritionRepository();
    mockIngredientRepo = MockIngredientRepository();

    when(mockIngredientRepo.getById(any)).thenAnswer((_) async => null);
    // NutritionNotifier.build() auto-fetches plans on first read.
    when(mockNutritionRepo.fetchAllPlans()).thenAnswer((_) async => []);

    nutritionalPlanInfoResponse = jsonDecode(
      fixture('nutrition/nutritional_plan_info_detail_response.json'),
    );
    nutritionalPlanDetailResponse = jsonDecode(
      fixture('nutrition/nutritional_plan_detail_response.json'),
    );
    nutritionDiaryResponse = jsonDecode(
      fixture('nutrition/nutrition_diary_response.json'),
    )['results'];
    fetchedIngredient = Ingredient.fromJson(
      jsonDecode(fixture('nutrition/ingredientinfo_10065.json')),
    );

    when(
      mockNutritionRepo.fetchPlanSparse(any),
    ).thenAnswer((_) async => nutritionalPlanDetailResponse);
    when(mockNutritionRepo.fetchPlanFull(any)).thenAnswer((_) async => nutritionalPlanInfoResponse);
    when(mockNutritionRepo.fetchLogsForPlan(any)).thenAnswer((_) async => nutritionDiaryResponse);
    when(mockNutritionRepo.fetchIngredient(any)).thenAnswer((_) async => fetchedIngredient);
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        bodyWeightRepositoryProvider.overrideWithValue(mockBodyWeightRepository),
        nutritionRepositoryProvider.overrideWithValue(mockNutritionRepo),
        ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createNutritionalPlan({locale = 'en', required ProviderContainer container}) {
    final key = GlobalKey<NavigatorState>();
    final plan = getNutritionalPlan();

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        key: GlobalKey(),
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: RouteSettings(arguments: plan),
              builder: (_) => const NutritionalPlanScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
      ),
    );
  }

  testWidgets(
    'Test the widgets on the nutritional plan screen',
    (tester) async {
      tester.view.physicalSize = const Size(500, 1000);
      tester.view.devicePixelRatio = 1.0; // Ensure correct pixel ratio

      final container = makeContainer();
      await tester.pumpWidget(createNutritionalPlan(container: container));
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      if (Platform.isLinux) {
        await expectLater(
          find.byType(NutritionalPlanScreen),
          matchesGoldenFile('goldens/nutritional_plan_1_default_view.png'),
        );
      }

      // Default view shows plan description, info button, and no ingredients
      expect(find.text('Less fat, more protein'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsNWidgets(3)); // 2 meals, 1 "other logs"
      expect(find.byIcon(Icons.info), findsNothing);
      expect(find.text('100 g Water'), findsNothing);
      expect(find.text('75 g Burger soup'), findsNothing);

      // tap the first info button changes it and reveals ingredients for the first meal
      var infoOutlineButtons = find.byIcon(Icons.info_outline);
      await tester.tap(infoOutlineButtons.first); // 2nd button shows up also, but is off-screen
      await tester.pumpAndSettle();

      if (Platform.isLinux) {
        await expectLater(
          find.byType(NutritionalPlanScreen),
          matchesGoldenFile('goldens/nutritional_plan_2_one_meal_with_ingredients.png'),
        );
      }

      // Ingredients show up now
      expect(find.text('100 g Water'), findsOneWidget);
      expect(find.text('75 g Burger soup'), findsOneWidget);

      // .. and the button icon has changed
      expect(find.byIcon(Icons.info_outline), findsNWidgets(2));
      expect(find.byIcon(Icons.info), findsOneWidget);

      // the goals widget pushes this content down a bit.
      // let's first find our icon (note: the previous icon no longer matches)
      infoOutlineButtons = find.byIcon(Icons.info_outline);

      await tester.scrollUntilVisible(infoOutlineButtons.first, 30);
      expect(find.text('300 g Broccoli cake'), findsNothing);

      await tester.tap(infoOutlineButtons.first);
      await tester.pumpAndSettle();

      if (Platform.isLinux) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/nutritional_plan_3_both_meals_with_ingredients.png'),
        );
      }

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.info), findsNWidgets(2));

      await tester.scrollUntilVisible(find.text('300 g Broccoli cake'), 30);
      expect(find.text('300 g Broccoli cake'), findsOneWidget);

      expect(find.byType(Card), findsNWidgets(3));

      // Restore the original window size.
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
    tags: ['golden'],
  );

  testWidgets('Tests the localization of times - EN', (WidgetTester tester) async {
    final container = makeContainer();
    await tester.pumpWidget(createNutritionalPlan(container: container));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('5:00 PM'), findsOneWidget);
  });

  testWidgets('Tests the localization of times - DE', (WidgetTester tester) async {
    final container = makeContainer();
    await tester.pumpWidget(createNutritionalPlan(locale: 'de', container: container));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('17:00'), findsOneWidget);
  });

  testWidgets(
    'loading indicator does not reappear after popup menu tap',
    (WidgetTester tester) async {
      final completer = Completer<Map<String, dynamic>>();

      // Override the fetchPlanFull behavior so we can control when it completes
      when(mockNutritionRepo.fetchPlanFull(any)).thenAnswer((_) => completer.future);

      final container = makeContainer();
      await tester.pumpWidget(createNutritionalPlan(container: container));
      await tester.tap(find.byType(TextButton));

      // Two pumps: first for route transition, second for FutureBuilder waiting state
      await tester.pump();
      await tester.pump();

      // Future is still pending — spinner must be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Now resolve the future — simulates network response
      completer.complete(nutritionalPlanInfoResponse);
      await tester.pumpAndSettle();

      // Spinner gone after successful load
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tap popup menu — this is the exact scenario that triggered the bug
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();

      // Core assertion: spinner must NOT reappear after menu tap
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}
