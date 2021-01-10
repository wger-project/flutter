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
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/screens/workout_plan_screen.dart';

class GymMode extends StatefulWidget {
  final WorkoutPlan _workoutPlan;
  final _changeMode;
  GymMode(this._workoutPlan, this._changeMode);

  @override
  _GymModeState createState() => _GymModeState();
}

class _GymModeState extends State<GymMode> {
  final dayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Gym mode',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                widget._workoutPlan.description,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            //...widget._workoutPlan.days.map((workoutDay) => WorkoutDayWidget(workoutDay)).toList(),
            Column(
              children: [
                ElevatedButton(
                  child: Text('Open workout'),
                  onPressed: () {
                    widget._changeMode(WorkoutScreenMode.workout);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
