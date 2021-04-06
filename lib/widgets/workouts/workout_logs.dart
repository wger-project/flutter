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
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/widgets/workouts/log.dart';

class WorkoutLogs extends StatefulWidget {
  final WorkoutPlan _workoutPlan;
  final _changeMode;
  WorkoutLogs(this._workoutPlan, this._changeMode);

  @override
  _WorkoutLogsState createState() => _WorkoutLogsState();
}

class _WorkoutLogsState extends State<WorkoutLogs> {
  final dayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Weight Log',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              /*
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'This page shows the weight logs belonging to this workout only.'
                  'Click on an exercise to see all the historical data for it.',
                  textAlign: TextAlign.justify,
                ),
              ),
              */
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context)!.logHelpEntries,
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context)!.logHelpEntriesUnits,
                  textAlign: TextAlign.justify,
                ),
              ),
              ElevatedButton(
                child: Text('Back to workout'),
                onPressed: () {
                  widget._changeMode(WorkoutScreenMode.workout);
                },
              ),
              ...widget._workoutPlan.days.map((workoutDay) => DayLogWidget(workoutDay)).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
