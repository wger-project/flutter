import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/utils.dart';
import '../test/workout/gym_mode_screen_test.mocks.dart';
import '../test_data/exercises.dart';
import '../test_data/workouts.dart';

Widget createGymModeScreen({locale = 'en'}) {
  final key = GlobalKey<NavigatorState>();
  final bases = getTestExercises();
  final workout = getWorkout(exercises: getScreenshotExercises());

  final mockExerciseProvider = MockExercisesProvider();

  when(mockExerciseProvider.findExerciseById(1)).thenReturn(bases[0]); // bench press
  when(mockExerciseProvider.findExerciseById(6)).thenReturn(bases[5]); // side raises
  //when(mockExerciseProvider.findExerciseBaseById(2)).thenReturn(bases[1]); // crunches
  //when(mockExerciseProvider.findExerciseBaseById(3)).thenReturn(bases[2]); // dead lift

  return ChangeNotifierProvider<WorkoutPlansProvider>(
    create: (context) => WorkoutPlansProvider(
      mockBaseProvider,
      mockExerciseProvider,
      [workout],
    ),
    child: ChangeNotifierProvider<ExercisesProvider>(
      create: (context) => mockExerciseProvider,
      child: MaterialApp(
        locale: Locale(locale),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        theme: wgerLightTheme,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: RouteSettings(arguments: workout.days.first),
              builder: (_) => const GymModeScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
        routes: {
          WorkoutPlanScreen.routeName: (ctx) => const WorkoutPlanScreen(),
        },
      ),
    ),
  );
}
