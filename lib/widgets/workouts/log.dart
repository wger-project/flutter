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
import 'package:provider/provider.dart';
import 'package:wger/helpers/colors.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/workouts/charts.dart';

class ExerciseLogChart extends StatelessWidget {
  final Exercise _base;
  final DateTime _currentDate;

  const ExerciseLogChart(this._base, this._currentDate);

  @override
  Widget build(BuildContext context) {
    final workoutPlansData = Provider.of<WorkoutPlansProvider>(context, listen: false);
    final workout = workoutPlansData.currentPlan;
    var colors = generateChartColors(1).iterator;

    Future<Map<String, dynamic>> getChartEntries(BuildContext context) async {
      return workoutPlansData.fetchLogData(workout!, _base);
    }

    return FutureBuilder(
      future: getChartEntries(context),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          colors = generateChartColors(snapshot.data!['chart_data'].length).iterator;
        }

        return SizedBox(
          height: 260,
          child: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    LogChartWidgetFl(snapshot.data!, _currentDate),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...snapshot.data!['chart_data'].map((e) {
                          // e is the list of logs with the same reps, so we can just take the
                          // first entry and read the reps from it. Yes, this is an amazingly ugly hack
                          final reps = e.first['reps'];

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
                ),
        );
      },
    );
  }
}

class DayLogWidget extends StatefulWidget {
  final DateTime _date;
  final WorkoutSession? _session;
  final Map<Exercise, List<Log>> _exerciseData;

  const DayLogWidget(this._date, this._exerciseData, this._session);

  @override
  _DayLogWidgetState createState() => _DayLogWidgetState();
}

class _DayLogWidgetState extends State<DayLogWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(
            DateFormat.yMd(Localizations.localeOf(context).languageCode).format(widget._date),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (widget._session != null) const Text('Session data here'),
          ...widget._exerciseData.keys.map((base) {
            final exercise = base.getExercise(Localizations.localeOf(context).languageCode);
            return Column(
              children: [
                if (widget._exerciseData[base]!.isNotEmpty)
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  )
                else
                  Container(),
                ...widget._exerciseData[base]!.map(
                  (log) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(log.singleLogRepTextNoNl),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          showDeleteDialog(
                            context,
                            exercise.name,
                            log,
                            exercise,
                            widget._exerciseData,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: ExerciseLogChart(base, widget._date),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
