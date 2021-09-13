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
import 'package:wger/widgets/exercises/exercises.dart';

import '../../test_data/exercises.dart';

main() {
  Widget createHomeScreen({locale = 'en'}) {
    return MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorKey: GlobalKey<NavigatorState>(),
      home: Scaffold(
        body: ExerciseDetail(getExercise()[0]),
      ),
    );
  }

  testWidgets('Test the widgets on the SetFormWidget', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Arms'), findsOneWidget, reason: 'Category');

    expect(find.text('Equipment'), findsOneWidget);
    expect(find.text('Bench\nDumbbell'), findsOneWidget, reason: 'Equipment');

    expect(find.text('Muscles'), findsOneWidget);
    expect(find.text('Flutterus maximus\nBiceps'), findsOneWidget, reason: 'Muscles');

    expect(find.text('Secondary muscles'), findsOneWidget);
    expect(find.text('Booty'), findsOneWidget, reason: 'Secondary muscles');

    expect(find.text('add clever text'), findsOneWidget, reason: 'Description');
  });
}
