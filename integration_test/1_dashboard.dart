import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/dashboard.dart';
import 'package:wger/theme/theme.dart';

import '../test/exercises/contribute_exercise_test.mocks.dart';
import '../test/measurements/measurement_categories_screen_test.mocks.dart';
import '../test/nutrition/nutritional_plan_form_test.mocks.dart';
import '../test/workout/weight_unit_form_widget_test.mocks.dart';
import '../test/workout/workout_form_test.mocks.dart';
import '../test_data/body_weight.dart';
import '../test_data/exercises.dart';
import '../test_data/measurements.dart';
import '../test_data/nutritional_plans.dart';
import '../test_data/profile.dart';
import '../test_data/workouts.dart';

Widget createDashboardScreen({locale = 'en'}) {
  final mockWorkoutProvider = MockWorkoutPlansProvider();
  when(mockWorkoutProvider.activePlan).thenReturn(getWorkout(exercises: getScreenshotExercises()));

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
  when(mockWorkoutProvider.fetchSessionData()).thenAnswer((a) => Future.value(logs));

  final mockNutritionProvider = MockNutritionPlansProvider();

  when(mockNutritionProvider.currentPlan)
      .thenAnswer((realInvocation) => getNutritionalPlanScreenshot());
  when(mockNutritionProvider.items).thenReturn([getNutritionalPlanScreenshot()]);

  final mockWeightProvider = MockBodyWeightProvider();
  when(mockWeightProvider.items).thenReturn(getScreenshotWeightEntries());

  final mockMeasurementProvider = MockMeasurementProvider();
  when(mockMeasurementProvider.categories).thenReturn(getMeasurementCategories());

  final mockUserProvider = MockUserProvider();
  when(mockUserProvider.profile).thenReturn(tProfile1);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(
        create: (context) => mockUserProvider,
      ),
      ChangeNotifierProvider<WorkoutPlansProvider>(
        create: (context) => mockWorkoutProvider,
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
      theme: wgerLightTheme,
      home: const DashboardScreen(),
    ),
  );
}
