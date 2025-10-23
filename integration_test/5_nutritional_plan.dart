import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/database/ingredients/ingredients_database.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight_repository.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/user/provider_test.mocks.dart';
import '../test/weight/weight_provider_test.mocks.dart';
import '../test_data/body_weight.dart';
import '../test_data/nutritional_plans.dart';

Widget createNutritionalPlanScreen({locale = 'en'}) {
  final mockBaseProvider = MockWgerBaseProvider();

  final key = GlobalKey<NavigatorState>();

  // Create a NutritionPlansProvider (still ChangeNotifier)
  final nutritionProvider = NutritionPlansProvider(
    mockBaseProvider,
    [],
    database: IngredientDatabase.inMemory(NativeDatabase.memory()),
  );

  final mockBodyWeightRepository = MockBodyWeightRepository();
  when(
    mockBodyWeightRepository.watchAllDrift(),
  ).thenAnswer((_) => Stream.value(getWeightEntries()));

  return riverpod.ProviderScope(
    overrides: [
      bodyWeightRepositoryProvider.overrideWithValue(mockBodyWeightRepository),
    ],
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<NutritionPlansProvider>(
          create: (context) => nutritionProvider,
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
    ),
  );
}
