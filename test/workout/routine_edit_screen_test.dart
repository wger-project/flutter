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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/routine_edit_screen.dart';

import '../../test_data/routines.dart';
import 'routine_edit_screen_test.mocks.dart';

@GenerateMocks([RoutinesProvider])
void main() {
  final key = GlobalKey<NavigatorState>();

  testWidgets('RoutineEditScreen smoke test', (WidgetTester tester) async {
    // Create a mock RoutinesProvider
    final mockRoutinesProvider = MockRoutinesProvider();
    when(mockRoutinesProvider.fetchAndSetRoutineFull(1)).thenAnswer((_) async => getTestRoutine());
    when(mockRoutinesProvider.findById(1)).thenReturn(getTestRoutine());

    // Build the RoutineEditScreen widget with the correct arguments
    await tester.pumpWidget(
      ChangeNotifierProvider<RoutinesProvider>.value(
        value: mockRoutinesProvider,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: key,
          home: TextButton(
            onPressed: () => key.currentState!.push(
              MaterialPageRoute<void>(
                settings: const RouteSettings(arguments: 1),
                builder: (_) => const RoutineEditScreen(),
              ),
            ),
            child: const SizedBox(),
          ),
        ),
      ),
    );

    // Navigate to RoutineEditScreen with the correct arguments
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // Verify the title is correct
    verify(mockRoutinesProvider.findById(1));
    expect(find.text('3 day workout'), findsNWidgets(2));
  });
}
