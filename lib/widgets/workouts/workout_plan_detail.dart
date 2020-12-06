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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/workouts/day.dart';

class DayCheckbox extends StatefulWidget {
  String name;

  DayCheckbox(this.name);

  @override
  _DayCheckboxState createState() => _DayCheckboxState();
}

class _DayCheckboxState extends State<DayCheckbox> {
  bool _isSelected = false;
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.name),
      value: _isSelected,
      onChanged: (bool newValue) {
        setState(() {
          _isSelected = newValue;
        });
      },
    );
  }
}

class WorkoutPlanDetail extends StatefulWidget {
  WorkoutPlan _workoutPlan;
  WorkoutPlanDetail(this._workoutPlan);

  @override
  _WorkoutPlanDetailState createState() => _WorkoutPlanDetailState();
}

class _WorkoutPlanDetailState extends State<WorkoutPlanDetail> {
  final dayController = TextEditingController();

  Map<String, dynamic> _dayData = {
    'description': '',
    'daysOfWeek': [1],
  };

  Widget showDaySheet(BuildContext outerContext, WorkoutPlan workout) {
    showModalBottomSheet(
      context: outerContext,
      builder: (BuildContext context) {
        return Container(
          child: DayFormWidget(
            dayController: dayController,
            dayData: _dayData,
            workout: workout,
          ),
        );
      },
    );
  }

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
                DateFormat('dd.MM.yyyy').format(widget._workoutPlan.creationDate).toString(),
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
            ...widget._workoutPlan.days.map((workoutDay) => WorkoutDayWidget(workoutDay)).toList(),
            Column(
              children: [
                ElevatedButton(
                    child: Text(AppLocalizations.of(context).add),
                    onPressed: () {
                      showDaySheet(context, widget._workoutPlan);
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DayFormWidget extends StatelessWidget {
  final WorkoutPlan workout;

  DayFormWidget({
    Key key,
    @required this.dayController,
    @required Map<String, dynamic> dayData,
    @required this.workout,
  })  : _dayData = dayData,
        super(key: key);

  final TextEditingController dayController;
  final Map<String, dynamic> _dayData;
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context).newDay,
              style: Theme.of(context).textTheme.headline6,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
              controller: dayController,
              onSaved: (value) {
                _dayData['description'] = value;
              },
              validator: (value) {
                const minLenght = 5;
                const maxLenght = 100;
                if (value.isEmpty || value.length < minLenght || value.length > maxLenght) {
                  return 'Please enter between $minLenght and $maxLenght characters.';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'TODO: Checkbox for days'),
              enabled: false,
            ),
            //...Day().weekdays.values.map((dayName) => DayCheckbox(dayName)).toList(),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).save),
              onPressed: () async {
                if (!_form.currentState.validate()) {
                  return;
                }
                _form.currentState.save();

                try {
                  Provider.of<WorkoutPlans>(context, listen: false)
                      .addDay(Day(description: dayController.text, daysOfWeek: [1]), workout);
                  //dayController.text = '';
                  //Navigator.of(context).pop();
                } catch (error) {
                  await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('An error occurred!'),
                      content: Text('Something went wrong.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Okay'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        )
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
