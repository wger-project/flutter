import 'package:flutter/material.dart';
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

  final mockRoutinesProvider = MockRoutinesProvider();
  final routine = getTestRoutine(exercises: getScreenshotExercises());
  // when(mockRoutinesProvider.activeRoutine).thenReturn(routine);
  when(mockRoutinesProvider.findById(1)).thenReturn(routine);
  // when(mockRoutinesProvider.fetchAndSetRoutineFull(1)).thenAnswer((_) => Future.value(routine));

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<RoutinesProvider>(
        create: (context) => mockRoutinesProvider,
      ),
    ],
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
