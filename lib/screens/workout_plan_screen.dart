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
import 'package:wger/locale/locales.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/workout_plans_screen.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/workouts/forms.dart';
import 'package:wger/widgets/workouts/workout_logs.dart';
import 'package:wger/widgets/workouts/workout_plan_detail.dart';

enum WorkoutScreenMode {
  workout,
  log,
  gym,
}

enum WorkoutOptions {
  edit,
  delete,
  toggleMode,
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
      //appBar: getAppBar(workoutPlan),
      body: Consumer<WorkoutPlans>(
        builder: (context, value, child) => CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              actions: [
                PopupMenuButton<WorkoutOptions>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) {
                    // Edit
                    if (value == WorkoutOptions.edit) {
                      showFormBottomSheet(
                        context,
                        AppLocalizations.of(context).edit,
                        WorkoutForm(workoutPlan),
                      );

                      // Delete
                    } else if (value == WorkoutOptions.delete) {
                      Provider.of<WorkoutPlans>(context, listen: false)
                          .deleteWorkout(workoutPlan.id);
                      Navigator.of(context).pushNamed(WorkoutPlansScreen.routeName);

                      // Toggle Mode
                    } else if (value == WorkoutOptions.toggleMode) {
                      if (_mode == WorkoutScreenMode.workout) {
                        _changeMode(WorkoutScreenMode.log);
                      } else {
                        _changeMode(WorkoutScreenMode.workout);
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<WorkoutOptions>(
                        value: WorkoutOptions.edit,
                        child: Text(AppLocalizations.of(context).edit),
                      ),
                      PopupMenuItem<WorkoutOptions>(
                        child: _mode == WorkoutScreenMode.log
                            ? Text('Open workout')
                            : Text('Open logs'),
                        value: WorkoutOptions.toggleMode,
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<WorkoutOptions>(
                        value: WorkoutOptions.delete,
                        child: Text(AppLocalizations.of(context).delete),
                      ),
                    ];
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(workoutPlan.description),
                background: Image.network(
                  'https://thumbnails.production.thenounproject.com/GS2Ct-A74O23cwQ-FYCpzlN9Bdc=/fit-in/1000x1000/photos.production.thenounproject.com/photos/1F45191D-AE0E-425D-90E3-95A23B762B95.jpg',
                  // --> https://thenounproject.com/photo/athlete-working-out-with-battle-ropes-outdoors-on-grass-field-0LrJR4/

                  fit: BoxFit.cover,
                ),
              ),
            ),
            getBody(workoutPlan),
          ],
        ),
      ),
    );
  }
}
