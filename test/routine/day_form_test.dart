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
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/forms/day.dart';

import '../../test_data/routines.dart';
import 'routine_edit_test.mocks.dart';

@GenerateMocks([RoutinesProvider])
void main() {
  late MockRoutinesProvider mockRoutinesProvider;

  setUp(() {
    mockRoutinesProvider = MockRoutinesProvider();
    when(mockRoutinesProvider.editDay(any)).thenAnswer((_) async => getTestRoutine().days[0]);
  });

  Widget renderWidget() {
    return ChangeNotifierProvider<RoutinesProvider>.value(
      value: mockRoutinesProvider,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: DayFormWidget(routineId: 125, day: getTestRoutine().days[0]),
          ),
        ),
      ),
    );
  }

  group('DayFormWidget test', () {
    testWidgets('Fields are disabled for rest days', (WidgetTester tester) async {
      await tester.pumpWidget(renderWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('field-is-rest-day')));
      await tester.pumpAndSettle();

      final nameField = find.byKey(const Key('field-name'));
      final TextFormField nameTextField = tester.widget(nameField);
      expect(nameTextField.enabled, isFalse);

      final descriptionField = find.byKey(const Key('field-description'));
      final TextFormField descriptionTextField = tester.widget(descriptionField);
      expect(descriptionTextField.enabled, isFalse);

      final switchListTileFinder = find.byKey(const Key('field-need-logs-to-advance'));
      final SwitchListTile switchListTile = tester.widget(switchListTileFinder);
      expect(switchListTile.onChanged, isNull);
    });

    testWidgets('Call server', (WidgetTester tester) async {
      await tester.pumpWidget(renderWidget());
      await tester.pumpAndSettle();

      final nameField = find.byKey(const Key('field-name'));
      await tester.enterText(nameField, '');
      await tester.enterText(nameField, 'Day 1');

      final descriptionField = find.byKey(const Key('field-description'));
      await tester.enterText(descriptionField, '');
      await tester.enterText(descriptionField, 'Day 1 description');

      await tester.tap(find.byKey(const Key(SUBMIT_BUTTON_KEY_NAME)));
      await tester.pumpAndSettle();

      verify(
        mockRoutinesProvider.editDay(
          argThat(
            isA<Day>()
                .having((d) => d.routineId, 'routineId', 125)
                .having((d) => d.id, 'id', 1)
                .having((d) => d.name, 'name', 'Day 1')
                .having((d) => d.description, 'description', 'Day 1 description'),
          ),
        ),
      );
    });
  });
}
