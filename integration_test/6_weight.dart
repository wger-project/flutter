import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/utils.dart';
import '../test/weight/weight_screen_test.mocks.dart';
import '../test_data/body_weight.dart';
import '../test_data/nutritional_plans.dart';
import '../test_data/profile.dart';

Widget createWeightScreen({Locale? locale}) {
  locale ??= const Locale('en');
  final weightProvider = BodyWeightProvider(mockBaseProvider);
  weightProvider.items = getScreenshotWeightEntries();

  final mockUserProvider = MockUserProvider();
  when(mockUserProvider.profile).thenReturn(tProfile1);

  final mockNutritionPlansProvider = MockNutritionPlansProvider();
  when(mockNutritionPlansProvider.currentPlan).thenReturn(null);
  when(mockNutritionPlansProvider.items).thenReturn([getNutritionalPlan()]);

  return MediaQuery(
    data: MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).copyWith(
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    ),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (context) => mockUserProvider,
        ),
        ChangeNotifierProvider<BodyWeightProvider>(
          create: (context) => weightProvider,
        ),
        ChangeNotifierProvider<NutritionPlansProvider>(
          create: (context) => mockNutritionPlansProvider,
        ),
      ],
      child: MaterialApp(
        locale: locale,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: wgerLightTheme,
        home: const WeightScreen(),
        routes: {FormScreen.routeName: (ctx) => const FormScreen()},
      ),
    ),
  );
}
