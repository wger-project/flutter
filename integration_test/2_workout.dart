import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test_data/exercises.dart';
import '../test_data/routines.dart';

Widget createWorkoutDetailScreen({Locale? locale}) {
  locale ??= const Locale('en');
  final key = GlobalKey<NavigatorState>();

  final routine = getTestRoutine(exercises: getScreenshotExercises());
  final container = riverpod.ProviderContainer.test();
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
        theme: wgerLightTheme,
        navigatorKey: key,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: RouteSettings(arguments: routine.id),
              builder: (_) => const RoutineScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
      ),
    ),
  );
}
