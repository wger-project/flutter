/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/screens/auth_screen.dart';

void main() {
  testWidgets('Test the widgets on the auth screen, login mode', (WidgetTester tester) async {
    // Wrap screen in material app so that the media query gets a context
    await tester.pumpWidget(MaterialApp(home: AuthScreen()));
    expect(find.text('WGER'), findsOneWidget);

    // Verify that the correct buttons and input fields are shown: login
    expect(find.text('REGISTER INSTEAD'), findsOneWidget);
    expect(find.text('LOGIN INSTEAD'), findsNothing);

    // Check that the correct widgets are shown
    expect(find.byKey(Key('inputUsername')), findsOneWidget);
    expect(find.byKey(Key('inputEmail')), findsNothing);
    expect(find.byKey(Key('inputPassword')), findsOneWidget);
    expect(find.byKey(Key('inputServer')), findsOneWidget);
    expect(find.byKey(Key('inputPassword2')), findsNothing);
    expect(find.byKey(Key('actionButton')), findsOneWidget);
    expect(find.byKey(Key('toggleActionButton')), findsOneWidget);
  });

  testWidgets('Test the widgets on the auth screen, registration', (WidgetTester tester) async {
    // Wrap screen in material app so that the media query gets a context
    await tester.pumpWidget(MaterialApp(home: AuthScreen()));
    await tester.tap(find.byKey(Key('toggleActionButton')));

    // Rebuild the widget after the state has changed.
    await tester.pump();
    expect(find.text('REGISTER INSTEAD'), findsNothing);
    expect(find.text('LOGIN INSTEAD'), findsOneWidget);

    // Check that the correct widgets are shown
    expect(find.byKey(Key('inputUsername')), findsOneWidget);
    expect(find.byKey(Key('inputEmail')), findsOneWidget);
    expect(find.byKey(Key('inputPassword')), findsOneWidget);
    expect(find.byKey(Key('inputServer')), findsOneWidget);
    expect(find.byKey(Key('inputPassword2')), findsOneWidget);
    expect(find.byKey(Key('actionButton')), findsOneWidget);
    expect(find.byKey(Key('toggleActionButton')), findsOneWidget);
  });
}
