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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/weight/charts.dart';
import 'package:wger/widgets/weight/forms.dart';
import 'package:wger/widgets/workouts/forms.dart';

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
  var showDetail = false;

  @override
  Widget build(BuildContext context) {
    plan = Provider.of<Nutrition>(context, listen: false).currentPlan;
    final bool hasContent = plan != null;

    List<Widget> out = [];
    if (hasContent) {
      for (var meal in plan.meals) {
        out.add(Text(
          meal.time.format(context),
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
        out.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${meal.nutritionalValues.energy}${AppLocalizations.of(context).kcal}'),
            Text(' / '),
            Text('${meal.nutritionalValues.protein}${AppLocalizations.of(context).g}'),
            Text(' / '),
            Text('${meal.nutritionalValues.carbohydrates}${AppLocalizations.of(context).g}'),
            Text(' / '),
            Text('${meal.nutritionalValues.fat}${AppLocalizations.of(context).g} '),
          ],
        ));
        out.add(SizedBox(height: 5));

        if (showDetail) {
          meal.mealItems.forEach((item) {
            out.add(
              Column(children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.ingredientObj.name),
                    SizedBox(width: 5),
                    Text('${item.amount.toString()} ${AppLocalizations.of(context).g}'),
                  ],
                ),
              ]),
            );
          });
          out.add(SizedBox(height: 10));
          out.add(Divider());
        }
      }
    }

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).nutritionalPlan,
            style: Theme.of(context).textTheme.headline4,
          ),
          hasContent
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
                    ...out,
                    Container(
                      padding: EdgeInsets.all(15),
                      height: 180,
                      child: NutritionalPlanPieChartWidget(plan.nutritionalValues),
                    )
                  ],
                )
              : NothingFound(
                  AppLocalizations.of(context).noNutritionalPlans,
                  AppLocalizations.of(context).newNutritionalPlan,
                  PlanForm(NutritionalPlan()),
                ),
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
                  : NothingFound(
                      AppLocalizations.of(context).noWeightEntries,
                      AppLocalizations.of(context).newEntry,
                      WeightForm(),
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
    final bool hasContent = _workoutPlan != null;

    List<Widget> out = [];
    if (hasContent) {
      for (var day in _workoutPlan.days) {
        out.add(Text(
          day.description,
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
        if (showDetail) {
          day.sets.forEach((set) {
            out.add(Column(
              children: [
                ...set.settings.map((s) {
                  return Column(
                    children: [
                      Text(s.exerciseObj.name),
                      Text(s.repsText),
                      SizedBox(height: 10),
                    ],
                  );
                }).toList(),
                Divider(),
              ],
            ));
          });
        }
      }
    }

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).labelWorkoutPlan,
            style: Theme.of(context).textTheme.headline4,
          ),
          hasContent
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
                    ...out,
                  ],
                )
              : NothingFound(
                  AppLocalizations.of(context).noWorkoutPlans,
                  AppLocalizations.of(context).newWorkout,
                  WorkoutForm(WorkoutPlan()),
                ),
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
      ),
    );
  }
}

class NothingFound extends StatelessWidget {
  final String _title;
  final String _titleForm;
  final Widget _form;

  NothingFound(this._title, this._titleForm, this._form);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_title),
          IconButton(
            iconSize: 30,
            icon: const Icon(
              Icons.add_box,
              color: wgerPrimaryButtonColor,
            ),
            onPressed: () async {
              showFormBottomSheet(
                context,
                _titleForm,
                _form,
              );
            },
          ),
        ],
      ),
    );
  }
}
