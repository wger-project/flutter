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
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:wger/widgets/nutrition/widgets.dart';

class MealForm extends StatelessWidget {
  late final Meal _meal;
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
      margin: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              key: const Key('field-time'),
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
              key: const Key('field-name'),
              decoration: InputDecoration(labelText: AppLocalizations.of(context).name),
              controller: _nameController,
              onSaved: (newValue) {
                _meal.name = newValue as String;
              },
              onFieldSubmitted: (_) {},
            ),
            ElevatedButton(
              key: const Key(SUBMIT_BUTTON_KEY_NAME),
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
  late final MealItem _mealItem;
  final List<MealItem> _listMealItems;
  late String _barcode;
  late bool _test;

  final _form = GlobalKey<FormState>();
  final _ingredientIdController = TextEditingController();
  final _ingredientController = TextEditingController();
  final _amountController = TextEditingController();

  MealItemForm(this._meal, this._listMealItems, [mealItem, code, test]) {
    _mealItem = mealItem ?? MealItem.empty();
    _test = test ?? false;
    _barcode = code ?? '';
    _mealItem.mealId = _meal.id!;
  }

  TextEditingController get ingredientIdController => _ingredientIdController;


  MealItem get mealItem => _mealItem;

  Future<String> scanBarcode() async {
    String barcode;
    try {
      barcode =  await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      if(barcode.compareTo('-1') == 0){
        return '';
      }
    } on PlatformException {
      return '';
    }

    return barcode;
  }

  @override
  Widget build(BuildContext context) {
    final String unit = AppLocalizations.of(context).g;
    return Container(
      margin: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          children: [
            IngredientTypeahead(_ingredientIdController, _ingredientController),
            ElevatedButton(
                key: const Key('scan-button'),
                onPressed: () async {
                  try {
                    if(!_test) {
                      _barcode = await scanBarcode();
                    }

                    if(_barcode.isNotEmpty){
                      final result = await Provider.of<NutritionPlansProvider>(context, listen: false)
                          .searchIngredientWithCode(_barcode);

                      if(result != null){
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            key: const Key('found-dialog'),
                            title: Text(AppLocalizations.of(context).productFound),
                            content: Text(AppLocalizations.of(context).productFoundDescription(result.name)),

                            actions: [
                              TextButton(
                                key: const Key('found-dialog-confirm-button'),
                                child: Text(MaterialLocalizations.of(context).continueButtonLabel),
                                onPressed: () {
                                  _ingredientController.text = result.name;
                                  _ingredientIdController.text = result.id.toString();
                                  Navigator.of(ctx).pop();
                                },
                              ),
                              TextButton(
                                key: const Key('found-dialog-close-button'),
                                child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                              )
                            ],
                          ),
                        );

                      }else{
                        //nothing is matching barcode
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            key: const Key('notFound-dialog'),
                            title: Text(AppLocalizations.of(context).productNotFound),
                            content:Text(AppLocalizations.of(context).productNotFoundDescription(_barcode),),
                            actions: [
                              TextButton(
                                key: const Key('notFound-dialog-close-button'),
                                child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                              )
                            ],
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    showErrorDialog(e, context);
                  }
                },
                child: Text(AppLocalizations.of(context).scanBarcode)

            ),
            TextFormField(
              key: const Key('field-weight'),
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
              key: const Key(SUBMIT_BUTTON_KEY_NAME),
              child: Text(AppLocalizations.of(context).save),
              onPressed: () async {
                if (!_form.currentState!.validate()) {
                  return;
                }
                _form.currentState!.save();
                _mealItem.ingredientId = int.parse(_ingredientIdController.text);

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
            if (_listMealItems.isNotEmpty) const SizedBox(height: 10.0),
            Container(
              child: Text(AppLocalizations.of(context).recentlyUsedIngredients),
              padding: const EdgeInsets.all(10.0),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _listMealItems.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        _ingredientController.text = _listMealItems[index].ingredientObj.name;
                        _ingredientIdController.text =
                            _listMealItems[index].ingredientObj.id.toString();
                        _amountController.text = _listMealItems[index].amount.toStringAsFixed(0);
                        _mealItem.ingredientId = _listMealItems[index].ingredientId;
                        _mealItem.amount = _listMealItems[index].amount;
                      },
                      title: Text(_listMealItems[index].ingredientObj.name),
                      subtitle: Text('${_listMealItems[index].amount.toStringAsFixed(0)}$unit'),
                      trailing: const Icon(Icons.copy),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class IngredientLogForm extends StatelessWidget {
  late MealItem _mealItem;
  final NutritionalPlan _plan;

  final _form = GlobalKey<FormState>();
  final _ingredientController = TextEditingController();
  final _ingredientIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  IngredientLogForm(this._plan) {
    _mealItem = MealItem.empty();
    _dateController.text = toDate(DateTime.now())!;
  }

  @override
  Widget build(BuildContext context) {
    final diaryEntries = _plan.logs;
    final String unit = AppLocalizations.of(context).g;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          children: [
            IngredientTypeahead(_ingredientIdController, _ingredientController),
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
            TextFormField(
              readOnly: true, // Stop keyboard from appearing
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).date,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              enableInteractiveSelection: false,
              controller: _dateController,
              onTap: () async {
                // Show Date Picker Here
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(DateTime.now().year - 10),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  _dateController.text = toDate(pickedDate)!;
                }
              },
              onSaved: (newValue) {
                _dateController.text = newValue!;
              },
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).save),
              onPressed: () async {
                if (!_form.currentState!.validate()) {
                  return;
                }
                _form.currentState!.save();
                _mealItem.ingredientId = int.parse(_ingredientIdController.text);

                try {
                  Provider.of<NutritionPlansProvider>(context, listen: false).logIngredentToDiary(
                      _mealItem, _plan.id!, DateTime.parse(_dateController.text));
                } on WgerHttpException catch (error) {
                  showHttpExceptionErrorDialog(error, context);
                } catch (error) {
                  showErrorDialog(error, context);
                }
                Navigator.of(context).pop();
              },
            ),
            if (diaryEntries.isNotEmpty) const SizedBox(height: 10.0),
            Container(
              child: Text(AppLocalizations.of(context).recentlyUsedIngredients),
              padding: const EdgeInsets.all(10.0),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: diaryEntries.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        _ingredientController.text = diaryEntries[index].ingredientObj.name;
                        _ingredientIdController.text =
                            diaryEntries[index].ingredientObj.id.toString();
                        _amountController.text = diaryEntries[index].amount.toStringAsFixed(0);
                        _mealItem.ingredientId = diaryEntries[index].ingredientId;
                        _mealItem.amount = diaryEntries[index].amount;
                      },
                      title: Text(_plan.logs[index].ingredientObj.name),
                      subtitle: Text('${diaryEntries[index].amount.toStringAsFixed(0)}$unit'),
                      trailing: const Icon(Icons.copy),
                    ),
                  );
                },
              ),
            )
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
            key: const Key('field-description'),
            decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
            controller: _descriptionController,
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              _plan.description = newValue!;
            },
          ),
          ElevatedButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
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
