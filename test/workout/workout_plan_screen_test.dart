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
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/workout_plan_screen.dart';

import '../../test_data/workouts.dart';
import '../other/base_provider_test.mocks.dart';
import '../utils.dart';

void main() {
  Widget createHomeScreen({locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();
    final client = MockClient();

    return ChangeNotifierProvider<WorkoutPlansProvider>(
      create: (context) =>
          WorkoutPlansProvider(testAuthProvider, testExercisesProvider, [], client),
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: TextButton(
          onPressed: () => key.currentState!.push(
            MaterialPageRoute<void>(
              settings: RouteSettings(arguments: getWorkout()),
              builder: (_) => WorkoutPlanScreen(),
            ),
          ),
          child: const SizedBox(),
        ),
        routes: {
          WorkoutPlanScreen.routeName: (ctx) => WorkoutPlanScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the nutritional plan screen', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('3 day workout'), findsOneWidget);
    expect(find.text('chest, shoulders'), findsOneWidget);
    expect(find.text('legs'), findsOneWidget);
    expect(find.byType(Dismissible), findsNWidgets(2));
  });

  testWidgets('Tests the localization of times - EN', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('Monday, Tuesday'), findsOneWidget);
    expect(find.text('Thursday'), findsOneWidget);
  });

  testWidgets('Tests the localization of times - DE', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen(locale: 'de'));
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('Montag, Dienstag'), findsOneWidget);
    expect(find.text('Donnerstag'), findsOneWidget);
  });
}
