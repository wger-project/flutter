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
import 'package:wger/locale/locales.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/weight/charts.dart';
import 'package:wger/widgets/weight/forms.dart';

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

  @override
  Widget build(BuildContext context) {
    plan = Provider.of<Nutrition>(context, listen: false).currentPlan;

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).nutritionalPlan,
            style: Theme.of(context).textTheme.headline4,
          ),
          plan != null
              ? Column(
                  children: [
                    Text(
                      DateFormat.yMd().format(plan.creationDate),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    TextButton(
                      child: Text(
                        plan.description,
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        return Navigator.of(context)
                            .pushNamed(NutritionalPlanScreen.routeName, arguments: plan);
                      },
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      height: 180,
                      child: NutritionalPlanPieChartWidget(plan.nutritionalValues),
                    )
                  ],
                )
              : Container(
                  alignment: Alignment.center,
                  height: 150,
                  child: Text('You have no nutritional plans'),
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

  @override
  Widget build(BuildContext context) {
    weightEntriesData = Provider.of<BodyWeight>(context, listen: false);

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).weight,
            style: Theme.of(context).textTheme.headline4,
          ),
          Column(
            children: [
              weightEntriesData.items.length > 0
                  ? Container(
                      padding: EdgeInsets.all(15),
                      height: 180,
                      child: WeightChartWidget(weightEntriesData.items),
                    )
                  : Container(
                      alignment: Alignment.center,
                      height: 150,
                      child: Text('You have no weight entries'),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text(AppLocalizations.of(context).newEntry),
                    onPressed: () async {
                      showFormBottomSheet(
                        context,
                        AppLocalizations.of(context).newEntry,
                        WeightForm(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardWorkoutWidget extends StatefulWidget {
  DashboardWorkoutWidget({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  _DashboardWorkoutWidgetState createState() => _DashboardWorkoutWidgetState();
}

class _DashboardWorkoutWidgetState extends State<DashboardWorkoutWidget> {
  WorkoutPlan _workoutPlan;
  var showDetail = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _workoutPlan = Provider.of<WorkoutPlans>(context, listen: false).activePlan;

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).labelWorkoutPlan,
            style: Theme.of(context).textTheme.headline4,
          ),
          _workoutPlan != null
              ? Column(
                  children: [
                    Text(
                      DateFormat.yMd().format(_workoutPlan.creationDate),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    TextButton(
                      child: Text(
                        _workoutPlan.description,
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        return Navigator.of(context)
                            .pushNamed(WorkoutPlanScreen.routeName, arguments: _workoutPlan);
                      },
                    ),
                    ..._workoutPlan.days.map((workoutDay) {
                      return Column(children: [
                        const SizedBox(height: 10),
                        showDetail == true
                            ? Text(
                                workoutDay.description,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            : Text(workoutDay.description),
                        if (showDetail)
                          ...workoutDay.sets
                              .map((set) => Text(set.exercisesObj.map((e) => e.name).join(', ')))
                              .toList(),
                      ]);
                    }).toList(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: Text(AppLocalizations.of(context).toggleDetails),
                          onPressed: () {
                            setState(() {
                              showDetail = !showDetail;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                )
              : Container(
                  alignment: Alignment.center,
                  height: 150,
                  child: Text('you have no workouts'),
                ),
        ],
      ),
    );
  }
}
