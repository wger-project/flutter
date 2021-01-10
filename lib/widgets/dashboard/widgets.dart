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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/weight/charts.dart';

class DashboardNutritionWidget extends StatefulWidget {
  const DashboardNutritionWidget({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  _DashboardNutritionWidgetState createState() => _DashboardNutritionWidgetState();
}

class _DashboardNutritionWidgetState extends State<DashboardNutritionWidget> {
  Nutrition nutrition;
  NutritionalPlan plan;

  Future<void> _refreshPlanEntries(BuildContext context) async {
    await Provider.of<Nutrition>(context, listen: false).fetchAndSetPlans();
    nutrition = Provider.of<Nutrition>(context, listen: false);
    plan = nutrition.currentPlan;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nutrition', style: Theme.of(context).textTheme.headline6),
          FutureBuilder(
            future: _refreshPlanEntries(context),
            builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : plan != null
                    ? Column(
                        children: [
                          Icon(Icons.restaurant),
                          Text(plan.description),
                          Container(
                              padding: EdgeInsets.all(15),
                              height: 180,
                              child: NutritionalPlanPieChartWidget(plan.nutritionalValues))
                        ],
                      )
                    : Text('You have no nutritional plans'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('Action one'),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              TextButton(
                child: const Text('Action two'),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardWeightWidget extends StatefulWidget {
  const DashboardWeightWidget({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  _DashboardWeightWidgetState createState() => _DashboardWeightWidgetState();
}

class _DashboardWeightWidgetState extends State<DashboardWeightWidget> {
  BodyWeight weightEntriesData;

  Future<void> _refreshWeightEntries(BuildContext context) async {
    await Provider.of<BodyWeight>(context, listen: false).fetchAndSetEntries();
    weightEntriesData = Provider.of<BodyWeight>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Weight', style: Theme.of(context).textTheme.headline6),
          FutureBuilder(
            future: _refreshWeightEntries(context),
            builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Icon(Icons.bar_chart),
                      Text('Weight'),
                      weightEntriesData.items.length > 0
                          ? Container(
                              padding: EdgeInsets.all(15),
                              height: 180,
                              child: WeightChartWidget(weightEntriesData.items),
                            )
                          : Text('You have no weight entries'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            child: const Text('Action one'),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            child: const Text('Action two'),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class DashboardWorkoutWidget extends StatefulWidget {
  const DashboardWorkoutWidget({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  _DashboardWorkoutWidgetState createState() => _DashboardWorkoutWidgetState();
}

class _DashboardWorkoutWidgetState extends State<DashboardWorkoutWidget> {
  WorkoutPlan _workoutPlan;

  Future<void> _fetchWorkoutEntries(BuildContext context) async {
    await Provider.of<WorkoutPlans>(context, listen: false).fetchAndSetWorkouts();
    _workoutPlan = Provider.of<WorkoutPlans>(context, listen: false).currentPlan;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Training', style: Theme.of(context).textTheme.headline6),
          Icon(Icons.fitness_center),
          FutureBuilder(
            future: _fetchWorkoutEntries(context),
            builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _workoutPlan != null
                    ? Column(children: [
                        Text(_workoutPlan.description),
                        Text(DateFormat.yMd().format(_workoutPlan.creationDate)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: const Text('Action one'),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              child: const Text('Action two'),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 8),
                          ],
                        )
                      ])
                    : Text('you have no workouts'),
          ),
        ],
      ),
    );
  }
}
