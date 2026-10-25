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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:wger/features/routines/notifications/workout_notification_content.dart';
import 'package:wger/features/routines/notifications/workout_notification_service.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  late List<MethodCall> calls;
  late bool exactAllowed;

  const labels = WorkoutNotificationLabels(
    logSet: 'Log set',
    skipRest: 'Skip rest',
    controlsChannel: 'Workout',
    alarmChannel: 'Rest alarm',
    notLoggedTitle: 'Set not logged',
    notLoggedBody: 'Open gym mode',
  );
  final payload = WorkoutNotificationPayload(
    routineId: 1,
    dayId: 1,
    iteration: 1,
    workoutStart: DateTime.utc(2025, 3, 29, 14, 33),
  );

  setUpAll(tzdata.initializeTimeZones);

  group('actionHandled', () {
    const tasksChannel = MethodChannel('de.wger.flutter/notification_actions');
    late List<String> taskCalls;

    setUp(() {
      taskCalls = [];
      binding.defaultBinaryMessenger.setMockMethodCallHandler(tasksChannel, (call) async {
        taskCalls.add(call.method);
        return null;
      });
      addTearDown(
        () => binding.defaultBinaryMessenger.setMockMethodCallHandler(tasksChannel, null),
      );
    });

    test('Ends the background task on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      await LocalWorkoutNotificationService().actionHandled();

      expect(taskCalls, ['actionHandled']);
    });

    test('Does nothing on Android, which keeps no task', () async {
      await LocalWorkoutNotificationService().actionHandled();

      expect(taskCalls, isEmpty);
    });
  });

  setUp(() {
    // The Android side of the plugin, talking to a fake platform channel
    FlutterLocalNotificationsPlatform.instance = AndroidFlutterLocalNotificationsPlugin();
    calls = [];
    exactAllowed = true;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'canScheduleExactNotifications' => exactAllowed,
        'initialize' => true,
        _ => null,
      };
    });
    addTearDown(() => binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
  });

  Map<Object?, Object?> scheduled() =>
      (calls.singleWhere((c) => c.method == 'zonedSchedule').arguments as Map)['platformSpecifics']
          as Map;

  RestAlarm alarm({bool canLogSet = true}) => RestAlarm(
    at: DateTime.now().add(const Duration(minutes: 2)),
    title: 'Rest is over',
    body: 'Next: Bench press',
    canLogSet: canLogSet,
    payload: payload,
  );

  test('Initializes with the monochrome status bar icon', () async {
    await LocalWorkoutNotificationService().initialize(labels);

    final init = calls.singleWhere((c) => c.method == 'initialize').arguments as Map;
    expect(init['defaultIcon'], 'ic_stat_wger');
  });

  test('The rest alarm is exact when allowed', () async {
    await LocalWorkoutNotificationService().scheduleRestAlarm(alarm(), labels);

    expect(scheduled()['scheduleMode'], AndroidScheduleMode.exactAllowWhileIdle.name);
  });

  test('Without the exact alarm permission it falls back to an inexact alarm', () async {
    exactAllowed = false;

    await LocalWorkoutNotificationService().scheduleRestAlarm(alarm(), labels);

    expect(scheduled()['scheduleMode'], AndroidScheduleMode.inexactAllowWhileIdle.name);
  });

  test('The alarm only offers "Log set" when the set can be logged', () async {
    final service = LocalWorkoutNotificationService();

    await service.scheduleRestAlarm(alarm(), labels);
    expect(
      (scheduled()['actions'] as List).map((a) => (a as Map)['id']),
      [WORKOUT_NOTIFICATION_ACTION_LOG_SET],
    );

    calls.clear();
    await service.scheduleRestAlarm(alarm(canLogSet: false), labels);
    expect(scheduled()['actions'], anyOf(isNull, isEmpty));
  });
}
