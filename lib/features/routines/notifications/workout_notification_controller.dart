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

import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/app_settings_notifier.dart';
import 'package:wger/core/network/wger_base.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/notifications/workout_notification_content.dart';
import 'package:wger/features/routines/notifications/workout_notification_service.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/providers/workout_logs_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Whether the gym mode screen is mounted
final gymModeVisibleProvider = NotifierProvider<GymModeVisibleNotifier, bool>(
  GymModeVisibleNotifier.new,
);

class GymModeVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool visible) {
    // The screen reports leaving after its own disposal, maybe after the app's
    if (ref.mounted) {
      state = visible;
    }
  }
}

/// Keeps the platform notifications in line with the gym state and carries
/// out what the user does with them
class WorkoutNotificationController {
  final _logger = Logger('WorkoutNotificationController');
  final Ref _ref;
  final WorkoutNotificationService _service;

  /// What the platform shows, null if unknown
  WorkoutNotificationTarget? _shown = WorkoutNotificationTarget.none;
  Future<void> _queue = Future.value();

  /// Earlier logs of the exercise of the set "log set" logs
  ProviderSubscription<AsyncValue<List<Log>>>? _recentLogsSubscription;
  int? _recentLogsExerciseId;
  List<Log> _recentLogs = const [];

  WorkoutNotificationController(this._ref, this._service);

  /// The locale the app renders in, also without a BuildContext
  Locale get _locale =>
      _ref.read(appSettingsProvider).value?.userLocale ??
      basicLocaleListResolution(
        PlatformDispatcher.instance.locales,
        AppLocalizations.supportedLocales,
      );

  WorkoutNotificationLabels get labels =>
      WorkoutNotificationLabels.of(lookupAppLocalizations(_locale));

  /// Runs platform calls one after the other, in call order
  Future<void> _enqueue(Future<void> Function() step) {
    return _queue = _queue
        .then((_) => step())
        .catchError((Object e) => _logger.warning('Could not update the notification: $e'));
  }

  /// Shows what the gym state calls for. Nothing while gym mode is on screen,
  /// the screen itself shows the rest.
  void update() {
    final state = _ref.read(gymStateProvider);
    final inForeground = !_backgroundStates.contains(WidgetsBinding.instance.lifecycleState);
    final locale = _locale;
    final i18n = lookupAppLocalizations(locale);

    // Only while gym mode is open in the background: on screen it shows the
    // rest itself, and leaving it (X, back) ends the notifications
    WorkoutNotificationTarget build({required bool withControls}) => buildWorkoutNotification(
      state,
      now: clock.now(),
      i18n: i18n,
      languageCode: locale.languageCode,
      withControls: withControls,
      recentLogs: _recentLogs,
      mediaUrl: _ref.read(mediaUrlBuilderProvider),
    );

    final target = inForeground || !_ref.read(gymModeVisibleProvider)
        ? WorkoutNotificationTarget.none
        : build(withControls: _service.supportsControls && state.showWorkoutNotification);
    final labels = WorkoutNotificationLabels.of(i18n);
    unawaited(_enqueue(() => _apply(target, labels)));

    // Also while nothing is shown, so the logs are there once something is
    _watchRecentLogs(state, build(withControls: true));
  }

  /// Follows the earlier logs of the set the notification can log
  void _watchRecentLogs(GymModeState state, WorkoutNotificationTarget target) {
    final key = target.controls?.payload.logSlotKey;
    final exerciseId = key == null ? null : state.getSlotPageByKey(key)?.setConfigData?.exerciseId;
    if (exerciseId == _recentLogsExerciseId) {
      return;
    }

    _recentLogsSubscription?.close();
    _recentLogsSubscription = null;
    _recentLogsExerciseId = exerciseId;
    _recentLogs = const [];
    if (exerciseId == null) {
      return;
    }
    _recentLogsSubscription = _ref.listen(
      pastExerciseLogsProvider(
        routineId: state.routine.id!,
        exerciseId: exerciseId,
        weeksBack: state.logScopeWeeks,
      ),
      (_, logs) {
        _recentLogs = logs.value ?? const [];
        update();
      },
      // The log page may have loaded them already
      fireImmediately: true,
    );
  }

  /// Like [update], also when nothing seems to have changed: the platform may
  /// have removed the notification on its own
  void refresh() {
    unawaited(_enqueue(() async => _shown = null));
    update();
  }

