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
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/date.dart';
import 'package:wger/core/keys.dart';
import 'package:wger/core/network/auth_notifier.dart';
import 'package:wger/core/network/auth_state.dart';
import 'package:wger/core/shared_preferences.dart';
import 'package:wger/features/routines/models/day_data.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/models/set_config_data.dart';
import 'package:wger/features/routines/models/workout_progress.dart';
import 'package:wger/features/routines/notifications/workout_notification_content.dart';
import 'package:wger/features/routines/notifications/workout_notification_controller.dart';
import 'package:wger/features/routines/providers/gym_state.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/providers/routines_notifier.dart';
import 'package:wger/features/routines/providers/workout_session_notifier.dart';
import 'package:wger/features/routines/screens/gym_mode.dart';
import 'package:wger/features/routines/screens/routine_list_screen.dart';

const _channel = MethodChannel('de.wger.flutter/workout-shortcuts');

Never _fail(String message) => throw PlatformException(code: 'workout', message: message);

/// The only actions that need the navigator. All others also run while iOS
/// keeps wger in the background, where no frames are drawn and
/// `endOfFrame` would never complete.
const SHORTCUT_NAVIGATION_METHODS = {'start', 'finish', 'plans'};

/// The set that is up next as the notifications describe it: during a rest
/// countdown the set after it, else the current page. Null without a workout.
({String title, String body})? shortcutUpNext(WorkoutNotificationTarget target) {
  final alarm = target.alarm;
  if (alarm != null) {
    return (title: alarm.title, body: alarm.body);
  }
  final controls = target.controls;
  return controls == null ? null : (title: controls.title, body: controls.body);
}

/// Whole seconds until [restEndsAt], rounded up, 0 if over or none
int shortcutRestRemaining(DateTime? restEndsAt, DateTime now) {
  if (restEndsAt == null || !restEndsAt.isAfter(now)) {
    return 0;
  }
  return (restEndsAt.difference(now).inMilliseconds / 1000).ceil();
}

/// The values "log set with values" logs: the planned ones of [planned], with
/// [repetitions] and [weight] instead if given
Log shortcutLogValues(SetConfigData planned, {num? repetitions, num? weight}) =>
    Log.fromSetConfigData(planned).copyWith(repetitions: repetitions, weight: weight);

/// Index a workout by the local calendar day or by its explicit plan label.
DayData? shortcutDay(Iterable<DayData> days, String name, DateTime today) {
  final label = name.trim().toLowerCase();
  return days.firstWhereOrNull((entry) {
    final day = entry.day;
    if (day == null || day.id == null || day.isRest || entry.slots.isEmpty) {
      return false;
    }
    return label.isEmpty ? entry.date.isSameDayAs(today) : day.name.trim().toLowerCase() == label;
  });
}

final workoutShortcutsProvider = Provider<void>((ref) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }
  var busy = false;
  _channel.setMethodCallHandler((call) async {
    if (busy) {
      _fail('Another wger action is running. Try again afterwards.');
    }
    busy = true;
    try {
      final result = await _perform(ref, call);
      // Also in the background: the Live Activity shows the change before iOS
      // suspends wger again
      await ref
          .read(workoutNotificationControllerProvider)
          .liveActivityIdle
          .timeout(const Duration(seconds: 3), onTimeout: () {});
      return result;
    } on PlatformException {
      rethrow;
    } catch (_) {
      _fail('The action failed. Check your routine and the connection in wger.');
    } finally {
      busy = false;
    }
  });
  unawaited(
    _channel.invokeMethod<void>('ready').catchError((Object e) {
      if (e is! MissingPluginException) {
        throw e;
      }
    }),
  );
  ref.onDispose(() => _channel.setMethodCallHandler(null));
});

