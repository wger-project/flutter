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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/forms/day.dart';
import 'package:wger/widgets/routines/routine_edit.dart';

import '../../test_data/routines.dart';
import 'routine_edit_test.mocks.dart';

@GenerateMocks([RoutinesProvider])
void main() {
  late MockRoutinesProvider mockRoutinesProvider;

  setUp(() {
    mockRoutinesProvider = MockRoutinesProvider();
    when(mockRoutinesProvider.fetchAndSetRoutineFull(1)).thenAnswer((_) async => getTestRoutine());
  });

  testWidgets('RoutineEditScreen smoke test', (WidgetTester tester) async {
    // Build the RoutineEditScreen widget with the correct arguments
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routinesChangeProvider.overrideWithValue(mockRoutinesProvider),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: RoutineEdit(getTestRoutine()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Always two widgets, one in the edit list, one in the generated routine
    expect(find.text('3 day workout'), findsOne, reason: 'title');
    expect(
      find.text('This is a 3 day workout and this text is important'),
      findsNWidgets(2),
      reason: 'description',
    );

    expect(find.text('first day'), findsNWidgets(2));
    expect(find.text('chest, shoulders'), findsNWidgets(2), reason: 'description');

    expect(find.text('second day'), findsNWidgets(2));
    expect(find.text('legs'), findsNWidgets(2), reason: 'description');

    // Edit the first day
    expect(find.byElementType(DayFormWidget), findsNothing);
    expect(find.byIcon(Icons.edit), findsNWidgets(2));
    expect(find.byIcon(Icons.edit_off), findsNothing);
    expect(find.byKey(const ValueKey('edit-day-1')), findsOne);
    expect(find.byKey(const ValueKey('edit-day-2')), findsOne);
    expect(find.text('is rest day'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('edit-day-1')));
    await tester.pumpAndSettle();

    expect(
      find.byIcon(Icons.edit),
      findsNWidgets(3),
      reason: 'also for the days',
    );
    expect(find.byIcon(Icons.edit_off), findsOne);
    expect(find.text('Is rest day'), findsOne);

    expect(find.text('Exercise 1'), findsOne);
    expect(
      find.text('Bench press'),
      findsNWidgets(3),
      reason: 'resulting routine plus edit',
    );

    expect(find.text('Exercise 2'), findsOne);
    expect(
      find.text('Side raises'),
      findsNWidgets(2),
      reason: 'resulting routine plus edit',
    );
  });
}
