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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/weight/charts.dart';
import 'package:wger/widgets/weight/forms.dart';
import 'package:wger/widgets/workouts/forms.dart';

class DashboardNutritionWidget extends StatefulWidget {
  @override
  _DashboardNutritionWidgetState createState() => _DashboardNutritionWidgetState();
}

class _DashboardNutritionWidgetState extends State<DashboardNutritionWidget> {
  NutritionalPlan? _plan;
  var _showDetail = false;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _plan = Provider.of<NutritionPlansProvider>(context, listen: false).currentPlan;
    _hasContent = _plan != null;
  }

  List<Widget> getContent() {
    List<Widget> out = [];

    if (!_hasContent) {
      return out;
    }

    for (var meal in _plan!.meals) {
      out.add(
        Row(
          children: [
            Expanded(
              child: Text(
                meal.time!.format(context),
                style: TextStyle(fontWeight: FontWeight.bold),
                //textAlign: TextAlign.left,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                MutedText(
                    '${meal.nutritionalValues.energy.toStringAsFixed(0)}${AppLocalizations.of(context).kcal}'),
                MutedText(' / '),
                MutedText(
                    '${meal.nutritionalValues.protein.toStringAsFixed(0)}${AppLocalizations.of(context).g}'),
                MutedText(' / '),
                MutedText(
                    '${meal.nutritionalValues.carbohydrates.toStringAsFixed(0)}${AppLocalizations.of(context).g}'),
                MutedText(' / '),
                MutedText(
                    '${meal.nutritionalValues.fat.toStringAsFixed(0)}${AppLocalizations.of(context).g} '),
              ],
            ),
            IconButton(
              icon: Icon(Icons.history_edu),
              color: wgerPrimaryButtonColor,
              onPressed: () {
                Provider.of<NutritionPlansProvider>(context, listen: false).logMealToDiary(meal);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).mealLogged,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
      out.add(SizedBox(height: 5));

      if (_showDetail) {
        meal.mealItems.forEach((item) {
          out.add(
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.ingredientObj.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text('${item.amount.toStringAsFixed(0)} ${AppLocalizations.of(context).g}'),
                  ],
                ),
              ],
            ),
          );
        });
        out.add(SizedBox(height: 10));
      }
      out.add(Divider());
    }

    return out;
  }

  Widget getTrailing() {
    if (!_hasContent) {
      return Text('');
    }

    return _showDetail ? Icon(Icons.expand_less) : Icon(Icons.expand_more);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              _hasContent ? _plan!.description : AppLocalizations.of(context).labelWorkoutPlan,
              style: Theme.of(context).textTheme.headline4,
            ),
            subtitle: Text(
              _hasContent
                  ? DateFormat.yMd(Localizations.localeOf(context).languageCode)
                      .format(_plan!.creationDate)
                  : '',
            ),
            leading: Icon(
              Icons.restaurant,
              color: Colors.black,
            ),
            trailing: getTrailing(),
            onTap: () {
              setState(() {
                _showDetail = !_showDetail;
              });
            },
          ),
          _hasContent
              ? Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    children: [
                      ...getContent(),
                      Container(
                        padding: EdgeInsets.all(15),
                        height: 180,
                        child: NutritionalPlanPieChartWidget(_plan!.nutritionalValues),
                      )
                    ],
                  ),
                )
              : NothingFound(
                  AppLocalizations.of(context).noNutritionalPlans,
                  AppLocalizations.of(context).newNutritionalPlan,
                  PlanForm(),
                ),
          if (_hasContent)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                    child: Text(AppLocalizations.of(context).goToDetailPage),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(NutritionalPlanScreen.routeName, arguments: _plan);
                    }),
              ],
            ),
        ],
      ),
    );
  }
}

class DashboardWeightWidget extends StatefulWidget {
  @override
  _DashboardWeightWidgetState createState() => _DashboardWeightWidgetState();
}

class _DashboardWeightWidgetState extends State<DashboardWeightWidget> {
  late BodyWeightProvider weightEntriesData;

  @override
  Widget build(BuildContext context) {
    weightEntriesData = Provider.of<BodyWeightProvider>(context, listen: false);

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context).weight,
              style: Theme.of(context).textTheme.headline4,
            ),
            leading: FaIcon(
              FontAwesomeIcons.weight,
              color: Colors.black,
            ),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    AppLocalizations.of(context).newEntry,
                    WeightForm(),
                  ),
                );
              },
            ),
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
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardWorkoutWidget extends StatefulWidget {
  @override
  _DashboardWorkoutWidgetState createState() => _DashboardWorkoutWidgetState();
}

class _DashboardWorkoutWidgetState extends State<DashboardWorkoutWidget> {
  var _showDetail = false;
  bool _hasContent = false;

  WorkoutPlan? _workoutPlan;

  @override
  void initState() {
    super.initState();
    _workoutPlan = context.read<WorkoutPlansProvider>().activePlan;
    _hasContent = _workoutPlan != null;
  }

  Widget getTrailing() {
    if (!_hasContent) {
      return Text('');
    }

    return _showDetail ? Icon(Icons.expand_less) : Icon(Icons.expand_more);
  }

  List<Widget> getContent() {
    List<Widget> out = [];

    if (!_hasContent) {
      return out;
    }

    for (var day in _workoutPlan!.days) {
      out.add(Container(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Text(
                day.description,
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            MutedText(
              day.getDaysText,
              textAlign: TextAlign.right,
            ),
            IconButton(
              icon: Icon(Icons.play_arrow),
              color: wgerPrimaryButtonColor,
              onPressed: () {
                Navigator.of(context).pushNamed(GymModeScreen.routeName, arguments: day);
              },
            ),
          ],
        ),
      ));

      day.sets.forEach((set) {
        out.add(Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...set.settingsFiltered.map((s) {
                return _showDetail
                    ? Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.exerciseObj.name),
                              SizedBox(width: 10),
                              MutedText(set.getSmartRepr(s.exerciseObj).join('\n')),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      )
                    : Container();
              }).toList(),
            ],
          ),
        ));
      });
      out.add(Divider());
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              _hasContent ? _workoutPlan!.name : AppLocalizations.of(context).labelWorkoutPlan,
              style: Theme.of(context).textTheme.headline4,
            ),
            subtitle: Text(
              _hasContent
                  ? DateFormat.yMd(Localizations.localeOf(context).languageCode)
                      .format(_workoutPlan!.creationDate)
                  : '',
            ),
            leading: Icon(
              Icons.fitness_center_outlined,
              color: Colors.black,
            ),
            trailing: getTrailing(),
            onTap: () {
              setState(() {
                _showDetail = !_showDetail;
              });
            },
          ),
          _hasContent
              ? Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    children: [
                      ...getContent(),
                    ],
                  ),
                )
              : NothingFound(
                  AppLocalizations.of(context).noWorkoutPlans,
                  AppLocalizations.of(context).newWorkout,
                  WorkoutForm(WorkoutPlan.empty()),
                ),
          if (_hasContent)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: Text(AppLocalizations.of(context).goToDetailPage),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(WorkoutPlanScreen.routeName, arguments: _workoutPlan);
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
