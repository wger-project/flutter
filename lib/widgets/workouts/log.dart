/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/workouts/charts.dart';

class ExerciseLog extends StatelessWidget {
  Exercise _exercise;
  ExerciseLog(this._exercise);

  @override
  Widget build(BuildContext context) {
    final _workoutPlansData = Provider.of<WorkoutPlans>(context, listen: false);
    final _workout = _workoutPlansData.currentPlan;

    Future<dynamic> _getChartEntries(BuildContext context) async {
      return await _workoutPlansData.fetchLogData(_workout, _exercise);
    }

    return Column(
      children: [
        Text(_exercise.name),
        FutureBuilder(
          future: _getChartEntries(context),
          builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : Container(
                  height: 120,
                  child: LogChartWidget(snapshot.data),
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Amount'),
            Text('Unit'),
            Text('Weight'),
            Text('Unit'),
            Text('RiR'),
          ],
        ),
      ],
    );
  }
}

class DayLogWidget extends StatelessWidget {
  final Day _day;

  DayLogWidget(this._day);

  Widget getSetRow(Set set) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Expanded(
          child: Column(
            children: [
              ...set.exercises.map((exercise) => ExerciseLog(exercise)).toList(),
              Divider(),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(
            _day.description,
            style: Theme.of(context).textTheme.headline5,
          ),
          ..._day.sets.map((set) => getSetRow(set)).toList(),
          OutlinedButton(
            child: Text('Add logs to this day'),
            onPressed: () {},
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 10.0))
        ],
      ),
    );
  }
}
