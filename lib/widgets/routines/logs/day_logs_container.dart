/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020, 2025 wger Team
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
import 'package:wger/helpers/date.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/models/workouts/routine.dart';

import 'exercise_log_chart.dart';
import 'muscle_groups.dart';
import 'session_info.dart';

class DayLogWidget extends StatelessWidget {
  final DateTime _date;
  final Routine _routine;

  const DayLogWidget(this._date, this._routine);

  @override
  Widget build(BuildContext context) {
    final sessionApi = _routine.sessions.firstWhere(
      (sessionApi) => sessionApi.session.date.isSameDayAs(_date),
    );
    final exercises = sessionApi.exercises;

    return Column(
      spacing: 10,
      children: [
        Card(child: SessionInfo(sessionApi.session)),
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
                                Text(log.repTextNoNl(context)),
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
