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
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/weight/charts.dart';
import 'package:wger/widgets/weight/forms.dart';
import 'package:wger/widgets/workouts/forms.dart';

class DashboardNutritionWidget extends StatefulWidget {
  const DashboardNutritionWidget({
    required this.context,
  });

  final BuildContext context;

  @override
  _DashboardNutritionWidgetState createState() => _DashboardNutritionWidgetState();
}

class _DashboardNutritionWidgetState extends State<DashboardNutritionWidget> {
  late NutritionalPlan plan;
  var showDetail = false;

  @override
  Widget build(BuildContext context) {
    NutritionalPlan? plan = Provider.of<Nutrition>(context, listen: false).currentPlan;
    final bool hasContent = plan != null;

    List<Widget> out = [];
    if (hasContent) {
      for (var meal in plan.meals) {
        out.add(Container(
          width: double.infinity,
          child: Row(
            children: [
              Spacer(
                flex: 1,
              ),
              Expanded(
                flex: 8,
                child: Text(
                  meal.time.format(context),
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: IconButton(
                  icon: Icon(Icons.bar_chart),
                  onPressed: () {
                    Provider.of<Nutrition>(context, listen: false).logMealToDiary(meal);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.mealLogged,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ));
        out.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                '${meal.nutritionalValues.energy.toStringAsFixed(0)}${AppLocalizations.of(context)!.kcal}'),
            Text(' / '),
            Text(
                '${meal.nutritionalValues.protein.toStringAsFixed(0)}${AppLocalizations.of(context)!.g}'),
            Text(' / '),
            Text(
                '${meal.nutritionalValues.carbohydrates.toStringAsFixed(0)}${AppLocalizations.of(context)!.g}'),
            Text(' / '),
            Text(
                '${meal.nutritionalValues.fat.toStringAsFixed(0)}${AppLocalizations.of(context)!.g} '),
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
                    Text('${item.amount.toStringAsFixed(0)} ${AppLocalizations.of(context)!.g}'),
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
            AppLocalizations.of(context)!.nutritionalPlan,
            style: Theme.of(context).textTheme.headline4,
          ),
          hasContent
              ? Column(
                  children: [
                    Text(
                      DateFormat.yMd(Localizations.localeOf(context).languageCode)
                          .format(plan.creationDate),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    TextButton(
                      child: Text(
                        plan.description,
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.of(context)
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
                  AppLocalizations.of(context)!.noNutritionalPlans,
                  AppLocalizations.of(context)!.newNutritionalPlan,
                  PlanForm(),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.toggleDetails),
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
    required this.context,
  });

  final BuildContext context;

  @override
  _DashboardWeightWidgetState createState() => _DashboardWeightWidgetState();
}

class _DashboardWeightWidgetState extends State<DashboardWeightWidget> {
  late BodyWeight weightEntriesData;

  @override
  Widget build(BuildContext context) {
    weightEntriesData = Provider.of<BodyWeight>(context, listen: false);

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.weight,
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
                      AppLocalizations.of(context)!.noWeightEntries,
                      AppLocalizations.of(context)!.newEntry,
                      WeightForm(),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text(AppLocalizations.of(context)!.newEntry),
                    onPressed: () async {
                      Navigator.pushNamed(
                        context,
                        FormScreen.routeName,
                        arguments: FormScreenArguments(
                          AppLocalizations.of(context)!.newEntry,
                          WeightForm(),
                        ),
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
    required this.context,
  });

  final BuildContext context;

  @override
  _DashboardWorkoutWidgetState createState() => _DashboardWorkoutWidgetState();
}

class _DashboardWorkoutWidgetState extends State<DashboardWorkoutWidget> {
  late WorkoutPlan _workoutPlan;
  var showDetail = false;

  @override
  Widget build(BuildContext context) {
    WorkoutPlan? _workoutPlan = Provider.of<WorkoutPlans>(context, listen: false).activePlan;
    final bool hasContent = _workoutPlan != null;

    List<Widget> out = [];
    if (hasContent) {
      for (var day in _workoutPlan.days) {
        out.add(Container(
          width: double.infinity,
          child: Row(
            children: [
              Spacer(
                flex: 1,
              ),
              Expanded(
                flex: 8,
                child: Text(
                  day.description,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    Navigator.of(context).pushNamed(GymModeScreen.routeName, arguments: day);
                  },
                ),
              )
            ],
          ),
        ));

        if (showDetail) {
          day.sets.forEach((set) {
            out.add(Column(
              children: [
                ...set.settingsFiltered.map((s) {
                  return Column(
                    children: [
                      Text(s.exerciseObj.name),
                      Text(s.repsText),
                    ],
                  );
                }).toList(),
              ],
            ));
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
            AppLocalizations.of(context)!.labelWorkoutPlan,
            style: Theme.of(context).textTheme.headline4,
          ),
          hasContent
              ? Column(
                  children: [
                    Text(
                      DateFormat.yMd(Localizations.localeOf(context).languageCode)
                          .format(_workoutPlan.creationDate),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    TextButton(
                      child: Text(
                        _workoutPlan.description,
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(WorkoutPlanScreen.routeName, arguments: _workoutPlan);
                      },
                    ),
                    ...out,
                  ],
                )
              : NothingFound(
                  AppLocalizations.of(context)!.noWorkoutPlans,
                  AppLocalizations.of(context)!.newWorkout,
                  WorkoutForm(WorkoutPlan(creationDate: DateTime.now(), description: '')),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.toggleDetails),
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
              Navigator.pushNamed(
                context,
                FormScreen.routeName,
                arguments: FormScreenArguments(
                  _titleForm,
                  _form,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
