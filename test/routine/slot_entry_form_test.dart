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
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/forms/reps_unit.dart';
import 'package:wger/widgets/routines/forms/rir.dart';
import 'package:wger/widgets/routines/forms/slot_entry.dart';
import 'package:wger/widgets/routines/forms/weight_unit.dart';

import '../../test_data/routines.dart';
import './slot_entry_form_test.mocks.dart';

@GenerateMocks([RoutinesProvider])
void main() {
  var mockRoutinesProvider = MockRoutinesProvider();

  final slotEntry = getTestRoutine().days[0].slots[0].entries[0];

  setUp(() {
    mockRoutinesProvider = MockRoutinesProvider();
  });

  Widget renderWidget({simpleMode = true, locale = 'en'}) {
    final key = GlobalKey<NavigatorState>();

    return riverpod.ProviderScope(
      overrides: [
        routineWeightUnitProvider.overrideWithValue(
          const riverpod.AsyncValue.data(testWeightUnits),
        ),
        routineRepetitionUnitProvider.overrideWithValue(
          const riverpod.AsyncValue.data(testRepetitionUnits),
        ),
      ],
      child: ChangeNotifierProvider<RoutinesProvider>(
        create: (context) => mockRoutinesProvider,
        child: MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: key,
          home: Scaffold(body: SlotEntryForm(slotEntry, 1, simpleMode: simpleMode)),
        ),
      ),
    );
  }

  testWidgets('Checks correct widgets are rendered in simple mode', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget());
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(Slider), findsOne);
    expect(find.byType(DropdownButtonFormField), findsNothing);
    expect(find.byType(WeightUnitInputWidget), findsNothing);
    expect(find.byType(RepetitionUnitInputWidget), findsNothing);
    expect(find.byType(RiRInputWidget), findsNothing);
  });

  testWidgets('Checks correct widgets are rendered in expanded mode', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget(simpleMode: false));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.byType(Slider), findsNWidgets(2));
    expect(find.byType(DropdownButtonFormField), findsNothing);
    expect(find.byType(WeightUnitInputWidget), findsOne);
    expect(find.byType(RepetitionUnitInputWidget), findsOne);
    expect(find.byType(RiRInputWidget), findsOne);
  });

  testWidgets('Correctly updates the values on the server', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget(simpleMode: false));
    await tester.pumpAndSettle();

    // Set weight
    final weightField = find.byKey(const ValueKey('field-weight'));
    await tester.enterText(weightField, '100');

    final maxWeightField = find.byKey(const ValueKey('field-max-weight'));
    await tester.enterText(maxWeightField, '110');

    // Set repetitions
    final repetitionsField = find.byKey(const ValueKey('field-repetitions'));
    await tester.enterText(repetitionsField, '10');
    final maxRepetitionsField = find.byKey(const ValueKey('field-max-repetitions'));
    await tester.enterText(maxRepetitionsField, '12');

    // Set rest time
    final restField = find.byKey(const ValueKey('field-rest'));
    await tester.enterText(restField, '90');
    final maxRestField = find.byKey(const ValueKey('field-max-rest'));
    await tester.enterText(maxRestField, '100');

    // Set type
    await tester.tap(find.byKey(const ValueKey('field-slot-entry-type')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('slot-entry-type-option-myo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('slot-entry-type-option-myo')), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey(SUBMIT_BUTTON_KEY_NAME)));
    await tester.pumpAndSettle();

    verify(
      mockRoutinesProvider.editSlotEntry(
        argThat(
          isA<SlotEntry>()
              .having((d) => d.id, 'id', null)
              .having((d) => d.slotId, 'slotId', 1)
              .having((d) => d.order, 'order', 1)
              .having((d) => d.type, 'type', SlotEntryType.myo),
        ),
        1,
      ),
    );

    final verification = verify(
      mockRoutinesProvider.handleConfig(captureAny, captureAny, captureAny),
    );
    final capturedArgs = verification.captured; // List with 8*3 arguments (3 per call)

    expect(capturedArgs[(0 * 3) + 1], 4);
    expect(capturedArgs[(0 * 3) + 2], ConfigType.sets);

    expect(capturedArgs[(1 * 3) + 1], 100);
    expect(capturedArgs[(1 * 3) + 2], ConfigType.weight);
    expect(capturedArgs[(2 * 3) + 1], 110);
    expect(capturedArgs[(2 * 3) + 2], ConfigType.maxWeight);

    expect(capturedArgs[(3 * 3) + 1], 10);
    expect(capturedArgs[(3 * 3) + 2], ConfigType.repetitions);
    expect(capturedArgs[(4 * 3) + 1], 12);
    expect(capturedArgs[(4 * 3) + 2], ConfigType.maxRepetitions);

    expect(capturedArgs[(5 * 3) + 1], 90);
    expect(capturedArgs[(5 * 3) + 2], ConfigType.rest);
    expect(capturedArgs[(6 * 3) + 1], 100);
    expect(capturedArgs[(6 * 3) + 2], ConfigType.maxRest);
  });
}
