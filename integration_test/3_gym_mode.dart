import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/exercise_state.dart';
import 'package:wger/providers/exercise_state_notifier.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test_data/exercises.dart';
import '../test_data/routines.dart';

Widget createGymModeScreen({locale = 'en'}) {
  final key = GlobalKey<NavigatorState>();

  final container = riverpod.ProviderContainer.test(
    overrides: [
      exerciseStateProvider.overrideWithValue(ExerciseState(exercises: getTestExercises())),
    ],
  );
  container.read(routinesRiverpodProvider.notifier).state = RoutinesState(
    routines: [getTestRoutine(exercises: getScreenshotExercises())],
  );

  return riverpod.UncontrolledProviderScope(
    container: container,
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
            settings: RouteSettings(
              arguments: GymModeArguments(routine.id!, routine.days.first.id!, 1),
            ),
            builder: (_) => const GymModeScreen(),
          ),
        ),
        child: const SizedBox(),
      ),
      routes: {
        RoutineScreen.routeName: (ctx) => const RoutineScreen(),
      },
    ),
  );
}
