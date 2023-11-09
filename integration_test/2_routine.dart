import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/routine.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/routine/workout_form_test.mocks.dart';
import '../test_data/routines.dart';

Widget createRoutineDetailScreen({locale = 'en'}) {
  final key = GlobalKey<NavigatorState>();

  final mockRoutineProvider = MockRoutineProvider();
  final routine = getRoutine();
  when(mockRoutineProvider.activeRoutine).thenReturn(routine);
  when(mockRoutineProvider.fetchAndSetRoutineFull(1)).thenAnswer((_) => Future.value(routine));

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<RoutineProvider>(
        create: (context) => mockRoutineProvider,
      ),
    ],
    child: MaterialApp(
      locale: Locale(locale),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: wgerTheme,
      navigatorKey: key,
      home: TextButton(
        onPressed: () => key.currentState!.push(
          MaterialPageRoute<void>(
            settings: RouteSettings(arguments: getRoutine()),
            builder: (_) => RoutineScreen(),
          ),
        ),
        child: const SizedBox(),
      ),
    ),
  );
}
