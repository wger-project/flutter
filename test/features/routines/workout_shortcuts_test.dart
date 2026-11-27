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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/routines/notifications/workout_notification_content.dart';
import 'package:wger/features/routines/workout_shortcuts.dart';

import '../../../test_data/routines.dart';

void main() {
  test('start chooses today or the explicit training day and skips rest days', () {
    final day = getTestRoutine().dayDataGym.first;
    final yesterday = day.date.subtract(const Duration(days: 1));

    expect(shortcutDay([day], '', day.date), same(day));
    expect(shortcutDay([day], '', yesterday), isNull);
    expect(shortcutDay([day], '  ${day.day!.name.toUpperCase()} ', yesterday), same(day));
    expect(shortcutDay([day], 'missing', day.date), isNull);

    day.day!.isRest = true;
    expect(shortcutDay([day], '', day.date), isNull);
    expect(shortcutDay([day], day.day!.name, day.date), isNull);
  });

  test('only start, finish and plans wait for a frame', () {
    // The others run in the background, where iOS draws no frames
    expect(SHORTCUT_NAVIGATION_METHODS, {'start', 'finish', 'plans'});
    for (final method in [
      'log',
      'logValues',
      'skip',
      'extend',
      'status',
      'restEnd',
      'restRemaining',
      'next',
      'saveFinish',
    ]) {
      expect(SHORTCUT_NAVIGATION_METHODS, isNot(contains(method)));
    }
  });

  test('remaining rest in whole seconds, rounded up, 0 without one', () {
    final now = DateTime.utc(2026, 11, 12, 10);

    expect(shortcutRestRemaining(null, now), 0);
    expect(shortcutRestRemaining(now, now), 0);
    expect(shortcutRestRemaining(now.subtract(const Duration(seconds: 5)), now), 0);
    expect(shortcutRestRemaining(now.add(const Duration(milliseconds: 200)), now), 1);
    expect(shortcutRestRemaining(now.add(const Duration(seconds: 90)), now), 90);
  });

  test('log with values keeps the planned values for empty fields', () {
    final planned = getTestRoutine().dayDataGym.first.slots.first.setConfigs.first;

    final unchanged = shortcutLogValues(planned);
    expect(unchanged.repetitions, 3);
    expect(unchanged.weight, 100);

    final reps = shortcutLogValues(planned, repetitions: 5);
    expect(reps.repetitions, 5);
    expect(reps.weight, 100);
    expect(reps.repetitionsUnitId, unchanged.repetitionsUnitId);

    final both = shortcutLogValues(planned, repetitions: 8, weight: 82.5);
    expect(both.repetitions, 8);
    expect(both.weight, 82.5);
    expect(both.weightUnitId, unchanged.weightUnitId);
    expect(both.rir, unchanged.rir);
  });

  test('the next set is the one after the rest during a countdown, else the current one', () {
    final payload = WorkoutNotificationPayload(
      routineId: 1,
      dayId: 1,
      iteration: 1,
      workoutStart: DateTime.utc(2026),
    );
    final controls = WorkoutControls(title: 'Pause', body: 'Next: Bench press', payload: payload);
    final alarm = RestAlarm(
      at: DateTime.utc(2026),
      title: 'Bench press',
      body: 'Set 2 of 3 · 3x100kg',
      payload: payload,
    );

    expect(shortcutUpNext(WorkoutNotificationTarget.none), isNull);
    expect(
      shortcutUpNext(WorkoutNotificationTarget(controls: controls, alarm: alarm)),
      (title: 'Bench press', body: 'Set 2 of 3 · 3x100kg'),
    );
    expect(
      shortcutUpNext(WorkoutNotificationTarget(controls: controls)),
      (title: 'Pause', body: 'Next: Bench press'),
    );
  });
}
