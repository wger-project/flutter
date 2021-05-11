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

@GenerateMocks([WorkoutPlansProvider])
void main() {
  var mockWorkoutPlans = MockWorkoutPlansProvider();
  final plan1 = WorkoutPlan(
    id: 1,
    creationDate: DateTime(2021, 1, 1),
    name: 'test 1',
    description: 'description 1',
  );
  final plan2 = WorkoutPlan(creationDate: DateTime(2021, 1, 2), name: '');

  setUp(() {
    mockWorkoutPlans = MockWorkoutPlansProvider();
  });

  Widget createHomeScreen(WorkoutPlan workoutPlan, {locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ChangeNotifierProvider<WorkoutPlansProvider>(
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

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Test editing an existing workout', (WidgetTester tester) async {
    when(mockWorkoutPlans.editWorkout(any)).thenAnswer((_) => Future.value(plan1));
    when(mockWorkoutPlans.addWorkout(any)).thenAnswer((_) => Future.value(plan2));

    await tester.pumpWidget(createHomeScreen(plan1));
    await tester.pumpAndSettle();

    expect(
      find.text(('test 1')),
      findsOneWidget,
      reason: 'Name of existing workout plan',
    );
    expect(
      find.text(('description 1')),
      findsOneWidget,
      reason: 'Description of existing workout plan',
    );
    await tester.enterText(find.byKey(Key('field-name')), 'New description');
    await tester.tap(find.byKey(Key(SUBMIT_BUTTON_KEY_NAME)));

    // Correct method was called
    verify(mockWorkoutPlans.editWorkout(any));
    verifyNever(mockWorkoutPlans.addWorkout(any));

    // TODO: edit calls Navigator.pop(), since the form can only be reached from the
    //       detail page. The test needs to add the detail page to the stack so that
    //       this can be checked.
    // https://stackoverflow.com/questions/50704647/how-to-test-navigation-via-navigator-in-flutter
    // Detail page
    //await tester.pumpAndSettle();
    //expect(find.text(('New description')), findsOneWidget, reason: 'Workout plan detail page');
  });

  testWidgets('Test creating a new workout - only name', (WidgetTester tester) async {
    when(mockWorkoutPlans.editWorkout(any)).thenAnswer((_) => Future.value(plan1));
    when(mockWorkoutPlans.addWorkout(any)).thenAnswer((_) => Future.value(plan2));

    await tester.pumpWidget(createHomeScreen(plan2));
    await tester.pumpAndSettle();

    expect(find.text(('')), findsNWidgets(2), reason: 'New workout has no name or description');
    await tester.enterText(find.byKey(Key('field-name')), 'New cool workout');
    await tester.tap(find.byKey(Key(SUBMIT_BUTTON_KEY_NAME)));

    verifyNever(mockWorkoutPlans.editWorkout(any));
    verify(mockWorkoutPlans.addWorkout(any));

    // Detail page
    await tester.pumpAndSettle();
    expect(find.text(('New cool workout')), findsOneWidget, reason: 'Workout plan detail page');
  });

  testWidgets('Test creating a new workout - description', (WidgetTester tester) async {
    when(mockWorkoutPlans.editWorkout(any)).thenAnswer((_) => Future.value(plan1));
    when(mockWorkoutPlans.addWorkout(any)).thenAnswer((_) => Future.value(plan2));

    await tester.pumpWidget(createHomeScreen(plan2));
    await tester.pumpAndSettle();

    expect(find.text(('')), findsNWidgets(2), reason: 'New workout has no name or description');
    await tester.enterText(find.byKey(Key('field-name')), 'My workout');
    await tester.enterText(find.byKey(Key('field-description')), 'Get yuuuge');
    await tester.tap(find.byKey(Key(SUBMIT_BUTTON_KEY_NAME)));

    verifyNever(mockWorkoutPlans.editWorkout(any));
    verify(mockWorkoutPlans.addWorkout(any));

    // Detail page
    await tester.pumpAndSettle();
    expect(find.text(('My workout')), findsOneWidget, reason: 'Workout plan detail page');
  });
}
