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

Widget createWorkoutDetailScreen({Locale? locale}) {
  locale ??= const Locale('en');
  final key = GlobalKey<NavigatorState>();

  final mockRoutinesProvider = MockRoutinesProvider();
  final routine = getTestRoutine(exercises: getScreenshotExercises());
  when(mockRoutinesProvider.findById(1)).thenReturn(routine);

  return MediaQuery(
    data: MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).copyWith(
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    ),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<RoutinesProvider>(
          create: (context) => mockRoutinesProvider,
        ),
      ],
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
