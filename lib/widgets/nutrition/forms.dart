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
  Meal meal;
  NutritionalPlan _plan;

  MealForm(plan, [meal]) {
    this._plan = plan;
    this.meal = meal ?? Meal();
  }

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
                  Provider.of<Nutrition>(context, listen: false).addMeal(meal, _plan.id);
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
  NutritionalPlan _plan;

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
            /*
            TextFormField(
              decoration: InputDecoration(labelText: AppLocalizations.of(context).ingredient),
              controller: _ingredientController,
              onSaved: (newValue) async {
                mealItem.ingredient = await Provider.of<NutritionalPlans>(context, listen: false)
                    .fetchIngredient(int.parse(newValue));
                print(mealItem.ingredient.name);
                print('ppppppppppppppppppp');
              },
              onFieldSubmitted: (_) {},
            ),

             */
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

                  Provider.of<Nutrition>(context, listen: false).addMealIteam(mealItem, meal.id);
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