  Future<void> _apply(WorkoutNotificationTarget target, WorkoutNotificationLabels labels) async {
    if (target == _shown) {
      return;
    }
    _shown = target;

    // Alarm and controls share one notification, so every change starts over
    try {
      await _service.cancelAll();
      if (target.alarm != null) {
        await _service.scheduleRestAlarm(target.alarm!, labels);
      }
      if (target.controls != null) {
        await _service.showControls(target.controls!, labels);
      }
    } catch (_) {
      // Unknown what the platform shows now, the next update tries again
      _shown = null;
      rethrow;
    }
  }

  /// Carries out a notification action. Stale actions only refresh the
  /// notification, without a running session the user is sent to the app.
  /// [input] is the quick log the user picked, if any.
  Future<void> handleAction(String? actionId, String? encodedPayload, [String? input]) async {
    try {
      await _handleAction(actionId, encodedPayload, input);
    } finally {
      // Lets iOS suspend the app again once the notification is up to date
      await _queue;
      await _service.actionHandled();
    }
  }

  Future<void> _handleAction(String? actionId, String? encodedPayload, String? input) async {
    final state = _ref.read(gymStateProvider);
    if (!state.isInitialized) {
      // E.g. iOS started the app in the background just for this action
      await _enqueue(() => _service.showNotLogged(labels));
      return;
    }

    final payload = WorkoutNotificationPayload.decode(encodedPayload);
    final notifier = _ref.read(gymStateProvider.notifier);
    if (payload != null && payload.matches(state)) {
      try {
        switch (actionId) {
          case WORKOUT_NOTIFICATION_ACTION_LOG_SET:
            final key = payload.logSlotKey;
            final config = key == null ? null : state.getSlotPageByKey(key)?.setConfigData;
            if (config == null) {
              break;
            }
            if (input == null) {
              await notifier.logPlannedSet(key!);
            } else {
              // An unknown label is from an outdated notification
              final valuesFrom = quickLogChoices(config, _recentLogs)[input];
              if (valuesFrom != null) {
                await notifier.logPlannedSet(key!, valuesFrom: valuesFrom);
              }
            }
          case WORKOUT_NOTIFICATION_ACTION_SKIP_REST:
            if (state.getSlotEntryPageByIndex()?.key == payload.restSlotKey) {
              notifier.skipRest();
            }
          case WORKOUT_NOTIFICATION_ACTION_EXTEND_REST:
            if (state.getSlotEntryPageByIndex()?.key == payload.restSlotKey) {
              notifier.extendRest(REST_EXTENSION);
            }
        }
      } catch (e) {
        _logger.warning('Notification action $actionId failed: $e');
      }
    }

    // The platform removes the notification on an action
    refresh();
  }
}

const _backgroundStates = {
  AppLifecycleState.hidden,
  AppLifecycleState.paused,
  AppLifecycleState.detached,
};

/// Bootstraps the workout notifications, read once at app start
final workoutNotificationControllerProvider = Provider<WorkoutNotificationController>((ref) {
  final service = ref.read(workoutNotificationServiceProvider);
  final controller = WorkoutNotificationController(ref, service);

  // Nothing to keep in line, and the web has no isolates for the actions
  if (service is NoopWorkoutNotificationService) {
    return controller;
  }
  unawaited(service.initialize(controller.labels));

  // Actions arrive from the background isolate
  final port = ReceivePort();
  IsolateNameServer.removePortNameMapping(WORKOUT_NOTIFICATION_PORT);
  IsolateNameServer.registerPortWithName(port.sendPort, WORKOUT_NOTIFICATION_PORT);
  port.listen((message) {
    final [actionId, payload, input] = message as List;
    unawaited(controller.handleAction(actionId as String?, payload as String?, input as String?));
  });

  // Notifications of an earlier process outlive it. Only cleaned up once the
  // app is really opened: iOS also starts it in the background for an action.
  void cleanUpWhenIdle() {
    if (!ref.read(gymStateProvider).isInitialized) {
      controller.refresh();
    }
  }

  if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
    cleanUpWhenIdle();
  }

  ref.listen(gymStateProvider, (_, _) => controller.update());
  ref.listen(gymModeVisibleProvider, (_, _) => controller.update());
  final lifecycle = AppLifecycleListener(
    onStateChange: (_) => controller.update(),
    onResume: cleanUpWhenIdle,
  );

  ref.onDispose(() {
    lifecycle.dispose();
    IsolateNameServer.removePortNameMapping(WORKOUT_NOTIFICATION_PORT);
    port.close();
  });

  return controller;
});
