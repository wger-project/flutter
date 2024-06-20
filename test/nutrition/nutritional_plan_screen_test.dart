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
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import '../../test_data/nutritional_plans.dart';
import 'nutritional_plan_screen_test.mocks.dart';

@GenerateMocks([WgerBaseProvider, AuthProvider, http.Client])
void main() {
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
              builder: (_) => const NutritionalPlanScreen(),
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

    expect(find.textContaining('5:00 PM'), findsOneWidget);
  });

  testWidgets('Tests the localization of times - DE', (WidgetTester tester) async {
    await tester.pumpWidget(createNutritionalPlan(locale: 'de'));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('17:00'), findsOneWidget);
  });
}
