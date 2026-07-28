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

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/widgets/gym_mode/elapsed_time.dart';

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

  Future<void> pumpTimer(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: ElapsedWorkoutTimer(),
          ),
        ),
      ),
    );
  }

  testWidgets('Shows the time elapsed since the workout start', (tester) async {
    final now = DateTime(2024, 5, 1, 12, 0, 0);

    await withClock(Clock.fixed(now), () async {
      final notifier = container.read(gymStateProvider.notifier);
      notifier.state = GymModeState(
        workoutStart: now.subtract(const Duration(minutes: 1, seconds: 5)),
      );

      await pumpTimer(tester);

      expect(find.text('1:05'), findsOneWidget);
    });
  });

  testWidgets('Shows zero for a workout start in the future', (tester) async {
    final now = DateTime(2024, 5, 1, 12, 0, 0);

    await withClock(Clock.fixed(now), () async {
      final notifier = container.read(gymStateProvider.notifier);
      notifier.state = GymModeState(
        workoutStart: now.add(const Duration(minutes: 5)),
      );

      await pumpTimer(tester);

      expect(find.text('0:00'), findsOneWidget);
    });
  });

  group('ElapsedWorkoutTimer.format', () {
    test('Formats durations under an hour as m:ss', () {
      expect(ElapsedWorkoutTimer.format(Duration.zero), '0:00');
      expect(ElapsedWorkoutTimer.format(const Duration(seconds: 9)), '0:09');
      expect(ElapsedWorkoutTimer.format(const Duration(minutes: 59, seconds: 59)), '59:59');
    });

    test('Formats durations over an hour as h:mm:ss', () {
      expect(ElapsedWorkoutTimer.format(const Duration(hours: 1)), '1:00:00');
      expect(
        ElapsedWorkoutTimer.format(const Duration(hours: 2, minutes: 3, seconds: 4)),
        '2:03:04',
      );
    });
  });
}
