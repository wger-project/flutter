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

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rest_timer_notifier.g.dart';

/// What the set timer is currently doing, used to colour the badge.
enum RestTimerMode {
  /// The logged set has no rest time; [RestTimerState.seconds] is the time
  /// elapsed since it was logged.
  countUp,

  /// A rest countdown is in progress; [RestTimerState.seconds] is the time
  /// remaining.
  countDown,

  /// A rest countdown has elapsed; [RestTimerState.seconds] is the overtime
  /// counted up since it hit zero.
  timesUp,
}

/// A snapshot of the gym-mode set timer.
///
/// The timer is single-purpose: it always tracks time relative to the most
/// recently logged set. When that set prescribes a rest time it counts *down*
/// the seconds remaining, then flips to [RestTimerMode.timesUp] once the rest
/// has elapsed; a set with no rest time just counts *up* the time since it was
/// logged.
class RestTimerState {
  final RestTimerMode mode;

  /// Seconds remaining (countdown), overtime (times up) or elapsed (count up).
  final int seconds;

  const RestTimerState({required this.mode, required this.seconds});
}

/// Holds the set timer for gym mode.
///
/// The timer lives in a keepAlive provider rather than in the log page widget
/// so that it keeps running when the user navigates between exercises (the page
/// widget that started it is disposed on auto-advance). The state is `null`
/// until the first set is logged.
@Riverpod(keepAlive: true)
class RestTimer extends _$RestTimer {
  Timer? _timer;

  /// When the most recent set was logged.
  DateTime? _lastSetAt;

  /// Prescribed rest for the most recent set, or `null` to only count up.
  int? _restSeconds;

  @override
  RestTimerState? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  /// Record that a set was just logged and (re)start the timer.
  ///
  /// A [restSeconds] greater than zero counts down from that value and then
  /// counts up once it reaches zero; a null or non-positive value simply counts
  /// up the time elapsed since the set was logged.
  void logSet({int? restSeconds}) {
    _lastSetAt = DateTime.now();
    _restSeconds = (restSeconds != null && restSeconds > 0) ? restSeconds : null;
    _tick();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final since = _lastSetAt;
    if (since == null) {
      state = null;
      return;
    }
    final elapsed = DateTime.now().difference(since).inSeconds;
    final rest = _restSeconds;
    if (rest == null) {
      state = RestTimerState(mode: RestTimerMode.countUp, seconds: elapsed);
    } else if (elapsed < rest) {
      state = RestTimerState(mode: RestTimerMode.countDown, seconds: rest - elapsed);
    } else {
      state = RestTimerState(mode: RestTimerMode.timesUp, seconds: elapsed - rest);
    }
  }

  /// Stop the timer and clear the displayed value.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _lastSetAt = null;
    _restSeconds = null;
    state = null;
  }
}
