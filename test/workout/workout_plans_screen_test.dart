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

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/database/exercises/exercise_database.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/workout_plans_screen.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/workouts/forms.dart';

import 'workout_plans_screen_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  var mockBaseProvider = MockWgerBaseProvider();
  final testExercisesProvider = ExercisesProvider(
    mockBaseProvider,
    database: ExerciseDatabase.inMemory(NativeDatabase.memory()),
  );

  setUp(() {
    mockBaseProvider = MockWgerBaseProvider();
  });

  Widget createHomeScreen({locale = 'en'}) {
    final uri = Uri(
      scheme: 'https',
      host: 'localhost',
      path: 'api/v2/workout/',
    );
    when(mockBaseProvider.makeUrl('workout', query: anyNamed('query'))).thenReturn(uri);
    when(mockBaseProvider.deleteRequest(any, any)).thenAnswer((_) async => http.Response('', 204));

    return ChangeNotifierProvider<WorkoutPlansProvider>(
      create: (context) => WorkoutPlansProvider(
        mockBaseProvider,
        testExercisesProvider,
        [
          WorkoutPlan(id: 1, creationDate: DateTime(2021, 01, 01), name: 'test 1'),
          WorkoutPlan(id: 2, creationDate: DateTime(2021, 02, 12), name: 'test 2'),
        ],
      ),
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const WorkoutPlansScreen(),
        routes: {
          FormScreen.routeName: (ctx) => const FormScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the workout plans screen', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    //debugDumpApp();
    expect(find.text('Workout plans'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('Test deleting an item using the Delete button', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    await tester.tap(find.byIcon(Icons.delete).first);

    await tester.pumpAndSettle();

    // Confirmation dialog
    expect(find.byType(AlertDialog), findsOneWidget);

    // Confirm
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
  });

  /*
  testWidgets('Test updating the list by dragging it down', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.fling(find.byKey(const Key('1')), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    //verify(mockWorkoutProvider.fetchAndSetAllPlansSparse());
  });

   */

  testWidgets('Test the form on the workout plan screen', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    expect(find.byType(PlanForm), findsNothing);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutForm), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - EN', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());

    expect(find.text('1/1/2021'), findsOneWidget);
    expect(find.text('2/12/2021'), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - DE', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(locale: 'de'));

    expect(find.text('1.1.2021'), findsOneWidget);
    expect(find.text('12.2.2021'), findsOneWidget);
  });
}
