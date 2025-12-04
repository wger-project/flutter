import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/exercise_state.dart';
import 'package:wger/providers/exercise_state_notifier.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/routines/gym_mode/summary.dart';

import '../test/routine/gym_mode/gym_mode_test.mocks.dart';
import '../test_data/exercises.dart';
import '../test_data/routines.dart';

Widget createGymModeScreen({Locale? locale}) {
  locale ??= const Locale('en');
  final key = GlobalKey<NavigatorState>();

  final routine = getTestRoutine(exercises: getScreenshotExercises());
  final container = riverpod.ProviderContainer.test(
    overrides: [
      exerciseStateProvider.overrideWithValue(ExerciseState(exercises: getTestExercises())),
    ],
  );
  container.read(routinesRiverpodProvider.notifier).state = RoutinesState(
    routines: [getTestRoutine(exercises: getScreenshotExercises())],
  );

  return MediaQuery(
    data: MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).copyWith(
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    ),
    child: riverpod.UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
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
    ),
  );
}

Widget createGymModeResultsScreen({String locale = 'en'}) {
  final controller = PageController(initialPage: 0);

  final key = GlobalKey<NavigatorState>();
  final routine = getTestRoutine(exercises: getScreenshotExercises());
  routine.sessions.first.session.date = clock.now();

  final mockRoutinesProvider = MockRoutinesProvider();
  final mockExerciseProvider = MockExercisesProvider();

  when(mockRoutinesProvider.fetchAndSetRoutineFull(1)).thenAnswer((_) async => routine);
  when(mockRoutinesProvider.findById(1)).thenAnswer((_) => routine);

  return riverpod.UncontrolledProviderScope(
    container: riverpod.ProviderContainer.test(
      overrides: [
        gymStateProvider.overrideWithValue(
          GymModeState(
            routine: routine,
            dayId: routine.days.first.id!,
            iteration: 1,
            showExercisePages: true,
            showTimerPages: true,
          ),
        ),
      ],
    ),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<RoutinesProvider>(
          create: (context) => mockRoutinesProvider,
        ),
        ChangeNotifierProvider<ExercisesProvider>(
          create: (context) => mockExerciseProvider,
        ),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        theme: wgerLightTheme,
        home: Scaffold(
          body: PageView(
            controller: controller,
            children: [
              WorkoutSummary(controller),
            ],
          ),
        ),
      ),
    ),
  );
}
