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
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/forms/reps_unit.dart';
import 'package:wger/widgets/routines/forms/rir.dart';
import 'package:wger/widgets/routines/forms/slot.dart';
import 'package:wger/widgets/routines/forms/weight_unit.dart';

import '../../test_data/routines.dart';
import './slot_entry_form_test.mocks.dart';

@GenerateMocks([RoutinesProvider])
void main() {
  var mockRoutinesProvider = MockRoutinesProvider();

  final slotEntry = getTestRoutine().days[0].slots[0].entries[0];

  setUp(() {
    mockRoutinesProvider = MockRoutinesProvider();
    when(mockRoutinesProvider.weightUnits).thenReturn(testWeightUnits);
    when(mockRoutinesProvider.findWeightUnitById(any)).thenReturn(testWeightUnit1);
    when(mockRoutinesProvider.repetitionUnits).thenReturn(testRepetitionUnits);
    when(mockRoutinesProvider.findRepetitionUnitById(any)).thenReturn(testRepetitionUnit1);
  });

  Widget renderWidget({simpleMode = true, locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return ChangeNotifierProvider<RoutinesProvider>(
      create: (context) => mockRoutinesProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: key,
        home: Scaffold(body: SlotEntryForm(slotEntry, simpleMode: simpleMode)),
      ),
    );
  }

  testWidgets('Checks correct widgets are rendered in simple mode', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget());
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(Slider), findsOne);
    expect(find.byType(WeightUnitInputWidget), findsNothing);
    expect(find.byType(RepetitionUnitInputWidget), findsNothing);
    expect(find.byType(RiRInputWidget), findsNothing);
  });

  testWidgets('Checks correct widgets are rendered in expanded mode', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget(simpleMode: false));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.byType(Slider), findsNWidgets(2));
    expect(find.byType(WeightUnitInputWidget), findsOne);
    expect(find.byType(RepetitionUnitInputWidget), findsOne);
    expect(find.byType(RiRInputWidget), findsOne);
  });

  testWidgets('Correctly updates the values on the server', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget(simpleMode: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
    await tester.pumpAndSettle();

    verify(mockRoutinesProvider.editSlotEntry(any)).called(1);
    verify(mockRoutinesProvider.handleConfig(any, any, any)).called(8);
  });
}
