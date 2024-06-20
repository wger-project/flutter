import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/user/provider_test.mocks.dart';
import '../test_data/nutritional_plans.dart';

Widget createNutritionalPlanScreen({locale = 'en'}) {
  final mockBaseProvider = MockWgerBaseProvider();

  final key = GlobalKey<NavigatorState>();

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
  );
}
