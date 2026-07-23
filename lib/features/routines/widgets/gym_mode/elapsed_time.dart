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

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';

/// Shows the time elapsed since the start of the current workout.
///
/// Reads the start time from the shared gym state so that the value is
/// consistent across all gym mode pages and with the times logged in the
/// workout session.
class ElapsedWorkoutTimer extends ConsumerStatefulWidget {
  const ElapsedWorkoutTimer({super.key});

  /// Formats a duration as `m:ss`, or `h:mm:ss` from one hour onwards
  static String format(Duration elapsed) {
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);
    final seconds = elapsed.inSeconds.remainder(60);

    final secondsStr = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$secondsStr';
    }
    return '$minutes:$secondsStr';
  }

  @override
  ConsumerState<ElapsedWorkoutTimer> createState() => _ElapsedWorkoutTimerState();
}

class _ElapsedWorkoutTimerState extends ConsumerState<ElapsedWorkoutTimer> {
  late Timer _uiTimer;

  @override
  void initState() {
    super.initState();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // ignore: no-empty-block, avoid-empty-setstate
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _uiTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutStart = ref.watch(gymStateProvider).workoutStart;
    final elapsed = clock.now().difference(workoutStart);
    final style = Theme.of(context).textTheme.bodySmall;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: 16, color: style?.color),
        const SizedBox(width: 2),
        Text(
          ElapsedWorkoutTimer.format(elapsed.isNegative ? Duration.zero : elapsed),
          style: style,
        ),
      ],
    );
  }
}
