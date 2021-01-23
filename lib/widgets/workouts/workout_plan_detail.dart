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
import 'package:wger/locale/locales.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/workouts/day.dart';
import 'package:wger/widgets/workouts/forms.dart';

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
  final WorkoutPlan _workoutPlan;
  final _changeMode;
  WorkoutPlanDetail(this._workoutPlan, this._changeMode);

  @override
  _WorkoutPlanDetailState createState() => _WorkoutPlanDetailState();
}

class _WorkoutPlanDetailState extends State<WorkoutPlanDetail> {
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
                DateFormat.yMd().format(widget._workoutPlan.creationDate).toString(),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showFormBottomSheet(
                  context,
                  AppLocalizations.of(context).edit,
                  WorkoutForm(widget._workoutPlan),
                );
              },
            ),
            ...widget._workoutPlan.days.map((workoutDay) => WorkoutDayWidget(workoutDay)).toList(),
            Column(
              children: [
                ElevatedButton(
                  child: Text(AppLocalizations.of(context).add),
                  onPressed: () {
                    showFormBottomSheet(
                      context,
                      AppLocalizations.of(context).newDay,
                      DayFormWidget(
                        workout: widget._workoutPlan,
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  child: Text('View logs'),
                  onPressed: () {
                    widget._changeMode(WorkoutScreenMode.log);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
