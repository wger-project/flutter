/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/date.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/widgets/routines/forms/session.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';

class SessionPage extends ConsumerWidget {
  final PageController _controller;

  const SessionPage(this._controller);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gymStateProvider);

    final session = state.routine.sessions
        .map((sessionApi) => sessionApi.session)
        .firstWhere(
          (session) => session.date.isSameDayAs(clock.now()),
          orElse: () => WorkoutSession(
            dayId: state.dayId,
            routineId: state.routine.id,
            impression: DEFAULT_IMPRESSION,
            date: clock.now(),
            timeStart: state.startTime,
            timeEnd: TimeOfDay.fromDateTime(clock.now()),
          ),
        );

    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).workoutSession,
          _controller,
        ),
        Expanded(child: Container()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SessionForm(
            state.routine.id,
            onSaved: () => _controller.nextPage(
              duration: DEFAULT_ANIMATION_DURATION,
              curve: DEFAULT_ANIMATION_CURVE,
            ),
            session: session,
          ),
        ),
        NavigationFooter(_controller),
      ],
    );
  }
}
