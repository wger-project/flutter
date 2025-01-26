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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/colors.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/widgets/measurements/charts.dart';

class SessionInfo extends StatelessWidget {
  final WorkoutSession _session;

  const SessionInfo(this._session);

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            i18n.workoutSession,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            DateFormat.yMd(Localizations.localeOf(context).languageCode).format(_session.date),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8.0),
          _buildInfoRow(
            context,
            i18n.timeStart,
            _session.timeStart != null
                ? MaterialLocalizations.of(context).formatTimeOfDay(_session.timeStart!)
                : '-/-',
          ),
          _buildInfoRow(
            context,
            i18n.timeEnd,
            _session.timeEnd != null
                ? MaterialLocalizations.of(context).formatTimeOfDay(_session.timeEnd!)
                : '-/-',
          ),
          _buildInfoRow(
            context,
            i18n.impression,
            _session.impressionAsString,
          ),
          _buildInfoRow(
            context,
            i18n.notes,
            _session.notes.isNotEmpty ? _session.notes : '-/-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

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
        // TODO: why does this not work??? 😫
        // LogChartWidgetFl(_logs, _selectedDate),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ..._logs.keys.map((reps) {
              colors.moveNext();
              return Indicator(
                color: colors.current,
                text: formatNum(reps).toString(),
                isSquare: false,
              );
            }),
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

  final WorkoutSession _session;
  final Map<Exercise, List<Log>> _exerciseMap;

  const DayLogWidget(this._date, this._exerciseMap, this._session, this._routine);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SessionInfo(_session),
          ..._exerciseMap.keys.map((exercise) {
            final translation =
                exercise.getTranslation(Localizations.localeOf(context).languageCode);
            return Column(
              children: [
                if (_exerciseMap[exercise]!.isNotEmpty)
                  Text(
                    translation.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  )
                else
                  Container(),
                ..._exerciseMap[exercise]!.map(
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
                            _exerciseMap,
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
