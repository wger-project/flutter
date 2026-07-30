/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/widgets/gym_mode/gym_mode.dart';
import 'package:wger/features/routines/widgets/gym_mode/leave_workout_dialog.dart';

class GymModeArguments {
  final int routineId;
  final int dayId;
  final int iteration;

  const GymModeArguments(this.routineId, this.dayId, this.iteration);
}

class GymModeScreen extends ConsumerWidget {
  const GymModeScreen();

  static const routeName = '/gym-mode';

  /// Leaves gym mode, but only if the user confirms it
  Future<void> _confirmAndLeave(BuildContext context) async {
    if (await confirmLeaveWorkout(context) && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)!.settings.arguments as GymModeArguments;
    final workoutInProgress = ref.watch(
      gymStateProvider.select((state) => state.isWorkoutInProgress),
    );

    return PopScope(
      // While a workout is running, leaving is always an explicit choice: the
      // iOS back swipe and the Android back gesture are easy to trigger by
      // accident (e.g. when reaching for a podcast app mid-set), and popping
      // the route drops the session, the elapsed timer and the progress
      // through the workout.
      canPop: !workoutInProgress,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _confirmAndLeave(context);
      },
      child: Scaffold(
        // backgroundColor: Theme.of(context).cardColor,
        // primary: false,
        body: SafeArea(
          child: WidescreenWrapper(child: GymMode(args)),
        ),
      ),
    );
  }
}
