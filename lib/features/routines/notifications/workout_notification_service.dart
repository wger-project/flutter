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

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:wger/features/routines/notifications/workout_notification_content.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

const WORKOUT_NOTIFICATION_ACTION_LOG_SET = 'log_set';
const WORKOUT_NOTIFICATION_ACTION_SKIP_REST = 'skip_rest';

/// The main isolate receives notification actions on this port
const WORKOUT_NOTIFICATION_PORT = 'wger_workout_actions';

/// Called with the payload when the user taps the notification itself
typedef WorkoutNotificationTapHandler = void Function(String? payload);

/// Runs in a separate isolate without the gym state, so it only forwards the
/// action. Without a running app nothing is logged, the user is sent there.
@pragma('vm:entry-point')
Future<void> workoutNotificationBackgroundHandler(NotificationResponse response) async {
  final port = IsolateNameServer.lookupPortByName(WORKOUT_NOTIFICATION_PORT);
  if (port != null) {
    port.send([response.actionId, response.payload]);
    return;
  }

  final locale = basicLocaleListResolution(
    PlatformDispatcher.instance.locales,
    AppLocalizations.supportedLocales,
  );
  final labels = WorkoutNotificationLabels.of(lookupAppLocalizations(locale));
  final service = LocalWorkoutNotificationService();
  await service.initialize(labels);
  await service.showNotLogged(labels);
}

/// Shows the workout notifications on the platform.
///
/// The controls and the rest alarm share one notification, so the alarm
/// replaces the controls in place when it fires.
abstract class WorkoutNotificationService {
  /// Whether the platform has the ongoing controls notification
  bool get supportsControls;

  /// Registers the actions and [onTap], before anything else is shown
  Future<void> initialize(WorkoutNotificationLabels labels, {WorkoutNotificationTapHandler? onTap});

  Future<void> requestPermissions(WorkoutNotificationLabels labels);

  /// Whether rest alarms fire on time. Without, Android may delay them.
  Future<bool> canScheduleExactAlarms();

  /// Sends the user to the system setting for exact alarms
  Future<void> requestExactAlarms();

  Future<void> scheduleRestAlarm(RestAlarm alarm, WorkoutNotificationLabels labels);

  Future<void> showControls(WorkoutControls controls, WorkoutNotificationLabels labels);

  /// Tells the user that an action was not carried out and the app is needed
  Future<void> showNotLogged(WorkoutNotificationLabels labels);

  /// Removes the shown notification and a pending rest alarm
  Future<void> cancelAll();

  /// Lets the platform suspend the app again after an action
  Future<void> actionHandled();
}

/// For platforms without workout notifications
class NoopWorkoutNotificationService implements WorkoutNotificationService {
  @override
  bool get supportsControls => false;

  @override
  Future<void> initialize(
    WorkoutNotificationLabels labels, {
    WorkoutNotificationTapHandler? onTap,
  }) async {}

  @override
  Future<void> requestPermissions(WorkoutNotificationLabels labels) async {}

  @override
  Future<bool> canScheduleExactAlarms() async => true;

  @override
  Future<void> requestExactAlarms() async {}

  @override
  Future<void> scheduleRestAlarm(RestAlarm alarm, WorkoutNotificationLabels labels) async {}

  @override
  Future<void> showControls(WorkoutControls controls, WorkoutNotificationLabels labels) async {}

  @override
  Future<void> showNotLogged(WorkoutNotificationLabels labels) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> actionHandled() async {}
}

/// Android and iOS, via flutter_local_notifications
class LocalWorkoutNotificationService implements WorkoutNotificationService {
  static const _notificationId = 1;
  static const _controlsChannelId = 'workout_controls';
  static const _alarmChannelId = 'rest_alarm';
  static const _restEndCategory = 'workout_rest_end';
  static const _actionTasksChannel = MethodChannel('de.wger.flutter/notification_actions');

  final _logger = Logger('LocalWorkoutNotificationService');
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initialized;

  @override
  bool get supportsControls => defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> initialize(
    WorkoutNotificationLabels labels, {
    WorkoutNotificationTapHandler? onTap,
  }) {
    // The iOS action labels are registered once, with the first labels seen
    return _initialized ??= _plugin
        .initialize(
          settings: InitializationSettings(
            android: const AndroidInitializationSettings('ic_stat_wger'),
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
          onDidReceiveNotificationResponse: (response) {
            // Actions go to the background handler, this is a tap on the body
            if (response.notificationResponseType ==
                NotificationResponseType.selectedNotification) {
              onTap?.call(response.payload);
            }
          },
          onDidReceiveBackgroundNotificationResponse: workoutNotificationBackgroundHandler,
        )
        .then((_) {});
  }

  Future<void> _ensureInitialized(WorkoutNotificationLabels labels) =>
      _initialized ?? initialize(labels);

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

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> canScheduleExactAlarms() async =>
      await _android?.canScheduleExactNotifications() ?? true;

  @override
  Future<void> requestExactAlarms() async {
    await _android?.requestExactAlarmsPermission();
  }

  @override
  Future<void> scheduleRestAlarm(RestAlarm alarm, WorkoutNotificationLabels labels) async {
    await _ensureInitialized(labels);
    final exact = await canScheduleExactAlarms();
    await _plugin.zonedSchedule(
      id: _notificationId,
      scheduledDate: tz.TZDateTime.from(alarm.at, tz.UTC),
      title: alarm.title,
      body: alarm.body,
      payload: alarm.payload.encode(),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
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
          presentSound: true,
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
  Future<void> showNotLogged(WorkoutNotificationLabels labels) async {
    await _ensureInitialized(labels);
    await _plugin.show(
      id: _notificationId,
      title: labels.notLoggedTitle,
      body: labels.notLoggedBody,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _alarmChannelId,
          labels.alarmChannel,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> cancelAll() async {
    // The app initializes the service at startup, so this also reaches
    // notifications left behind by an earlier process
    await _initialized;
    await _plugin.cancel(id: _notificationId);
  }

  @override
  Future<void> actionHandled() async {
    // Only iOS holds the app awake for an action, see AppDelegate.swift
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    try {
      await _actionTasksChannel.invokeMethod<void>('actionHandled');
    } on PlatformException catch (e) {
      _logger.warning('Could not end the background task: $e');
    }
  }
}

/// Whether rest alarms fire on time, rechecked whenever it is shown again
final exactAlarmsAllowedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.read(workoutNotificationServiceProvider).canScheduleExactAlarms(),
);

final workoutNotificationServiceProvider = Provider<WorkoutNotificationService>((ref) {
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    return LocalWorkoutNotificationService();
  }
  return NoopWorkoutNotificationService();
});
