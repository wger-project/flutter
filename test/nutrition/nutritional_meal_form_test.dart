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

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/ingredient_repository.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/providers/nutrition_repository.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/nutrition/forms.dart';

import '../../test_data/nutritional_plans.dart';
import 'nutritional_plan_form_test.mocks.dart';

void main() {
  late MockNutritionRepository mockRepo;
  late MockIngredientRepository mockIngredientRepo;
  late ProviderContainer container;

  var plan1 = NutritionalPlan.empty();
  var meal1 = Meal();

  setUp(() async {
    plan1 = getNutritionalPlan();
    meal1 = plan1.meals.first;
    mockRepo = MockNutritionRepository();
    mockIngredientRepo = MockIngredientRepository();

    when(mockRepo.updateMeal(any, any)).thenAnswer((_) async => Meal(id: 1, plan: 1).toJson());
    when(mockRepo.createMeal(any)).thenAnswer((_) async => Meal(id: 99, plan: 1).toJson());
    // NutritionNotifier.build() auto-fetches plans on first read; the
    // explicit state seed below replaces this empty value.
    when(mockRepo.fetchAllPlans()).thenAnswer((_) async => []);

    container = ProviderContainer(
      overrides: [
        nutritionRepositoryProvider.overrideWithValue(mockRepo),
        ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
      ],
    );
    // Initialize the notifier so build() runs, then seed plans.
    await container.read(nutritionProvider.future);
    container.read(nutritionProvider.notifier).state = AsyncData([plan1]);
  });

  tearDown(() {
    container.dispose();
  });

  Widget createFormScreen(Meal meal, {locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: Scaffold(body: MealForm(1, meal)),
        routes: {
          NutritionalPlanScreen.routeName: (ctx) => const NutritionalPlanScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the meal form', (WidgetTester tester) async {
    await tester.pumpWidget(createFormScreen(meal1));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)), findsOneWidget);
  });

  testWidgets('Test editing an existing meal', (WidgetTester tester) async {
    await tester.pumpWidget(createFormScreen(meal1));
    await tester.pumpAndSettle();

    expect(
      find.text('17:00'),
      findsOneWidget,
      reason: 'Time of existing meal is filled in',
    );

    expect(
      find.text('Initial Name 1'),
      findsOneWidget,
      reason: 'Time of existing meal is filled in',
    );

    await tester.enterText(find.byKey(const Key('field-time')), '12:34');
    await tester.enterText(find.byKey(const Key('field-name')), 'test meal');
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));

    // Correct method was called
    verify(mockRepo.updateMeal(any, any));
    verifyNever(mockRepo.createMeal(any));
  });

  testWidgets('Test creating a new nutritional plan', (WidgetTester tester) async {
    // DateTime.now() is difficult to mock as it pull directly from the platform
    // currently being run. The clock pacakge (https://pub.dev/packages/clock)
    // addresses this issue, using clock.now() allows us to set a fixed value as the
    // response when using withClock.
    final fixedDateTimeValue = DateTime(2020, 09, 01, 01, 01);
    withClock(Clock.fixed(fixedDateTimeValue), () async {
      // The time set in the meal object is what is displayed by default
      // and can be matched with the find.text function. By creating the meal
      // wrapped in the withClock it also shares the same now value.

      // Note: it seems there is something wrong with withClock that seems to
      //       get ignored, so passing the time to the constructor for now
      final fixedTimeMeal = Meal(time: const TimeOfDay(hour: 1, minute: 1));

      await tester.pumpWidget(createFormScreen(fixedTimeMeal));
      await tester.pumpAndSettle();

      expect(
        clock.now(),
        fixedDateTimeValue,
        reason: 'Current time is set to a fixed value for testing',
      );

      expect(
        find.text(timeToString(TimeOfDay.fromDateTime(clock.now()))!),
        findsOneWidget,
        reason: 'Current time is filled in',
      );

      await tester.enterText(find.byKey(const Key('field-time')), '08:00');
      await tester.enterText(find.byKey(const Key('field-name')), 'test meal');
      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));

      // Correct method was called
      verifyNever(mockRepo.updateMeal(any, any));
      verify(mockRepo.createMeal(any));
    });

    // Detail page
    // ...
  });

  testWidgets('Submit is disabled when offline and updateMeal is not called', (
    WidgetTester tester,
  ) async {
    // Build a fresh container that overrides the network status to offline.
    final offlineContainer = ProviderContainer(
      overrides: [
        nutritionRepositoryProvider.overrideWithValue(mockRepo),
        ingredientRepositoryProvider.overrideWithValue(mockIngredientRepo),
        networkStatusProvider.overrideWithValue(false),
      ],
    );
    addTearDown(offlineContainer.dispose);
    await offlineContainer.read(nutritionProvider.future);
    offlineContainer.read(nutritionProvider.notifier).state = AsyncData([plan1]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: offlineContainer,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MealForm(1, meal1)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)), warnIfMissed: false);
    await tester.pump();
    verifyNever(mockRepo.updateMeal(any, any));
    verifyNever(mockRepo.createMeal(any));
  });
}
