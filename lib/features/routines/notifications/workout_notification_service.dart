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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:wger/features/routines/notifications/workout_notification_content.dart';

const WORKOUT_NOTIFICATION_ACTION_LOG_SET = 'log_set';
const WORKOUT_NOTIFICATION_ACTION_SKIP_REST = 'skip_rest';

/// Shows the workout notifications on the platform.
///
/// The controls and the rest alarm share one notification, so the alarm
/// replaces the controls in place when it fires.
abstract class WorkoutNotificationService {
  /// Whether the platform has the ongoing controls notification
  bool get supportsControls;

  Future<void> requestPermissions(WorkoutNotificationLabels labels);

  Future<void> scheduleRestAlarm(RestAlarm alarm, WorkoutNotificationLabels labels);

  Future<void> showControls(WorkoutControls controls, WorkoutNotificationLabels labels);

  /// Removes the shown notification and a pending rest alarm
  Future<void> cancelAll();
}

/// For platforms without workout notifications
class NoopWorkoutNotificationService implements WorkoutNotificationService {
  @override
  bool get supportsControls => false;

  @override
  Future<void> requestPermissions(WorkoutNotificationLabels labels) async {}

  @override
  Future<void> scheduleRestAlarm(RestAlarm alarm, WorkoutNotificationLabels labels) async {}

  @override
  Future<void> showControls(WorkoutControls controls, WorkoutNotificationLabels labels) async {}

  @override
  Future<void> cancelAll() async {}
}

/// Android and iOS, via flutter_local_notifications
class LocalWorkoutNotificationService implements WorkoutNotificationService {
  static const _notificationId = 1;
  static const _controlsChannelId = 'workout_controls';
  static const _alarmChannelId = 'rest_alarm';
  static const _restEndCategory = 'workout_rest_end';

  final _logger = Logger('LocalWorkoutNotificationService');
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initialized;

  @override
  bool get supportsControls => defaultTargetPlatform == TargetPlatform.android;

  /// The iOS action labels are registered once, with the first labels seen
  Future<void> _ensureInitialized(WorkoutNotificationLabels labels) {
    return _initialized ??= _plugin
        .initialize(
          settings: InitializationSettings(
            android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings(
              requestAlertPermission: false,
              requestBadgePermission: false,
              requestSoundPermission: false,
              notificationCategories: [
                DarwinNotificationCategory(
                  _restEndCategory,
                  actions: [
                    DarwinNotificationAction.plain(
                      WORKOUT_NOTIFICATION_ACTION_LOG_SET,
                      labels.logSet,
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .then((_) {});
  }

  @override
  Future<void> requestPermissions(WorkoutNotificationLabels labels) async {
    await _ensureInitialized(labels);
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final granted =
        await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, sound: true);
    _logger.fine('Notification permission granted: $granted');
  }

  @override
  Future<void> scheduleRestAlarm(RestAlarm alarm, WorkoutNotificationLabels labels) async {
    await _ensureInitialized(labels);
    await _plugin.zonedSchedule(
      id: _notificationId,
      scheduledDate: tz.TZDateTime.from(alarm.at, tz.UTC),
      title: alarm.title,
      body: alarm.body,
      payload: alarm.payload.encode(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _alarmChannelId,
          labels.alarmChannel,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          actions: [
            if (alarm.canLogSet)
              AndroidNotificationAction(WORKOUT_NOTIFICATION_ACTION_LOG_SET, labels.logSet),
          ],
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: alarm.canLogSet ? _restEndCategory : null,
        ),
      ),
    );
  }

  @override
  Future<void> showControls(WorkoutControls controls, WorkoutNotificationLabels labels) async {
    await _ensureInitialized(labels);
    final chronometerAt = controls.chronometerAt;
    await _plugin.show(
      id: _notificationId,
      title: controls.title,
      body: controls.body,
      payload: controls.payload.encode(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _controlsChannelId,
          labels.controlsChannel,
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          playSound: false,
          enableVibration: false,
          category: AndroidNotificationCategory.workout,
          visibility: NotificationVisibility.public,
          showWhen: chronometerAt != null,
          when: chronometerAt?.millisecondsSinceEpoch,
          usesChronometer: chronometerAt != null,
          chronometerCountDown: controls.chronometerCountsDown,
          actions: [
            if (controls.canSkipRest)
              AndroidNotificationAction(WORKOUT_NOTIFICATION_ACTION_SKIP_REST, labels.skipRest),
            if (controls.canLogSet)
              AndroidNotificationAction(WORKOUT_NOTIFICATION_ACTION_LOG_SET, labels.logSet),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> cancelAll() async {
    // This process has shown nothing yet, leftovers of an earlier one are
    // cleaned up at startup
    if (_initialized == null) {
      return;
    }
    await _initialized;
    await _plugin.cancel(id: _notificationId);
  }
}

final workoutNotificationServiceProvider = Provider<WorkoutNotificationService>((ref) {
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    return LocalWorkoutNotificationService();
  }
  return NoopWorkoutNotificationService();
});
