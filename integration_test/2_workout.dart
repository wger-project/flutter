import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/routine/routine_form_test.mocks.dart';
import '../test_data/exercises.dart';
import '../test_data/routines.dart';

Widget createWorkoutDetailScreen({locale = 'en'}) {
  final key = GlobalKey<NavigatorState>();

  final container = riverpod.ProviderContainer.test();
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
  );
}
