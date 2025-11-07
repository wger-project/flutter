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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/routine_edit_screen.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/widgets/routines/forms/routine.dart';

import './routine_form_test.mocks.dart';

@GenerateMocks([RoutinesProvider])
void main() {
  var mockRoutinesProvider = MockRoutinesProvider();

  final existingRoutine = Routine(
    id: 1,
    created: DateTime(2021, 1, 1),
    start: DateTime(2024, 11, 1),
    end: DateTime(2024, 12, 1),
    name: 'test 1',
    description: 'description 1',
    fitInWeek: false,
  );
  var newRoutine = Routine.empty();

  setUp(() {
    newRoutine = Routine.empty();
    mockRoutinesProvider = MockRoutinesProvider();
    when(mockRoutinesProvider.findById(any)).thenAnswer((_) => existingRoutine);
    when(mockRoutinesProvider.editRoutine(any)).thenAnswer((_) => Future.value(existingRoutine));
    when(
      mockRoutinesProvider.fetchAndSetRoutineFull(any),
    ).thenAnswer((_) => Future.value(existingRoutine));
  });

  Widget renderWidget(Routine routine, {locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ProviderScope(
      overrides: [
        routinesChangeProvider.overrideWithValue(mockRoutinesProvider),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: Scaffold(body: RoutineForm(routine)),
        routes: {
          RoutineScreen.routeName: (ctx) => const RoutineScreen(),
          RoutineEditScreen.routeName: (ctx) => const RoutineEditScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the routine form', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget(existingRoutine));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Test editing an existing routine', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget(existingRoutine));
    await tester.pumpAndSettle();

    expect(
      find.text('test 1'),
      findsOneWidget,
      reason: 'Name of existing routine',
    );
    expect(
      find.text('description 1'),
      findsOneWidget,
      reason: 'Description of existing routine',
    );
    await tester.enterText(find.byKey(const Key('field-name')), 'New description');
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));

    // Correct method was called
    verify(mockRoutinesProvider.editRoutine(any));
    verifyNever(mockRoutinesProvider.addRoutine(any));

    // TODO(x): edit calls Navigator.pop(), since the form can only be reached from the
    //       detail page. The test needs to add the detail page to the stack so that
    //       this can be checked.
    // https://stackoverflow.com/questions/50704647/how-to-test-navigation-via-navigator-in-flutter
    // Detail page
    //await tester.pumpAndSettle();
    //expect(find.text(('New description')), findsOneWidget, reason: 'Workout plan detail page');
  });

  testWidgets('Test editing an existing routine - server error', (WidgetTester tester) async {
    // Arrange
    when(mockRoutinesProvider.editRoutine(any)).thenThrow(
      WgerHttpException.fromMap({
        'name': ['The name is not valid'],
      }),
    );

    // Act
    await tester.pumpWidget(renderWidget(existingRoutine));
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
    await tester.pump();

    // Assert
    expect(find.text('The name is not valid'), findsOneWidget, reason: 'Error message is shown');
  });

  testWidgets('Test creating a new routine - only name', (WidgetTester tester) async {
    final editRoutine = Routine(
      id: 2,
      created: newRoutine.created,
      start: DateTime(2024, 11, 1),
      end: DateTime(2024, 12, 1),
      name: 'New cool routine',
    );

    when(mockRoutinesProvider.addRoutine(any)).thenAnswer((_) => Future.value(editRoutine));
    when(mockRoutinesProvider.findById(any)).thenAnswer((_) => editRoutine);

    await tester.pumpWidget(renderWidget(newRoutine));
    await tester.pumpAndSettle();

    expect(find.text(''), findsNWidgets(2), reason: 'New routine has no name or description');
    await tester.enterText(find.byKey(const Key('field-name')), editRoutine.name);
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));

    verifyNever(mockRoutinesProvider.editRoutine(any));
    verify(mockRoutinesProvider.addRoutine(any));

    // Detail page
    await tester.pumpAndSettle();
    expect(find.text('New cool routine'), findsWidgets, reason: 'routine detail page');
  });

  testWidgets('Test creating a new routine - name and description', (WidgetTester tester) async {
    final editRoutine = Routine(
      id: 2,
      created: newRoutine.created,
      start: DateTime(2024, 11, 1),
      end: DateTime(2024, 12, 1),
      name: 'My routine',
      description: 'Get yuuuge',
    );
    when(mockRoutinesProvider.addRoutine(any)).thenAnswer((_) => Future.value(editRoutine));
    when(mockRoutinesProvider.findById(any)).thenAnswer((_) => editRoutine);

    await tester.pumpWidget(renderWidget(newRoutine));
    await tester.pumpAndSettle();

    expect(find.text(''), findsNWidgets(2), reason: 'New routine has no name or description');
    await tester.enterText(find.byKey(const Key('field-name')), editRoutine.name);
    await tester.enterText(find.byKey(const Key('field-description')), editRoutine.description);
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));

    verifyNever(mockRoutinesProvider.editRoutine(any));
    verify(mockRoutinesProvider.addRoutine(any));

    // Detail page
    await tester.pumpAndSettle();
    expect(find.text('My routine'), findsWidgets, reason: 'routine detail page');
  });

  testWidgets('Test creating a new routine - server error', (WidgetTester tester) async {
    // Arrange
    when(mockRoutinesProvider.addRoutine(any)).thenThrow(
      WgerHttpException.fromMap({
        'name': ['The name is not valid'],
      }),
    );

    // Act
    await tester.pumpWidget(renderWidget(newRoutine));
    await tester.enterText(find.byKey(const Key('field-name')), 'test 1234');
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
    await tester.pump();

    // Assert
    expect(find.text('The name is not valid'), findsOneWidget, reason: 'Error message is shown');
  });
}
