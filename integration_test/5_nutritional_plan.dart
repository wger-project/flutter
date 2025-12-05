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
