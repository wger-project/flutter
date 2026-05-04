/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/database/ingredients/ingredients_database.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/user/provider_test.mocks.dart';
import '../test_data/nutritional_plans.dart';

Widget createNutritionalPlanScreen({Locale? locale}) {
  locale ??= const Locale('en');
  final mockBaseProvider = MockWgerBaseProvider();

  final key = GlobalKey<NavigatorState>();

  return MediaQuery(
    data: MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).copyWith(
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    ),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<NutritionPlansProvider>(
          create: (context) => NutritionPlansProvider(
            mockBaseProvider,
            [],
            database: IngredientDatabase.inMemory(NativeDatabase.memory()),
          ),
        ),
        ChangeNotifierProvider<BodyWeightProvider>(
          create: (context) => BodyWeightProvider(mockBaseProvider),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: wgerLightTheme,
        navigatorKey: key,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: RouteSettings(arguments: getNutritionalPlanScreenshot()),
              builder: (_) => const NutritionalPlanScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
      ),
    ),
  );
}
