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
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/exercises/exercises.dart';

import '../../test_data/exercises.dart';
import '../gym_mode_screen_test.mocks.dart';

void main() {
  final mockProvider = MockExercisesProvider();

  Widget createHomeScreen({locale = 'en'}) {
    return ChangeNotifierProvider<ExercisesProvider>(
      create: (context) => mockProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: GlobalKey<NavigatorState>(),
        home: Scaffold(
          body: ExerciseDetail(getExercise()[0]),
        ),
      ),
    );
  }

  testWidgets('Test the widgets on the SetFormWidget', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    expect(find.text('Arms'), findsOneWidget, reason: 'Category');

    //expect(find.text('Equipment'), findsOneWidget);
    //expect(find.text('Bench'), findsOneWidget, reason: 'Equipment');
    //expect(find.text('Dumbbell'), findsOneWidget, reason: 'Equipment');

    expect(find.text('Muscles'), findsNWidgets(2));
    expect(find.text('Flutterus maximus'), findsOneWidget, reason: 'Main muscles');
    expect(find.text('Biceps'), findsOneWidget, reason: 'Main muscles');

    expect(find.text('Secondary muscles'), findsOneWidget);
    expect(
      find.byType(MuscleWidget),
      findsNWidgets(2),
      reason: 'Two diagrams, one for front, one for the back',
    );
    expect(find.text('Booty'), findsOneWidget, reason: 'Secondary muscles');

    expect(find.text('Description'), findsOneWidget, reason: 'Description header');
    expect(find.text('add clever text'), findsOneWidget, reason: 'Description');

    expect(find.text('Variations'), findsNothing);
  });
}
