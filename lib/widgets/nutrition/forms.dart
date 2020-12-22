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
import 'package:provider/provider.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutritional_plans.dart';

class MealForm extends StatelessWidget {
  Meal meal;
  NutritionalPlan _plan;

  MealForm(plan, [meal]) {
    this._plan = plan;
    this.meal = meal ?? Meal();
  }

  //MealForm(this._plan, {this.meal});

  final _form = GlobalKey<FormState>();
  final _timeController = TextEditingController(text: timeToString(TimeOfDay.now()));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: AppLocalizations.of(context).time),
              controller: _timeController,
              onTap: () async {
                // Stop keyboard from appearing
                FocusScope.of(context).requestFocus(new FocusNode());

                // Open time picker
                var pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                _timeController.text = timeToString(pickedTime);
              },
              onSaved: (newValue) {
                meal.time = stringToTime(newValue);
              },
              onFieldSubmitted: (_) {},
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).save),
              onPressed: () async {
                if (!_form.currentState.validate()) {
                  return;
                }
                _form.currentState.save();

                meal.plan = _plan.id;

                try {
                  Provider.of<NutritionalPlans>(context, listen: false).addMeal(meal, _plan);
                  Navigator.of(context).pop();
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
