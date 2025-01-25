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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/colors.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/routines/charts.dart';

class ExerciseLogChart extends StatelessWidget {
  final Map<num, List<Log>> _logs;
  final DateTime _selectedDate;

  const ExerciseLogChart(this._logs, this._selectedDate);

  @override
  Widget build(BuildContext context) {
    final colors = generateChartColors(_logs.keys.length).iterator;

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        LogChartWidgetFl(_logs, _selectedDate),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ..._logs.keys.map((reps) {
              // e is the list of logs with the same reps, so we can just take the
              // first entry and read the reps from it. Yes, this is an amazingly ugly hack
              // final reps = log.repetitions;

              colors.moveNext();
              return Indicator(
                color: colors.current,
                text: reps.toString(),
                isSquare: false,
              );
            }).toList(),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

class DayLogWidget extends StatelessWidget {
  final DateTime _date;
  final Routine _routine;

  final WorkoutSession? _session;
  final Map<Exercise, List<Log>> _exerciseData;

  const DayLogWidget(this._date, this._exerciseData, this._session, this._routine);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(
            DateFormat.yMd(Localizations.localeOf(context).languageCode).format(_date),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (_session != null) const Text('Session data here'),
          ..._exerciseData.keys.map((exercise) {
            final translation =
                exercise.getTranslation(Localizations.localeOf(context).languageCode);
            return Column(
              children: [
                if (_exerciseData[exercise]!.isNotEmpty)
                  Text(
                    translation.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  )
                else
                  Container(),
                ..._exerciseData[exercise]!.map(
                  (log) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(log.singleLogRepTextNoNl),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDeleteDialog(
                            context,
                            translation.name,
                            log,
                            translation,
                            _exerciseData,
                          );
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
                    ),
                    _date,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
