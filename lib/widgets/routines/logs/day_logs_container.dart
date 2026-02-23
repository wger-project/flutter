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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/helpers/date.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/trophies.dart';

import '../gym_mode/summary.dart';
import 'exercise_log_chart.dart';
import 'muscle_groups.dart';
import 'session_info.dart';

class DayLogWidget extends ConsumerWidget {
  final DateTime _date;
  final Routine _routine;

  const DayLogWidget(this._date, this._routine);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final trophyState = ref.read(trophyStateProvider);

    final sessionApi = _routine.sessions.firstWhere(
      (sessionApi) => sessionApi.session.date.isSameDayAs(_date),
    );
    final exercises = sessionApi.exercises;

    final prTrophies = trophyState.prTrophies
        .where((t) => t.contextData?.sessionId == sessionApi.session.id)
        .toList();

    return Column(
      spacing: 10,
      children: [
        Card(child: SessionInfo(sessionApi.session)),
        if (prTrophies.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: InfoCard(
              title: i18n.personalRecords,
              value: prTrophies.length.toString(),
              color: theme.colorScheme.tertiaryContainer,
            ),
          ),
        MuscleGroupsCard(sessionApi.logs),
        Column(
          spacing: 10,
          children: [
            ...exercises.map((exercise) {
              final translation = exercise.getTranslation(
                Localizations.localeOf(context).languageCode,
              );
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        translation.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ...sessionApi.logs
                          .where((l) => l.exerciseId == exercise.id)
                          .map(
                            (log) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (prTrophies.any((t) => t.contextData?.logId == log.id))
                                      Icon(
                                        Icons.emoji_events,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                    Text(log.repTextNoNl(context)),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  key: ValueKey('delete-log-${log.id}'),
                                  onPressed: () {
                                    showDeleteDialog(context, translation.name, log);
                                  },
                                ),
                              ],
                            ),
                          ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ExerciseLogChart(
                          _routine.groupLogsByRepetition(
                            logs: _routine.filterLogsByExercise(exercise.id!),
                            filterNullReps: true,
                            filterNullWeights: true,
                          ),
                          _date,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
