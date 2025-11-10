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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/routine_edit_screen.dart';

import '../../test_data/routines.dart';

void main() {
  final key = GlobalKey<NavigatorState>();

  testWidgets('RoutineEditScreen smoke test', (WidgetTester tester) async {
    final container = ProviderContainer.test();

    container.read(routinesRiverpodProvider.notifier).state = RoutinesState(
      routines: [getTestRoutine()],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
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
    expect(find.text('3 day workout'), findsNWidgets(2));
  });
}
