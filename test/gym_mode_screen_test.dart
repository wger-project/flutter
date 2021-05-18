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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/widgets/workouts/forms.dart';
import 'package:wger/widgets/workouts/gym_mode.dart';

import '../test_data/workouts.dart';
import 'base_provider_test.mocks.dart';
import 'utils.dart';

void main() {
  Widget createHomeScreen({locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();
    final client = MockClient();

    WorkoutPlan workoutPlan = getWorkout();

    return ChangeNotifierProvider<WorkoutPlansProvider>(
      create: (context) => WorkoutPlansProvider(
        testAuthProvider,
        testExercisesProvider,
        [workoutPlan],
        client,
      ),
      child: ChangeNotifierProvider(
        create: (context) => testExercisesProvider,
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: key,
          home: TextButton(
            onPressed: () => key.currentState!.push(
              MaterialPageRoute<void>(
                settings: RouteSettings(arguments: workoutPlan.days.first),
                builder: (_) => GymModeScreen(),
              ),
            ),
            child: const SizedBox(),
          ),
          routes: {
            WorkoutPlanScreen.routeName: (ctx) => WorkoutPlanScreen(),
          },
        ),
      ),
    );
  }

  testWidgets('Test the widgets on the gym mode screen', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    //
    // Start page
    //
    expect(find.byType(StartPage), findsOneWidget);
    expect(find.text('Your workout today'), findsOneWidget);
    expect(find.text('test exercise 1'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Exercise overview page
    //
    expect(find.text('test exercise 1'), findsOneWidget);
    expect(find.byType(ExerciseOverview), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.drag(find.byType(ExerciseOverview), Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    //
    // Log
    //
    expect(find.text('test exercise 1'), findsOneWidget);
    expect(find.byType(LogPage), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('10 × 10 kg  (1.5 RiR)'), findsOneWidget);
    expect(find.text('12 × 10 kg  (2 RiR)'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    // Form shows only weight and reps
    expect(find.byIcon(Icons.unfold_more), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(RepetitionUnitInputWidget), findsNothing);
    expect(find.byType(WeightUnitInputWidget), findsNothing);
    expect(find.byType(RiRInputWidget), findsNothing);

    // Form shows unit and rir after tapping the toggle button
    await tester.tap(find.byIcon(Icons.unfold_more));
    await tester.pump();
    expect(find.byType(RepetitionUnitInputWidget), findsOneWidget);
    expect(find.byType(WeightUnitInputWidget), findsOneWidget);
    expect(find.byType(RiRInputWidget), findsOneWidget);
    expect(find.byIcon(Icons.unfold_less), findsOneWidget);

    await tester.drag(find.byType(LogPage), Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    //
    // Pause
    //
    expect(find.text('0:00'), findsOneWidget);
    expect(find.byType(TimerWidget), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Log
    //
    expect(find.text('test exercise 1'), findsOneWidget);
    expect(find.byType(LogPage), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    await tester.drag(find.byType(LogPage), Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    //
    // Pause
    //
    expect(find.text('0:00'), findsOneWidget);
    expect(find.byType(TimerWidget), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    //
    // Session
    //
    expect(find.text('Workout session'), findsOneWidget);
    expect(find.byType(SessionPage), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);

    //
  });
}
