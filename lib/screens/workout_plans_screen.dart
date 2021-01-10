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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/workouts/workout_plans_list.dart';

class WorkoutPlansScreen extends StatefulWidget {
  static const routeName = '/workout-plans-list';

  @override
  _WorkoutPlansScreenState createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  final workoutController = TextEditingController();

  Future<WorkoutPlan> _refreshWorkoutPlans(BuildContext context) async {
    await Provider.of<WorkoutPlans>(context, listen: false).fetchAndSetWorkouts();
  }

  Widget getAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).labelWorkoutPlans),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                margin: EdgeInsets.all(20),
                child: Form(
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context).newWorkout,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: AppLocalizations.of(context).description),
                        controller: workoutController,
                        onFieldSubmitted: (_) {},
                      ),
                      ElevatedButton(
                        child: Text('Save'),
                        onPressed: () {
                          final workoutFuture = Provider.of<WorkoutPlans>(context, listen: false)
                              .addWorkout(WorkoutPlan(description: workoutController.text));
                          workoutController.text = '';
                          Navigator.of(context).pop();
                          workoutFuture.then(
                            (workout) => Navigator.of(context).pushNamed(
                              WorkoutPlanScreen.routeName,
                              arguments: workout,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshWorkoutPlans(context),
        child: Consumer<WorkoutPlans>(
          builder: (context, productsData, child) => WorkoutPlansList(),
        ),
      ),
    );
  }
}