Future<String> _perform(Ref ref, MethodCall call) async {
  final auth = await ref.read(authProvider.future);
  if (auth.status != AuthStatus.loggedIn) {
    _fail('Open wger and log in.');
  }
  NavigatorState? nav;
  if (SHORTCUT_NAVIGATION_METHODS.contains(call.method)) {
    await WidgetsBinding.instance.endOfFrame;
    nav = navigatorKey.currentState;
    if (nav == null) {
      _fail('The gym mode is not ready yet.');
    }
  }
  if (call.method == 'plans') {
    unawaited(nav!.pushNamed<void>(RoutineListScreen.routeName));
    return 'Routines opened';
  }

  final notifier = ref.read(gymStateProvider.notifier);
  var state = ref.read(gymStateProvider);
  final now = clock.now();
  final arguments = call.arguments as Map<Object?, Object?>;
  final name = arguments['day'] as String? ?? '';
  if (!state.isInitialized || state.validUntil.isBefore(now)) {
    final raw = await PreferenceHelper.asyncPref.getString(PREFS_WORKOUT_PROGRESS);
    WorkoutProgress? saved;
    int? routineId;
    if (raw != null) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final previous = WorkoutProgress.fromJson(data);
      if (previous.validUntil.isAfter(now) && previous.currentPageKey != 'start') {
        saved = previous;
        routineId = data['routineId'] as int?;
      }
    }
    if (saved == null && call.method != 'start') {
      return _inactive(call.method);
    }
    final routines = await ref.read(routinesRiverpodProvider.future);
    var routine = routineId == null ? routines.currentRoutine : routines.findByIdOrNull(routineId);
    if (routine == null || routine.id == null) {
      _fail('No matching routine available.');
    }
    if (!routine.isHydrated) {
      routine = await ref
          .read(routinesRiverpodProvider.notifier)
          .fetchAndSetRoutineFull(routine.id!);
    }
    final previous = saved;
    final day = previous == null
        ? shortcutDay(routine.dayDataCurrentIterationGym, name, now)
        : routine.dayDataGym.firstWhereOrNull(
            (d) => d.day?.id == previous.dayId && d.iteration == previous.iteration,
          );
    if (day == null) {
      if (saved != null) {
        _fail('Open the last used training day in wger.');
      }
      _fail('No matching training day. Enter its name from your routine in the shortcut.');
    }
    if (ref.read(authProvider).value?.status != AuthStatus.loggedIn) {
      _fail('Log in to wger.');
    }
    await notifier.open(routine, day.day!.id!, day.iteration);
    state = ref.read(gymStateProvider);
    if ((call.method == 'log' || call.method == 'logValues') &&
        state.getSlotEntryPageByIndex()?.type == SlotPageType.log) {
      await notifier.startNewEntry();
    }
  }

  if (call.method == 'start') {
    if (name.trim().isNotEmpty &&
        state.dayDataGym.day!.name.trim().toLowerCase() != name.trim().toLowerCase()) {
      _fail('Another training day is already open.');
    }
    if (state.currentPage == 0) {
      notifier.startWorkout();
      notifier.setCurrentPage(1);
    }
  } else if (state.currentPage == 0) {
    return _inactive(call.method, notStarted: true);
  }

  final page = state.getSlotEntryPageByIndex();
  final restEndsAt = state.restEndsAt;
  WorkoutNotificationTarget describe() =>
      ref.read(workoutNotificationControllerProvider).describe();
  switch (call.method) {
    case 'start':
    case 'finish':
      if (call.method == 'finish') {
        notifier.setCurrentPage(
          state.pages.firstWhere((p) => p.type == PageType.session).pageIndex,
        );
      }
      if (ref.read(gymModeVisibleProvider)) {
        nav!.popUntil((route) => route.settings.name == GymModeScreen.routeName || route.isFirst);
      } else {
        unawaited(
          nav!.pushNamed<void>(
            GymModeScreen.routeName,
            arguments: GymModeArguments(
              state.routine.id!,
              state.dayId,
              state.iteration,
              alreadyOpened: true,
            ),
          ),
        );
        await WidgetsBinding.instance.endOfFrame;
      }
      return call.method == 'finish'
          ? 'Summary opened. Tap save to finish.'
          : state.dayDataGym.day!.name;
    case 'saveFinish':
      final entries = state.progress.values.where((p) => p.done).map((p) => p.loggedEntry);
      final ids = entries.map((entry) => entry?.sessionId).toSet();
      if (ids.length > 1 || ids.contains(null)) {
        _fail('Check the logged sets with "Open workout summary".');
      }
      await ref.read(workoutSessionProvider.future);
      final saved = await ref
          .read(workoutSessionProvider.notifier)
          .finishGymSession(
            routineId: state.routine.id!,
            dayId: state.dayId,
            start: state.workoutStart,
            end: now,
            sessionId: ids.firstOrNull,
          );
      if (!saved) {
        _fail('Check the session with "Open workout summary".');
      }
      // Without frames in the background, the route changes still take effect
      final navigator = navigatorKey.currentState;
      if (navigator != null && ref.read(gymModeVisibleProvider)) {
        navigator.popUntil(
          (route) => route.settings.name == GymModeScreen.routeName || route.isFirst,
        );
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
      notifier.clear();
      return now.toUtc().toIso8601String();
    case 'log':
      if (page?.type != SlotPageType.log || !await notifier.logPlannedSet(page!.key)) {
        _fail('Open an unsaved set with complete values.');
      }
      return 'Set logged';
    case 'logValues':
      final logPage = page?.type == SlotPageType.log ? page : null;
      final config = logPage?.setConfigData;
      if (logPage == null || config == null || state.progressOf(logPage.key).done) {
        _fail('Open an unsaved set.');
      }
      final repetitions = arguments['repetitions'] as num?;
      final weight = arguments['weight'] as num?;
      if ((repetitions != null && (repetitions <= 0 || repetitions > 1000)) ||
          (weight != null && (weight < 0 || weight > 10000))) {
        _fail('Invalid repetitions or weight.');
      }
      final values = shortcutLogValues(config, repetitions: repetitions, weight: weight);
      if (!await notifier.logPlannedSet(logPage.key, valuesFrom: values)) {
        _fail('The set needs repetitions and weight. Enter them in the shortcut.');
      }
      return 'Set logged';
    case 'skip':
      if (page?.type != SlotPageType.timer) {
        _fail('No rest is running.');
      }
      notifier.skipRest();
      return 'Rest skipped';
    case 'extend':
      final seconds = arguments['seconds'] as int? ?? 30;
      if (seconds < 1 || seconds > 1800) {
        _fail('Choose between 1 and 1800 seconds.');
      }
      if (state.restEndsAt == null) {
        _fail('No rest countdown is running.');
      }
      notifier.extendRest(Duration(seconds: seconds));
      return 'Rest extended';
    case 'status':
      final upNext = shortcutUpNext(describe());
      return jsonEncode({
        'active': true,
        'routine': state.routine.name,
        'day': state.dayDataGym.day!.name,
        'startedAt': state.workoutStart.toUtc().toIso8601String(),
        'restEndsAt': restEndsAt?.toUtc().toIso8601String(),
        'completedSets': state.progress.values.where((p) => p.done).length,
        'exercise': upNext?.title,
        'detail': upNext?.body,
        'resting': page?.type == SlotPageType.timer,
        'restRemaining': shortcutRestRemaining(restEndsAt, now),
      });
    case 'restEnd':
      if (restEndsAt == null || !restEndsAt.isAfter(now)) {
        _fail('No rest is running.');
      }
      return restEndsAt.millisecondsSinceEpoch.toString();
    case 'restRemaining':
      return shortcutRestRemaining(restEndsAt, now).toString();
    case 'next':
      final next = shortcutUpNext(describe());
      if (next == null) {
        _fail('No workout is running.');
      }
      return [next.title, next.body].where((text) => text.isNotEmpty).join(' · ');
    default:
      _fail('Unknown workout action.');
  }
}

/// The answer without a running workout: queries say so, actions fail
String _inactive(String method, {bool notStarted = false}) {
  switch (method) {
    case 'status':
      return jsonEncode({'active': false});
    case 'restRemaining':
      return '0';
    case 'restEnd':
      _fail('No rest is running.');
    default:
      _fail(notStarted ? 'Start the workout first.' : 'No workout is running.');
  }
}
