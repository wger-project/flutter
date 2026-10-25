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
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/date.dart';
import 'package:wger/core/widgets/async_value_widget.dart';
import 'package:wger/features/routines/models/session.dart';
import 'package:wger/features/routines/providers/gym_state_notifier.dart';
import 'package:wger/features/routines/providers/workout_session_notifier.dart';
import 'package:wger/features/routines/widgets/forms/session.dart';
import 'package:wger/features/routines/widgets/gym_mode/navigation.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class SessionPage extends ConsumerStatefulWidget {
  final PageController _controller;

  const SessionPage(this._controller);

  @override
  ConsumerState<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends ConsumerState<SessionPage> {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final gymState = ref.read(gymStateProvider);

    return Column(
      children: [
        NavigationHeader(i18n.workoutSession, widget._controller),
        Expanded(
          child: AsyncValueWidget<List<WorkoutSession>>(
            value: ref.watch(workoutSessionProvider),
            loggerName: 'SessionPage',
            data: (sessions) {
              final now = clock.now();
              final ours = sessions.where((s) => s.routineId == gymState.routine.id);

              // A session that is still running wins over one that merely shares
              // a calendar day, because a workout can cross midnight. The day is
              // still the fallback, so an already finished one stays editable.
              final found =
                  ours.firstWhereOrNull(
                    (s) =>
                        s.datetimeEnd == null &&
                        now.difference(s.datetimeStart) <= sessionMaxDuration,
                  ) ??
                  ours.firstWhereOrNull((s) => s.datetimeStart.isSameDayAs(now)) ??
                  WorkoutSession(
                    dayId: gymState.dayId,
                    datetimeStart: gymState.workoutStart,
                    routineId: gymState.routine.id,
                  );

              // Prefill missing times. A session may have been created lazily
              // while logging sets (without times), so fall back to the gym
              // session's start and the current time.
              // A session created lazily while logging has no end yet; prefill
              // the current time so the form opens on a complete interval.
              final session = found.copyWith(datetimeEnd: found.datetimeEnd ?? now);

              return Column(
                children: [
                  Expanded(child: Container()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SessionForm(
                      gymState.routine.id,
                      onSaved: () => widget._controller.nextPage(
                        duration: DEFAULT_ANIMATION_DURATION,
                        curve: DEFAULT_ANIMATION_CURVE,
                      ),
                      session: session,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        NavigationFooter(widget._controller),
      ],
    );
  }
}
