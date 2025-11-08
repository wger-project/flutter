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
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/routine_list_screen.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/routines/forms/routine.dart';

import 'routines_screen_test.mocks.dart';

@GenerateMocks([RoutinesProvider])
void main() {
  MockRoutinesProvider mockRoutinesProvider = MockRoutinesProvider();

  final routine1 = Routine(
    id: 1,
    created: DateTime(2021, 01, 01),
    start: DateTime(2024, 11, 1),
    end: DateTime(2024, 12, 1),
    name: 'test 1',
    fitInWeek: false,
  );

  final routine2 = Routine(
    id: 2,
    created: DateTime(2021, 02, 12),
    start: DateTime(2024, 5, 5),
    end: DateTime(2024, 6, 6),
    name: 'test 2',
    fitInWeek: false,
  );

  setUp(() {
    mockRoutinesProvider = MockRoutinesProvider();
  });

  Widget renderWidget({locale = 'en', isOnline = true}) {
    when(mockRoutinesProvider.fetchAndSetRoutineFull(any)).thenAnswer(
      (_) async => routine1,
    );
    when(mockRoutinesProvider.routines).thenReturn([
      routine1,
      routine2,
    ]);
    when(mockRoutinesProvider.findById(1)).thenReturn(routine1);

    return riverpod.ProviderScope(
      overrides: [
        networkStatusProvider.overrideWithValue(isOnline),
        routinesChangeProvider.overrideWithValue(mockRoutinesProvider),
      ],
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const RoutineListScreen(),
        routes: {
          FormScreen.routeName: (ctx) => const FormScreen(),
          RoutineScreen.routeName: (ctx) => const RoutineScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the workout plans screen', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget());

    //debugDumpApp();
    expect(find.text('Routines'), findsOneWidget);
    expect(find.text('test 1'), findsOneWidget);
    expect(find.text('test 2'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('Test deleting an item using the Delete button', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget());
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    // Confirmation dialog
    expect(find.byType(AlertDialog), findsOneWidget);

    // Confirm
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    verify(mockRoutinesProvider.deleteRoutine(1)).called(1);
  });

  testWidgets('Handle offline status', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget(isOnline: false));
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    // No confirmation dialog (button is disabled)
    expect(find.byType(AlertDialog), findsNothing);
    verifyNever(mockRoutinesProvider.deleteRoutine(1));
  });

  /*
  testWidgets('Test updating the list by dragging it down', (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.fling(find.byKey(const Key('1')), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    //verify(mockRoutinesProvider.fetchAndSetAllPlansSparse());
  });
   */

  testWidgets('Test the form on the workout plan screen', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget());

    expect(find.byType(PlanForm), findsNothing);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(RoutineForm), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - EN', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget());

    expect(find.text('11/1/2024 - 12/1/2024'), findsOneWidget);
    expect(find.text('5/5/2024 - 6/6/2024'), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - DE', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget(locale: 'de'));

    expect(find.text('1.11.2024 - 1.12.2024'), findsOneWidget);
    expect(find.text('5.5.2024 - 6.6.2024'), findsOneWidget);
  });
}
