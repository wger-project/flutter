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

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:wger/features/routines/notifications/workout_notification_content.dart';
import 'package:wger/features/routines/providers/gym_state.dart';

const WORKOUT_LIVE_ACTIVITY_CHANNEL = MethodChannel('de.wger.flutter/rest_activity');

/// What the iOS Live Activity (Lock Screen and Dynamic Island) shows for the
/// workout, null for none. Times are seconds since the epoch.
///
/// Follows [target], the ongoing notification, so both always say the same.
/// During a countdown the `after*` fields are what the activity switches to
/// once the rest is over: iOS marks it stale then, without the app running.
Map<String, Object?>? workoutActivityContent(
  GymModeState state,
  WorkoutNotificationTarget target, {
  required WorkoutNotificationLabels labels,
  required DateTime now,
}) {
  final controls = target.controls;
  // Set pages are found by their slot pages, start, session and summary directly
  final page =
      state.getPageByIndex() ??
      state.pages.firstWhereOrNull((p) => p.pageIndex == state.currentPage);
  if (!state.isInitialized || controls == null || page == null || page.type == PageType.start) {
    return null;
  }

  double seconds(DateTime at) => at.millisecondsSinceEpoch / 1000;
  final restStart = state.restStartedAt;
  final restEnd = state.restEndsAt;
  final countdown = restStart != null && restEnd != null && restEnd.isAfter(now);
  final countUp = restStart != null && restEnd == null;
  final alarm = countdown ? target.alarm : null;

  return {
    'title': controls.title,
    'body': controls.body,
    'subtitle': controls.subtitle,
    'resting': countdown || countUp,
    'workoutStart': seconds(state.workoutStart),
    // Counts down to `timerTo` if given, else up from `timerFrom`
    'timerFrom': seconds(countdown || countUp ? restStart : state.workoutStart),
    'timerTo': countdown ? seconds(restEnd) : null,
    'canLog': controls.canLogSet,
    'canSkip': controls.canSkipRest,
    'canExtend': controls.canExtendRest,
    'afterTitle': alarm?.title,
    'afterBody': alarm?.body,
    'afterSubtitle': alarm?.subtitle,
    'afterCanLog': alarm?.canLogSet ?? false,
    'afterCanExtend': alarm?.canExtendRest ?? false,
    // The buttons carry it to the app like a notification action
    'payload': (alarm?.payload ?? controls.payload).encode(),
    'logLabel': labels.logSet,
    'skipLabel': labels.skipRest,
    'extendLabel': labels.extendRest,
  };
}

/// Mirrors the workout in one Live Activity, from the first set to the end.
///
/// One for the whole workout rather than one per rest: iOS only lets an app
/// start a Live Activity in the foreground, but update it in the background,
/// e.g. after a set logged from a notification or a shortcut.
class WorkoutLiveActivity {
  final _logger = Logger('WorkoutLiveActivity');
  Future<void> _queue = Future.value();

  /// The content last sent, null if unknown. Starts unknown so that the first
  /// update also ends what an earlier process may have left on screen.
  String? _shown;

  bool get _supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Resolves once the platform has the latest update
  Future<void> get idle => _queue;

  /// Hands the buttons of the activity to [onAction], with the action id and
  /// payload of a notification action
  void listen(Future<void> Function(String action, String payload) onAction) {
    if (!_supported) {
      return;
    }
    WORKOUT_LIVE_ACTIVITY_CHANNEL.setMethodCallHandler((call) async {
      if (call.method != 'action') {
        throw MissingPluginException();
      }
      final arguments = call.arguments as Map<Object?, Object?>;
      final action = arguments['action'] as String?;
      final payload = arguments['payload'] as String?;
      if (action == null || payload == null) {
        throw PlatformException(code: 'INVALID_ARGUMENT', message: 'Missing action or payload');
      }
      await onAction(action, payload);
      // The app may be suspended right after the reply
      await _queue;
      return null;
    });
  }

  void update(
    GymModeState state,
    WorkoutNotificationTarget target, {
    required bool visible,
    required WorkoutNotificationLabels labels,
    required DateTime now,
  }) {
    if (!_supported) {
      return;
    }
    final content = visible
        ? workoutActivityContent(state, target, labels: labels, now: now)
        : null;
    final key = content == null ? '' : jsonEncode(content);
    if (key == _shown) {
      return;
    }
    _shown = key;
    _queue = _queue.then((_) async {
      try {
        await WORKOUT_LIVE_ACTIVITY_CHANNEL.invokeMethod<void>(
          content == null ? 'end' : 'sync',
          content,
        );
      } on MissingPluginException {
        _shown = null;
      } on PlatformException catch (error) {
        // E.g. started in the background: the next update tries again
        _shown = null;
        _logger.warning('Live Activity unavailable: ${error.code}');
      }
    });
  }
}
