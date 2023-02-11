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
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/workouts/forms.dart';

import '../../test_data/workouts.dart';
import 'workout_day_form_test.mocks.dart';

@GenerateMocks([WorkoutPlansProvider])
void main() {
  var mockWorkoutPlans = MockWorkoutPlansProvider();
  WorkoutPlan workoutPlan = WorkoutPlan.empty();

  setUp(() {
    workoutPlan = getWorkout();
    mockWorkoutPlans = MockWorkoutPlansProvider();
  });

  Widget createHomeScreen({locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ChangeNotifierProvider<WorkoutPlansProvider>(
      create: (context) => mockWorkoutPlans,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: Scaffold(
          body: DayFormWidget(workoutPlan),
        ),
      ),
    );
  }

  testWidgets('Test the widgets on the DayFormWidget', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(7));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Test creating a new day', (WidgetTester tester) async {
    when(mockWorkoutPlans.addDay(any, any)).thenAnswer((_) => Future.value(Day()));

    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    expect(find.text(''), findsOneWidget, reason: 'New day has no description');
    await tester.enterText(find.byKey(const Key('field-description')), 'Leg day!');
    await tester.tap(find.byKey(const Key('field-checkbox-1')));
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));

    verify(mockWorkoutPlans.addDay(any, any));

    // Successful redirect to workout plan detail page
    //await tester.pumpAndSettle();
    //verify(mockObserver.didPop(any, any));
  });

  testWidgets('Tests the localization of days - EN', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Tuesday'), findsOneWidget);
    expect(find.text('Thursday'), findsOneWidget);
  });

  testWidgets('Tests the localization of days - DE', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(locale: 'de'));

    expect(find.text('Montag'), findsOneWidget);
    expect(find.text('Dienstag'), findsOneWidget);
    expect(find.text('Donnerstag'), findsOneWidget);
  });
}
