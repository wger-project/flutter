/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/exercise_state.dart';
import 'package:wger/providers/exercise_state_notifier.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/routines/gym_mode/summary.dart';

import '../test_data/exercises.dart';
import '../test_data/routines.dart';

class _StubRoutinesRiverpod extends RoutinesRiverpod {
  _StubRoutinesRiverpod(this._routines);
  final List<Routine> _routines;

  @override
  Future<RoutinesState> build() async => RoutinesState(routines: _routines);
}

Widget createGymModeScreen({Locale? locale}) {
  locale ??= const Locale('en');
  final key = GlobalKey<NavigatorState>();

  final routine = getTestRoutine(exercises: getScreenshotExercises());
  final container = riverpod.ProviderContainer.test(
    overrides: [
      exerciseStateProvider.overrideWithValue(ExerciseState(exercises: getTestExercises())),
    ],
  );
  container.read(routinesRiverpodProvider.notifier).state = riverpod.AsyncData(
    RoutinesState(
      routines: [getTestRoutine(exercises: getScreenshotExercises())],
    ),
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
  routine.sessions.first.date = clock.now();

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
        routinesRiverpodProvider.overrideWith(
          () => _StubRoutinesRiverpod([routine]),
        ),
      ],
    ),

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
  );
}
