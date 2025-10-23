import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/body_weight_repository.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/dashboard.dart';
import 'package:wger/theme/theme.dart';

import '../test/exercises/contribute_exercise_test.mocks.dart';
import '../test/measurements/measurement_categories_screen_test.mocks.dart';
import '../test/routine/weight_unit_form_widget_test.mocks.dart';
import '../test/weight/weight_provider_test.mocks.dart';
import '../test/weight/weight_screen_test.mocks.dart' as weight;
import '../test_data/body_weight.dart';
import '../test_data/exercises.dart';
import '../test_data/measurements.dart';
import '../test_data/nutritional_plans.dart';
import '../test_data/profile.dart';
import '../test_data/routines.dart';

Widget createDashboardScreen({String locale = 'en'}) {
  final mockWorkoutProvider = MockRoutinesProvider();
  when(mockWorkoutProvider.items).thenReturn([getTestRoutine(exercises: getScreenshotExercises())]);
  when(
    mockWorkoutProvider.currentRoutine,
  ).thenReturn(getTestRoutine(exercises: getScreenshotExercises()));

  when(mockWorkoutProvider.fetchSessionData()).thenAnswer(
    (a) => Future.value([
      WorkoutSession(
        routineId: 1,
        date: DateTime.now().add(const Duration(days: -1)),
        timeStart: const TimeOfDay(hour: 17, minute: 34),
        timeEnd: const TimeOfDay(hour: 19, minute: 3),
        impression: 3,
      ),
    ]),
  );

  final mockNutritionProvider = weight.MockNutritionPlansProvider();

  when(
    mockNutritionProvider.currentPlan,
  ).thenAnswer((realInvocation) => getNutritionalPlanScreenshot());
  when(mockNutritionProvider.items).thenReturn([getNutritionalPlanScreenshot()]);

  final mockBodyWeightRepository = MockBodyWeightRepository();
  when(
    mockBodyWeightRepository.watchAllDrift(),
  ).thenAnswer((_) => Stream.value(getWeightEntries()));

  final mockMeasurementProvider = MockMeasurementProvider();
  when(mockMeasurementProvider.categories).thenReturn(getMeasurementCategories());

  final mockUserProvider = MockUserProvider();
  when(mockUserProvider.profile).thenReturn(tProfile1);

  return riverpod.ProviderScope(
    overrides: [
      bodyWeightRepositoryProvider.overrideWithValue(mockBodyWeightRepository),
    ],
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (context) => mockUserProvider,
        ),
        ChangeNotifierProvider<RoutinesProvider>(
          create: (context) => mockWorkoutProvider,
        ),
        ChangeNotifierProvider<NutritionPlansProvider>(
          create: (context) => mockNutritionProvider,
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
    ),
  );
}
