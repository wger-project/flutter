/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/widgets/routines/gym_mode/workout_menu.dart';

import '../../../test_data/routines.dart';

void main() {
  late GymStateNotifier notifier;
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer.test();
    notifier = container.read(gymStateProvider.notifier);
    notifier.state = notifier.state.copyWith(
      showExercisePages: false,
      showTimerPages: false,
      dayId: 1,
      iteration: 1,
      routine: getTestRoutine(),
    );
    notifier.calculatePages();
  });

  Widget renderWidget({locale = 'en'}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ProgressionTab(PageController()),
        ),
      ),
    );
  }

  testWidgets('Smoke and golden test', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget());

    if (Platform.isLinux) {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/gym_mode_progression_tab.png'),
      );
    }
  });

  testWidgets('Opens the exercise swap', (WidgetTester tester) async {
    await tester.pumpWidget(renderWidget());

    expect(find.byType(ExerciseSwapWidget), findsNothing);

    await tester.tap(find.byKey(Key('swap-icon-${notifier.state.pages[1].uuid}')));
    await tester.pumpAndSettle();
    expect(find.byType(ExerciseSwapWidget), findsOne);
  });
}
