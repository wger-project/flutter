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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/widgets/workouts/forms.dart';

import 'workout_form_test.mocks.dart';

@GenerateMocks([WorkoutPlans])
void main() {
  var mockWorkoutPlans = MockWorkoutPlans();
  final plan1 = WorkoutPlan(id: 1, creationDate: DateTime(2021, 1, 1), description: 'test 1');
  final plan2 = WorkoutPlan(creationDate: DateTime(2021, 1, 2), description: '');

  setUp(() {
    mockWorkoutPlans = MockWorkoutPlans();
  });

  Widget createHomeScreen(WorkoutPlan workoutPlan, {locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ChangeNotifierProvider<WorkoutPlans>(
      create: (context) => mockWorkoutPlans,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: Scaffold(
          body: WorkoutForm(workoutPlan),
        ),
        routes: {
          WorkoutPlanScreen.routeName: (ctx) => WorkoutPlanScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the workout form', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(plan1));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Test editing an existing workout', (WidgetTester tester) async {
    when(mockWorkoutPlans.editWorkout(any)).thenAnswer((_) => Future.value(plan1));
    when(mockWorkoutPlans.addWorkout(any)).thenAnswer((_) => Future.value(plan2));

    await tester.pumpWidget(createHomeScreen(plan1));
    await tester.pumpAndSettle();

    expect(find.text(('test 1')), findsOneWidget, reason: 'Description of existing workout plan');
    await tester.enterText(find.byKey(Key('field-description')), 'New description');
    await tester.tap(find.byKey(Key(SUBMIT_BUTTON_KEY_NAME)));

    // Correct ed
    verify(mockWorkoutPlans.editWorkout(any));
    verifyNever(mockWorkoutPlans.addWorkout(any));

    // Detail page
    await tester.pumpAndSettle();
    expect(find.text(('New description')), findsOneWidget, reason: 'Workout plan detail page');
  });

  testWidgets('Test creating a new workout', (WidgetTester tester) async {
    when(mockWorkoutPlans.editWorkout(any)).thenAnswer((_) => Future.value(plan1));
    when(mockWorkoutPlans.addWorkout(any)).thenAnswer((_) => Future.value(plan2));

    await tester.pumpWidget(createHomeScreen(plan2));
    await tester.pumpAndSettle();

    expect(find.text(('')), findsOneWidget, reason: 'New workout has no description');
    await tester.enterText(find.byKey(Key('field-description')), 'New cool workout');
    await tester.tap(find.byKey(Key(SUBMIT_BUTTON_KEY_NAME)));

    verifyNever(mockWorkoutPlans.editWorkout(any));
    verify(mockWorkoutPlans.addWorkout(any));

    // Detail page
    await tester.pumpAndSettle();
    expect(find.text(('New cool workout')), findsOneWidget, reason: 'Workout plan detail page');
  });

  testWidgets('Golden test', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(plan2));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('workout_form.png'));
  });
}
