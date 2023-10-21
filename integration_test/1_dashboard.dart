import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/routine.dart';
import 'package:wger/screens/dashboard.dart';
import 'package:wger/theme/theme.dart';

import '../test/measurements/measurement_categories_screen_test.mocks.dart';
import '../test/nutrition/nutritional_plan_form_test.mocks.dart';
import '../test/routine/weight_unit_form_widget_test.mocks.dart';
import '../test/routine/workout_form_test.mocks.dart';
import '../test_data/body_weight.dart';
import '../test_data/measurements.dart';
import '../test_data/nutritional_plans.dart';
import '../test_data/routines.dart';

Widget createDashboardScreen({locale = 'en'}) {
  final mockRoutineProvider = MockRoutineProvider();
  when(mockRoutineProvider.activeRoutine).thenReturn(getRoutine());

  final Map<String, dynamic> logs = {
    'results': [
      {
        'id': 1,
        'workout': 1,
        'date': '2022-12-01',
        'impression': '3',
        'time_start': '17:00',
        'time_end': '19:00'
      }
    ]
  };
  when(mockRoutineProvider.fetchSessionData()).thenAnswer((a) => Future.value(logs));

  final mockNutritionProvider = MockNutritionPlansProvider();
  when(mockNutritionProvider.currentPlan).thenAnswer((realInvocation) => getNutritionalPlan());
  when(mockNutritionProvider.items).thenReturn([getNutritionalPlan()]);

  final mockWeightProvider = MockBodyWeightProvider();
  when(mockWeightProvider.items).thenReturn(getWeightEntries());

  final mockMeasurementProvider = MockMeasurementProvider();
  when(mockMeasurementProvider.categories).thenReturn(getMeasurementCategories());

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<RoutineProvider>(
        create: (context) => mockRoutineProvider,
      ),
      ChangeNotifierProvider<NutritionPlansProvider>(
        create: (context) => mockNutritionProvider,
      ),
      ChangeNotifierProvider<BodyWeightProvider>(
        create: (context) => mockWeightProvider,
      ),
      ChangeNotifierProvider<MeasurementProvider>(
        create: (context) => mockMeasurementProvider,
      ),
    ],
    child: MaterialApp(
      locale: Locale(locale),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: wgerTheme,
      home: DashboardScreen(),
    ),
  );
}
