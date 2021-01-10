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
import 'package:provider/provider.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/workouts/workout_logs.dart';
import 'package:wger/widgets/workouts/workout_plan_detail.dart';

enum WorkoutScreenMode {
  workout,
  log,
  gym,
}

class WorkoutPlanScreen extends StatefulWidget {
  static const routeName = '/workout-plan-detail';

  @override
  _WorkoutPlanScreenState createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  WorkoutScreenMode _mode = WorkoutScreenMode.workout;

  _changeMode(WorkoutScreenMode newMode) {
    setState(() {
      _mode = newMode;
    });
  }

  Future<WorkoutPlan> _loadWorkoutPlanDetail(BuildContext context, int workoutId) async {
    var workout =
        await Provider.of<WorkoutPlans>(context, listen: false).fetchAndSetFullWorkout(workoutId);
    return workout;
  }

  Widget getAppBar(WorkoutPlan plan) {
    return AppBar(
      title: Text(plan.description),
      actions: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text("Would open options"),
                actions: [
                  TextButton(
                    child: Text(
                      "Cancel",
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget getBody(WorkoutPlan plan) {
    switch (_mode) {
      case WorkoutScreenMode.workout:
        return WorkoutPlanDetail(plan, _changeMode);
        break;
      case WorkoutScreenMode.log:
        return WorkoutLogs(plan, _changeMode);
        break;
      case WorkoutScreenMode.gym:
        return Text('Gym Mode');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutPlan = ModalRoute.of(context).settings.arguments as WorkoutPlan;

    return Scaffold(
      appBar: getAppBar(workoutPlan),
      body: FutureBuilder<WorkoutPlan>(
        future: _loadWorkoutPlanDetail(context, workoutPlan.id),
        builder: (context, AsyncSnapshot<WorkoutPlan> snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : getBody(snapshot.data),
      ),
    );
  }
}
