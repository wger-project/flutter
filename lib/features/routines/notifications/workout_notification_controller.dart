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
import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/app_settings_notifier.dart';
import 'package:wger/features/routines/notifications/workout_notification_content.dart';
import 'package:wger/features/routines/notifications/workout_notification_service.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
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

/// Keeps the platform notifications in line with the desired target
class WorkoutNotificationController {
  final _logger = Logger('WorkoutNotificationController');
  final WorkoutNotificationService _service;

  var _shown = WorkoutNotificationTarget.none;
  Future<void> _queue = Future.value();

  WorkoutNotificationController(this._service);

  /// Applies [target], in call order. Unchanged targets cause no platform calls.
  Future<void> apply(WorkoutNotificationTarget target, WorkoutNotificationLabels labels) {
    return _queue = _queue
        .then((_) => _apply(target, labels))
        .catchError((Object e) => _logger.warning('Could not update the notification: $e'));
  }

  Future<void> _apply(WorkoutNotificationTarget target, WorkoutNotificationLabels labels) async {
    if (target == _shown) {
      return;
    }
    _shown = target;

    // Alarm and controls share one notification, so every change starts over
    await _service.cancelAll();
    if (target.alarm != null) {
      await _service.scheduleRestAlarm(target.alarm!, labels);
    }
    if (target.controls != null) {
      await _service.showControls(target.controls!, labels);
    }
  }
}

/// The locale the app renders in, also without a BuildContext
Locale _appLocale(Ref ref) {
  final userLocale = ref.read(appSettingsProvider).value?.userLocale;
  return userLocale ??
      basicLocaleListResolution(
        PlatformDispatcher.instance.locales,
        AppLocalizations.supportedLocales,
      );
}

const _backgroundStates = {
  AppLifecycleState.hidden,
  AppLifecycleState.paused,
  AppLifecycleState.detached,
};

/// Derives the workout notifications from the gym state. While gym mode is on
/// screen there are none, the screen itself shows the rest.
final workoutNotificationControllerProvider = Provider<WorkoutNotificationController>((ref) {
  final service = ref.read(workoutNotificationServiceProvider);
  final controller = WorkoutNotificationController(service);

  void update() {
    final state = ref.read(gymStateProvider);
    final inForeground = !_backgroundStates.contains(WidgetsBinding.instance.lifecycleState);
    final locale = _appLocale(ref);
    final i18n = lookupAppLocalizations(locale);

    final target = inForeground && ref.read(gymModeVisibleProvider)
        ? WorkoutNotificationTarget.none
        : buildWorkoutNotification(
            state,
            now: clock.now(),
            i18n: i18n,
            languageCode: locale.languageCode,
            withControls: service.supportsControls && state.showWorkoutNotification,
          );
    unawaited(controller.apply(target, WorkoutNotificationLabels.of(i18n)));
  }

  ref.listen(gymStateProvider, (_, _) => update());
  ref.listen(gymModeVisibleProvider, (_, _) => update());
  final lifecycle = AppLifecycleListener(onStateChange: (_) => update());
  ref.onDispose(lifecycle.dispose);

  return controller;
});
