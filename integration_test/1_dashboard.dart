import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/home_tabs_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/exercises/contribute_exercise_test.mocks.dart';
import '../test/gallery/gallery_form_test.mocks.dart';
import '../test/measurements/measurement_categories_screen_test.mocks.dart';
import '../test/nutrition/nutritional_plan_screen_test.mocks.dart';
import '../test/routine/weight_unit_form_widget_test.mocks.dart';
import '../test/weight/weight_screen_test.mocks.dart' as weight;
import '../test_data/body_weight.dart';
import '../test_data/exercises.dart';
import '../test_data/measurements.dart';
import '../test_data/nutritional_plans.dart';
import '../test_data/profile.dart';
import '../test_data/routines.dart';

Widget createDashboardScreen({Locale? locale}) {
  locale ??= const Locale('en');

  final mockGalleryProvider = MockGalleryProvider();

  final mockExercisesProvider = MockExercisesProvider();

  final mockAuthProvider = MockAuthProvider();
  when(mockAuthProvider.setServerVersion()).thenAnswer((_) async {});
  when(mockAuthProvider.dataInit).thenReturn(true);

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

  final mockWeightProvider = weight.MockBodyWeightProvider();
  when(mockWeightProvider.items).thenReturn(getScreenshotWeightEntries());

  final mockMeasurementProvider = MockMeasurementProvider();
  when(mockMeasurementProvider.categories).thenReturn(getMeasurementCategories());

  final mockUserProvider = MockUserProvider();
  when(mockUserProvider.profile).thenReturn(tProfile1);

  return MediaQuery(
    data: MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).copyWith(
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    ),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<GalleryProvider>(
          create: (context) => mockGalleryProvider,
        ),
        ChangeNotifierProvider<ExercisesProvider>(
          create: (context) => mockExercisesProvider,
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => mockAuthProvider,
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => mockUserProvider,
        ),
        ChangeNotifierProvider<RoutinesProvider>(
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
        locale: locale,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: wgerLightTheme,
        home: HomeTabsScreen(),
      ),
    ),
  );
}
