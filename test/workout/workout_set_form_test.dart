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
import 'package:wger/models/workouts/slot.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/forms/slot.dart';

import '../../test_data/exercises.dart';
import '../../test_data/routines.dart';
import 'workout_set_form_test.mocks.dart';

@GenerateMocks([ExercisesProvider, WgerBaseProvider, RoutinesProvider])
void main() {
  var mockWorkoutPlans = MockRoutinesProvider();
  final mockBaseProvider = MockWgerBaseProvider();
  final mockExerciseProvider = MockExercisesProvider();
  final workoutPlan = getWorkout();

  Day day = Day();

  setUp(() {
    day = workoutPlan.days.first;
    mockWorkoutPlans = MockRoutinesProvider();
  });

  Widget createHomeScreen({locale = 'en'}) {
    return ChangeNotifierProvider<RoutinesProvider>(
      create: (context) => RoutinesProvider(
        mockBaseProvider,
        mockExerciseProvider,
        [workoutPlan],
      ),
      child: ChangeNotifierProvider<ExercisesProvider>(
        create: (context) => mockExerciseProvider,
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: GlobalKey<NavigatorState>(),
          home: Scaffold(body: SlotFormWidget(day)),
        ),
      ),
    );
  }

  testWidgets('Test the widgets on the SetFormWidget', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    //TODO: why doesn't it find the typeahead?
    //expect(find.byType(TypeAheadFormField), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Test creating a new set', (WidgetTester tester) async {
    when(mockWorkoutPlans.addSet(any)).thenAnswer((_) => Future.value(Slot.empty()));
    when(mockWorkoutPlans.addSetting(any)).thenAnswer((_) => Future.value(SlotEntry.empty()));
    when(mockExerciseProvider.searchExercise(
      any,
      languageCode: anyNamed('languageCode'),
      searchEnglish: anyNamed('searchEnglish'),
    )).thenAnswer((_) => Future.value([getTestExercises().first]));

    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('field-typeahead')), 'exercise');
    await tester.pumpAndSettle();

    //await tester.tap(find.byKey(const Key('exercise-1')));
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));

    //verify(mockWorkoutPlans.addSet(any));
    //verify(mockWorkoutPlans.addSettinbg(any));
    //verify(mockWorkoutPlans.fetchSmartText(any, any));
  });
}
