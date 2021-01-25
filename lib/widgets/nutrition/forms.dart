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
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/http_exception.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';

class MealForm extends StatelessWidget {
  Meal _meal;
  int _planId;

  final _form = GlobalKey<FormState>();
  final _timeController = TextEditingController();

  MealForm(planId, [meal]) {
    this._planId = planId;
    this._meal = meal ?? Meal();

    _timeController.text =
        _meal.time != null ? timeToString(_meal.time) : timeToString(TimeOfDay.now());
  }

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
                  initialTime: _meal.time ?? TimeOfDay.now(),
                );

                _timeController.text = timeToString(pickedTime);
              },
              onSaved: (newValue) {
                _meal.time = stringToTime(newValue);
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

                _meal.plan = _planId;

                try {
                  _meal.id == null
                      ? Provider.of<Nutrition>(context, listen: false).addMeal(_meal, _planId)
                      : Provider.of<Nutrition>(context, listen: false).editMeal(_meal);
                } on WgerHttpException catch (error) {
                  showHttpExceptionErrorDialog(error, context);
                } catch (error) {
                  showErrorDialog(error, context);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MealItemForm extends StatelessWidget {
  Meal meal;
  MealItem mealItem;

  MealItemForm(meal, [mealItem]) {
    this.meal = meal;
    this.mealItem = mealItem ?? MealItem();
  }

  final _form = GlobalKey<FormState>();
  final _ingredientController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          children: [
            TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: this._ingredientController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context).ingredient),
              ),
              suggestionsCallback: (pattern) async {
                return await Provider.of<Nutrition>(context, listen: false)
                    .searchIngredient(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion['value']),
                  subtitle: Text(suggestion['data']['id'].toString()),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (suggestion) {
                print(suggestion);
                mealItem.ingredientId = suggestion['data']['id'];
                this._ingredientController.text = suggestion['value'];
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please select an ingredient';
                }
                if (mealItem.ingredientId == null) {
                  return 'Please select an ingredient';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: AppLocalizations.of(context).amount),
              controller: _amountController,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_) {},
              onSaved: (newValue) {
                mealItem.amount = double.parse(newValue);
              },
              validator: (value) {
                try {
                  double.parse(value);
                } catch (error) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).save),
              onPressed: () async {
                if (!_form.currentState.validate()) {
                  return;
                }
                _form.currentState.save();

                try {
                  mealItem.meal = meal.id;

                  Provider.of<Nutrition>(context, listen: false).addMealItem(mealItem, meal.id);
                } on WgerHttpException catch (error) {
                  showHttpExceptionErrorDialog(error, context);
                } catch (error) {
                  showErrorDialog(error, context);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PlanForm extends StatelessWidget {
  NutritionalPlan _plan;
  PlanForm(this._plan);

  final _form = GlobalKey<FormState>();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    descriptionController.text = _plan.description ?? '';

    return Form(
      key: _form,
      child: Column(
        children: [
          // Description
          TextFormField(
            decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
            controller: descriptionController,
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              _plan.description = newValue;
            },
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              // Validate and save the current values to the weightEntry
              final isValid = _form.currentState.validate();
              if (!isValid) {
                return;
              }
              _form.currentState.save();

              // Save the entry on the server
              try {
                if (_plan.id != null) {
                  await Provider.of<Nutrition>(context, listen: false).patchPlan(_plan);
                } else {
                  await Provider.of<Nutrition>(context, listen: false).postPlan(_plan);
                }

                // Saving was successful, reset the data
                //descriptionController.clear();
                //nutritionalPlan = NutritionalPlan();
              } on WgerHttpException catch (error) {
                showHttpExceptionErrorDialog(error, context);
              } catch (error) {
                showErrorDialog(error, context);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
