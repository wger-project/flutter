// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

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
