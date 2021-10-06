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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';

class MealForm extends StatelessWidget {
  late Meal _meal;
  final int _planId;

  final _form = GlobalKey<FormState>();
  final _timeController = TextEditingController();
  final _nameController = TextEditingController();

  MealForm(this._planId, [meal]) {
    _meal = meal ?? Meal(plan: _planId);
    _timeController.text = timeToString(_meal.time)!;
    _nameController.text = _meal.name;
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
              key: Key('field-time'),
              decoration: InputDecoration(labelText: AppLocalizations.of(context).time),
              controller: _timeController,
              onTap: () async {
                // Stop keyboard from appearing
                FocusScope.of(context).requestFocus(FocusNode());

                // Open time picker
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _meal.time!,
                );

                _timeController.text = timeToString(pickedTime)!;
              },
              onSaved: (newValue) {
                _meal.time = stringToTime(newValue);
              },
              onFieldSubmitted: (_) {},
            ),
            TextFormField(
              maxLength: 25,
              key: Key('field-name'),
              decoration: InputDecoration(labelText: AppLocalizations.of(context).name),
              controller: _nameController,
              onSaved: (newValue) {
                _meal.name = newValue as String;
              },
              onFieldSubmitted: (_) {},
            ),
            ElevatedButton(
              key: Key(SUBMIT_BUTTON_KEY_NAME),
              child: Text(AppLocalizations.of(context).save),
              onPressed: () async {
                if (!_form.currentState!.validate()) {
                  return;
                }
                _form.currentState!.save();

                try {
                  _meal.id == null
                      ? Provider.of<NutritionPlansProvider>(context, listen: false)
                          .addMeal(_meal, _planId)
                      : Provider.of<NutritionPlansProvider>(context, listen: false).editMeal(_meal);
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
  final Meal _meal;
  late MealItem _mealItem;

  MealItemForm(this._meal, [mealItem]) {
    _mealItem = mealItem ?? MealItem.empty();
    _mealItem.mealId = _meal.id!;
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
                controller: _ingredientController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context).ingredient),
              ),
              suggestionsCallback: (pattern) async {
                return Provider.of<NutritionPlansProvider>(context, listen: false).searchIngredient(
                  pattern,
                  Localizations.localeOf(context).languageCode,
                );
              },
              itemBuilder: (context, dynamic suggestion) {
                return ListTile(
                  title: Text(suggestion['value']),
                  subtitle: Text(suggestion['data']['id'].toString()),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (dynamic suggestion) {
                _mealItem.ingredientId = suggestion['data']['id'];
                _ingredientController.text = suggestion['value'];
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return AppLocalizations.of(context).selectIngredient;
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: AppLocalizations.of(context).weight),
              controller: _amountController,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_) {},
              onSaved: (newValue) {
                _mealItem.amount = double.parse(newValue!);
              },
              validator: (value) {
                try {
                  double.parse(value!);
                } catch (error) {
                  return AppLocalizations.of(context).enterValidNumber;
                }
                return null;
              },
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).save),
              onPressed: () async {
                if (!_form.currentState!.validate()) {
                  return;
                }
                _form.currentState!.save();

                try {
                  Provider.of<NutritionPlansProvider>(context, listen: false)
                      .addMealItem(_mealItem, _meal);
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
  final _form = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  late NutritionalPlan _plan;

  PlanForm([NutritionalPlan? plan]) {
    _plan = plan ?? NutritionalPlan.empty();
    _descriptionController.text = _plan.description;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          // Description
          TextFormField(
            key: Key('field-description'),
            decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
            controller: _descriptionController,
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              _plan.description = newValue!;
            },
          ),
          ElevatedButton(
            key: Key(SUBMIT_BUTTON_KEY_NAME),
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              // Validate and save the current values to the weightEntry
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              // Save to DB
              try {
                if (_plan.id != null) {
                  await Provider.of<NutritionPlansProvider>(context, listen: false).editPlan(_plan);
                  Navigator.of(context).pop();
                } else {
                  _plan = await Provider.of<NutritionPlansProvider>(context, listen: false)
                      .addPlan(_plan);
                  Navigator.of(context).pushReplacementNamed(
                    NutritionalPlanScreen.routeName,
                    arguments: _plan,
                  );
                }

                // Saving was successful, reset the data
                _descriptionController.clear();
              } on WgerHttpException catch (error) {
                showHttpExceptionErrorDialog(error, context);
              } catch (error) {
                showErrorDialog(error, context);
              }
            },
          ),
        ],
      ),
    );
  }
}
