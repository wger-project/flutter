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
import 'package:provider/provider.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/workouts/forms.dart';
import 'package:wger/widgets/workouts/workout_logs.dart';
import 'package:wger/widgets/workouts/workout_plan_detail.dart';

enum WorkoutScreenMode {
  workout,
  log,
}

enum WorkoutOptions {
  edit,
  delete,
}

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen();
  static const routeName = '/workout-plan-detail';

  @override
  _WorkoutPlanScreenState createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  WorkoutScreenMode _mode = WorkoutScreenMode.workout;

  void _changeMode(WorkoutScreenMode newMode) {
    setState(() {
      _mode = newMode;
    });
  }

  Future<WorkoutPlan> _loadFullWorkout(BuildContext context, int planId) {
    return Provider.of<WorkoutPlansProvider>(context, listen: false)
        .fetchAndSetWorkoutPlanFull(planId);
  }

  Widget getBody(WorkoutPlan plan) {
    switch (_mode) {
      case WorkoutScreenMode.workout:
        return WorkoutPlanDetail(plan, _changeMode);

      case WorkoutScreenMode.log:
        return WorkoutLogs(plan, _changeMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    const appBarForeground = Colors.white;
    final workoutPlan = ModalRoute.of(context)!.settings.arguments as WorkoutPlan;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            iconTheme: const IconThemeData(color: appBarForeground),
            backgroundColor: wgerPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 56, 16),
              title: Text(
                workoutPlan.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: appBarForeground),
              ),
            ),
            actions: [
              PopupMenuButton<WorkoutOptions>(
                icon: const Icon(Icons.more_vert, color: appBarForeground),
                onSelected: (value) {
                  // Edit
                  if (value == WorkoutOptions.edit) {
                    Navigator.pushNamed(
                      context,
                      FormScreen.routeName,
                      arguments: FormScreenArguments(
                        AppLocalizations.of(context).edit,
                        WorkoutForm(workoutPlan),
                      ),
                    );

                    // Delete
                  } else if (value == WorkoutOptions.delete) {
                    Provider.of<WorkoutPlansProvider>(context, listen: false)
                        .deleteWorkout(workoutPlan.id!);
                    Navigator.of(context).pop();

                    // Toggle Mode
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<WorkoutOptions>(
                      value: WorkoutOptions.edit,
                      child: Text(AppLocalizations.of(context).edit),
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
          ),
          FutureBuilder(
            future: _loadFullWorkout(context, workoutPlan.id!),
            builder: (context, AsyncSnapshot<WorkoutPlan> snapshot) => SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Consumer<WorkoutPlansProvider>(
                      builder: (context, value, child) => getBody(workoutPlan),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
