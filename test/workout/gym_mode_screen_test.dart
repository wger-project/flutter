/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/widgets/routines/forms/reps_unit.dart';
import 'package:wger/widgets/routines/forms/rir.dart';
import 'package:wger/widgets/routines/forms/weight_unit.dart';
import 'package:wger/widgets/routines/gym_mode/exercise_overview.dart';
import 'package:wger/widgets/routines/gym_mode/log_page.dart';
import 'package:wger/widgets/routines/gym_mode/session_page.dart';
import 'package:wger/widgets/routines/gym_mode/start_page.dart';
import 'package:wger/widgets/routines/gym_mode/timer.dart';

import '../../test_data/exercises.dart';
import '../../test_data/routines.dart';
import 'gym_mode_screen_test.mocks.dart';

@GenerateMocks([WgerBaseProvider, ExercisesProvider])
void main() {
  final mockBaseProvider = MockWgerBaseProvider();
  final key = GlobalKey<NavigatorState>();

  final mockExerciseProvider = MockExercisesProvider();
  final testRoutine = getTestRoutine();
  final testExercises = getTestExercises();

  Widget renderGymMode({locale = 'en'}) {
    return ChangeNotifierProvider<RoutinesProvider>(
      create: (context) => RoutinesProvider(
        mockBaseProvider,
        mockExerciseProvider,
        [testRoutine],
        repetitionUnits: testRepetitionUnits,
        weightUnits: testWeightUnits,
      ),
      child: ChangeNotifierProvider<ExercisesProvider>(
        create: (context) => mockExerciseProvider,
        child: riverpod.ProviderScope(
          child: MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorKey: key,
            home: TextButton(
              onPressed: () => key.currentState!.push(
                MaterialPageRoute<void>(
                  settings: const RouteSettings(arguments: GymModeArguments(1, 1, 1)),
                  builder: (_) => const GymModeScreen(),
                ),
              ),
              child: const SizedBox(),
            ),
            routes: {RoutineScreen.routeName: (ctx) => const RoutineScreen()},
          ),
        ),
      ),
    );
  }

  testWidgets('Test the widgets on the gym mode screen', (WidgetTester tester) async {
    when(mockExerciseProvider.findExerciseById(1)).thenReturn(testExercises[0]);
    when(mockExerciseProvider.findExerciseById(6)).thenReturn(testExercises[5]);

    await tester.pumpWidget(renderGymMode());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    //
    // Start page
    //
    expect(find.byType(StartPage), findsOneWidget);
    expect(find.text('Your workout today'), findsOneWidget);
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.text('Side raises'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.toc), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Bench press - exercise overview page
    //
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.byType(ExerciseOverview), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.toc), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.drag(find.byType(ExerciseOverview), const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    //
    // Bench press - Log
    //
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.byType(LogPage), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3), reason: 'Two logs and the switch tile');
    expect(find.text('10 × 10 kg  (1.5 RiR)'), findsOneWidget);
    expect(find.text('12 × 10 kg  (2 RiR)'), findsOneWidget);
    expect(find.text('Make sure to warm up'), findsOneWidget, reason: 'Set comment');
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.toc), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    // Form shows only weight and reps
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(RepetitionUnitInputWidget), findsNothing);
    expect(find.byType(WeightUnitInputWidget), findsNothing);
    expect(find.byType(RiRInputWidget), findsNothing);

    // Form shows unit and rir after tapping the toggle button
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(find.byType(RepetitionUnitInputWidget), findsOneWidget);
    expect(find.byType(WeightUnitInputWidget), findsOneWidget);
    expect(find.byType(RiRInputWidget), findsOneWidget);
    await tester.drag(find.byType(LogPage), const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    //
    // Bench press - pause
    //
    expect(find.text('Pause'), findsOneWidget);
    expect(find.byType(TimerCountdownWidget), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.toc), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Bench press - log
    //
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.byType(LogPage), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    await tester.drag(find.byType(LogPage), const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    //
    // Pause
    //
    expect(find.text('Pause'), findsOneWidget);
    expect(find.byType(TimerCountdownWidget), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Bench press - log
    //
    expect(find.text('Bench press'), findsOneWidget);
    expect(find.byType(LogPage), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Pause
    //
    expect(find.text('Pause'), findsOneWidget);
    expect(find.byType(TimerCountdownWidget), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Side raises - overview
    //
    expect(find.text('Side raises'), findsOneWidget);
    expect(find.byType(ExerciseOverview), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Side raises - log
    //
    expect(find.text('Side raises'), findsOneWidget);
    expect(find.byType(LogPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Side raises - timer
    //
    expect(find.byType(TimerWidget), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Side raises - log
    //
    expect(find.text('Side raises'), findsOneWidget);
    expect(find.byType(LogPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Side raises - timer
    //
    expect(find.byType(TimerWidget), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Side raises - log
    //
    expect(find.text('Side raises'), findsOneWidget);
    expect(find.byType(LogPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Side raises - timer
    //
    expect(find.byType(TimerWidget), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Session
    //
    expect(find.text('Workout session'), findsOneWidget);
    expect(find.byType(SessionPage), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byIcon(Icons.sentiment_very_dissatisfied), findsOneWidget);
    expect(find.byIcon(Icons.sentiment_neutral), findsOneWidget);
    expect(find.byIcon(Icons.sentiment_very_satisfied), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);

    //
  });
}
