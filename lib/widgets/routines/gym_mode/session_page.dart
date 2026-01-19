/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/date.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/gym_state.dart';
import 'package:wger/providers/workout_session.dart';
import 'package:wger/widgets/routines/forms/session.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';

class SessionPage extends ConsumerStatefulWidget {
  final PageController _controller;

  const SessionPage(this._controller);

  @override
  ConsumerState<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends ConsumerState<SessionPage> {
  late Future<void> _initData;
  List<WorkoutSession> sessions = [];

  @override
  void initState() {
    super.initState();
    _initData = _reloadRoutineData();
  }

  Future<void> _reloadRoutineData() async {
    sessions = await ref.read(workoutSessionProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final gymState = ref.read(gymStateProvider);

    return Column(
      children: [
        NavigationHeader(i18n.workoutSession, widget._controller),
        Expanded(
          child: FutureBuilder<void>(
            future: _initData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final session = sessions.firstWhere(
                  (s) => s.date.isSameDayAs(clock.now()) && s.routineId == gymState.routine.id,
                  orElse: () => WorkoutSession(
                    dayId: gymState.dayId,
                    date: clock.now(),
                    routineId: gymState.routine.id,
                    timeStart: gymState.startTime,
                    timeEnd: TimeOfDay.fromDateTime(clock.now()),
                  ),
                );

                return Column(
                  children: [
                    Expanded(child: Container()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SessionForm(
                        gymState.routine.id!,
                        onSaved: () => widget._controller.nextPage(
                          duration: DEFAULT_ANIMATION_DURATION,
                          curve: DEFAULT_ANIMATION_CURVE,
                        ),
                        session: session,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
        NavigationFooter(widget._controller),
      ],
    );
  }
}
