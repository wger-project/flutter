/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/widgets/gym_mode/elapsed_time.dart';
import 'package:wger/features/routines/widgets/gym_mode/navigation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        gymStateProvider.overrideWith(() => GymStateNotifier()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> pumpFooter(WidgetTester tester) async {
    final controller = PageController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: NavigationFooter(controller),
          ),
        ),
      ),
    );
  }

  testWidgets('Shows the elapsed workout timer by default', (tester) async {
    await pumpFooter(tester);

    expect(find.byType(ElapsedWorkoutTimer), findsOneWidget);
  });

  testWidgets('Hides the elapsed workout timer when disabled', (tester) async {
    final notifier = container.read(gymStateProvider.notifier);
    notifier.state = GymModeState(showWorkoutDuration: false);

    await pumpFooter(tester);

    expect(find.byType(ElapsedWorkoutTimer), findsNothing);
  });
}
