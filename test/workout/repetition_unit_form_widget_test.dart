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
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/widgets/routines/forms/reps_unit.dart';

import 'repetition_unit_form_widget_test.mocks.dart';

@GenerateMocks([RoutinesProvider])
void main() {
  var mockWorkoutPlans = MockRoutinesProvider();
  const unit1 = RepetitionUnit(id: 1, name: 'some rep unit');
  const unit2 = RepetitionUnit(id: 2, name: 'another name');
  const unit3 = RepetitionUnit(id: 3, name: 'this is repetition number 3');

  var result = -1;

  final slotEntry = SlotEntry(
    slotId: 1,
    type: 'normal',
    order: 1,
    exerciseId: 1,
    repetitionUnitId: 1,
    repetitionRounding: 0.25,
    weightUnitId: 1,
    weightRounding: 0.25,
    comment: 'comment',
  );
  slotEntry.repetitionUnitObj = unit1;

  setUp(() {
    mockWorkoutPlans = MockRoutinesProvider();
    result = -1;
    when(mockWorkoutPlans.repetitionUnits).thenAnswer((_) => [unit1, unit2, unit3]);
    when(mockWorkoutPlans.findRepetitionUnitById(1)).thenReturn(unit1);
    when(mockWorkoutPlans.findRepetitionUnitById(2)).thenReturn(unit2);
  });

  Widget renderWidget() {
    final key = GlobalKey<NavigatorState>();

    return ChangeNotifierProvider<RoutinesProvider>(
      create: (context) => mockWorkoutPlans,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: Scaffold(body: RepetitionUnitInputWidget(1, onChanged: (value) => result = value)),
        routes: {
          RoutineScreen.routeName: (ctx) => const RoutineScreen(),
        },
      ),
    );
  }

  testWidgets('Test that the entries are shown', (WidgetTester tester) async {
    // arrange
    await tester.pumpWidget(renderWidget());
    await tester.tap(find.byKey(const Key('1')));
    await tester.pump();

    // assert
    expect(find.text('some rep unit'), findsWidgets);
    expect(find.text('another name'), findsWidgets);
    expect(find.text('this is repetition number 3'), findsWidgets);
  });

  testWidgets('Test that the correct units are set after selection', (WidgetTester tester) async {
    // arrange
    await tester.pumpWidget(renderWidget());
    await tester.pump();

    // act
    await tester.tap(find.byKey(const Key('1')));
    await tester.pump();
    await tester.tap(find.text('another name').last);

    // assert
    expect(result, equals(2));
  });
}
