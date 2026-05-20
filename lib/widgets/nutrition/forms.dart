/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/ingredient_weight_unit.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/widgets/core/datetime_input.dart';
import 'package:wger/widgets/core/decimal_input.dart';
import 'package:wger/widgets/nutrition/helpers.dart';
import 'package:wger/widgets/nutrition/nutrition_tiles.dart';
import 'package:wger/widgets/nutrition/widgets.dart';

class MealForm extends ConsumerWidget {
  late final Meal _meal;
  final String _planId;

  final _form = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  MealForm(this._planId, [meal]) {
    _meal = meal ?? Meal(plan: _planId, time: TimeOfDay.fromDateTime(DateTime.now()));
    _nameController.text = _meal.name;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCreating = _meal.id == null;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          children: [
            TimeInputWidget(
              key: const Key('field-time'),
              value: _meal.time,
              labelText: AppLocalizations.of(context).time,
              onChanged: (time) => _meal.time = time,
            ),
            TextFormField(
              maxLength: 25,
              key: const Key('field-name'),
              decoration: InputDecoration(labelText: AppLocalizations.of(context).name),
              controller: _nameController,
              onSaved: (newValue) {
                _meal.name = newValue as String;
              },
            ),
            ElevatedButton(
              key: const Key(SUBMIT_BUTTON_KEY_NAME),
              child: Text(AppLocalizations.of(context).save),
              onPressed: () {
                if (!_form.currentState!.validate()) {
                  return;
                }
                _form.currentState!.save();

                final notifier = ref.read(nutritionProvider.notifier);
                isCreating ? notifier.addMeal(_meal, _planId) : notifier.editMeal(_meal);

                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget getMealItemForm(
  Meal meal,
  List<MealItem> recent, [
  String? barcode,
  bool? test,
]) {
  return IngredientForm(
    // The recent list is ephemeral display data — planId isn't used for
    // persistence, so an empty sentinel is fine.
    recent: recent.map((e) => LogItem.fromMealItem(e, '', e.mealId)).toList(),
    onSave: (BuildContext context, WidgetRef ref, MealItem mealItem, DateTime? dt) {
      mealItem.mealId = meal.id!;
      ref.read(nutritionProvider.notifier).addMealItem(mealItem, meal);
    },
    barcode: barcode ?? '',
    test: test ?? false,
    withDate: false,
  );
}

Widget getIngredientLogForm(NutritionalPlan plan) {
  return IngredientForm(
    recent: plan.dedupDiaryEntries,
    onSave: (BuildContext context, WidgetRef ref, MealItem mealItem, DateTime? dt) {
      ref.read(nutritionProvider.notifier).logIngredientToDiary(mealItem, plan.id!, dt);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).ingredientLogged,
            textAlign: TextAlign.center,
          ),
        ),
      );
    },
    withDate: true,
  );
}

/// IngredientForm is a form that lets the user pick an ingredient (and amount) to
/// log to the diary or to add to a meal.
class IngredientForm extends ConsumerStatefulWidget {
  final Function(BuildContext context, WidgetRef ref, MealItem mealItem, DateTime? dt) onSave;
  final List<LogItem> recent;
  final bool withDate;
  final String barcode;
  final bool test;

  const IngredientForm({
    required this.recent,
    required this.onSave,
    required this.withDate,
    this.barcode = '',
    this.test = false,
  });

  @override
  ConsumerState<IngredientForm> createState() => IngredientFormState();
}

class IngredientFormState extends ConsumerState<IngredientForm> {
  final _form = GlobalKey<FormState>();
  final _ingredientController = TextEditingController();
  final _ingredientIdController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  final _mealItem = MealItem.empty();
  var _searchQuery = ''; // copy from typeahead. for filtering suggestions
  List<IngredientWeightUnit> _weightUnits = [];
  IngredientWeightUnit? _selectedWeightUnit;

  @override
  void dispose() {
    _ingredientController.dispose();
    _ingredientIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  TextEditingController get ingredientIdController => _ingredientIdController;

  MealItem get mealItem => _mealItem;

  void selectIngredient(Ingredient ingredient, num? amount) {
    setState(() {
      _mealItem.ingredient = ingredient;
      _mealItem.ingredientId = ingredient.id;
      _ingredientController.text = ingredient.name;
      _ingredientIdController.text = ingredient.id.toString();
      if (amount != null) {
        _amountController.text = amount.toStringAsFixed(0);
        _mealItem.amount = amount;
      }
      _selectedWeightUnit = null;
      _mealItem.weightUnitId = null;
      _mealItem.weightUnitObj = null;
      _weightUnits = ingredient.weightUnits;
    });
  }

  // note: does not reset text search and amount inputs
  void unSelectIngredient() {
    setState(() {
      _mealItem.ingredientId = 0;
      _ingredientIdController.text = '';
    });
  }

  void updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    final String unit = i18n.g;
    final queryLower = _searchQuery.toLowerCase();
    final suggestions = widget.recent
        .where((e) => e.ingredient.name.toLowerCase().contains(queryLower))
        .toList();
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

    return Container(
      margin: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: Column(
          children: [
            IngredientTypeahead(
              _ingredientIdController,
              _ingredientController,
              barcode: widget.barcode,
              test: widget.test,
              selectIngredient: selectIngredient,
              onDeselectIngredient: unSelectIngredient,
              onUpdateSearchQuery: updateSearchQuery,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('field-weight'),
                    decoration: InputDecoration(
                      labelText: i18n.weight,
                      suffix: _weightUnits.isNotEmpty
                          ? DropdownButton<int?>(
                              value: _selectedWeightUnit?.id,
                              underline: const SizedBox(),
                              isDense: true,
                              items: [
                                DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text(i18n.g),
                                ),
                                ..._weightUnits.map(
                                  (unit) => DropdownMenuItem<int?>(
                                    value: unit.id,
                                    child: Text('${unit.name} (${unit.grams}g)'),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  if (value == null) {
                                    _selectedWeightUnit = null;
                                    _mealItem.weightUnitId = null;
                                    _mealItem.weightUnitObj = null;
                                  } else {
                                    _selectedWeightUnit = _weightUnits.firstWhere(
                                      (u) => u.id == value,
                                    );
                                    _mealItem.weightUnitId = value;
                                    _mealItem.weightUnitObj = _selectedWeightUnit;
                                  }
                                });
                              },
                            )
                          : Text(i18n.g),
                    ),
                    controller: _amountController,
                    keyboardType: textInputTypeDecimal,
                    onChanged: (value) {
                      setState(() {
                        final v = double.tryParse(value);
                        if (v != null) {
                          _mealItem.amount = v;
                        }
                      });
                    },
                    onSaved: (value) {
                      _mealItem.amount = numberFormat.parse(value!);
                    },
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return i18n.enterValue;
                      }
                      final parsed = double.tryParse(text);
                      if (parsed == null) {
                        return i18n.enterValidNumber;
                      }

                      if (parsed < 1 || parsed > 1000) {
                        return i18n.formMinMaxValues(1, 1000);
                      }
                      return null;
                    },
                  ),
                ),
                if (widget.withDate)
                  Expanded(
                    child: DateInputWidget(
                      value: _date,
                      labelText: i18n.date,
                      firstDate: DateTime(DateTime.now().year - 10),
                      lastDate: DateTime.now(),
                      onChanged: (date) => _date = date,
                    ),
                  ),
                if (widget.withDate)
                  Expanded(
                    child: TimeInputWidget(
                      key: const Key('field-time'),
                      value: _time,
                      labelText: i18n.time,
                      onChanged: (time) => _time = time,
                    ),
                  ),
              ],
            ),
            if (ingredientIdController.text.isNotEmpty && _amountController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Macros preview', // TODO fix l10n
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    MealItemValuesTile(
                      ingredient: _mealItem.ingredient,
                      nutritionalValues: _mealItem.nutritionalValues,
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              key: const Key(SUBMIT_BUTTON_KEY_NAME),
              child: Text(AppLocalizations.of(context).save),
              onPressed: () {
                if (!_form.currentState!.validate()) {
                  return;
                }
                _form.currentState!.save();
                _mealItem.ingredientId = int.parse(_ingredientIdController.text);

                final loggedDate = DateTime(
                  _date.year,
                  _date.month,
                  _date.day,
                  _time.hour,
                  _time.minute,
                );
                widget.onSave(context, ref, _mealItem, loggedDate);

                Navigator.of(context).pop();
              },
            ),
            if (suggestions.isNotEmpty) const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(AppLocalizations.of(context).recentlyUsedIngredients),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  void select() {
                    selectIngredient(
                      suggestions[index].ingredient,
                      suggestions[index].amount,
                    );
                  }

                  return Card(
                    child: ListTile(
                      onTap: select,
                      title: Text(
                        suggestions[index].weightUnitObj != null
                            ? '${suggestions[index].ingredient.name} (${suggestions[index].amount.toStringAsFixed(0)} × ${suggestions[index].weightUnitObj!.name})'
                            : '${suggestions[index].ingredient.name} (${suggestions[index].amount.toStringAsFixed(0)}$unit)',
                      ),
                      subtitle: Text(
                        getShortNutritionValues(
                          suggestions[index].ingredient.nutritionalValues,
                          context,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              showIngredientDetails(
                                context,
                                ref,
                                suggestions[index].ingredient,
                                select: select,
                              );
                            },
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.copy),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum GoalType {
  meals('From meals'),
  basic('Basic'),
  advanced('Advanced')
  ;

  const GoalType(this.label);

  final String label;

  String getI18nLabel(BuildContext context) {
    switch (this) {
      case GoalType.meals:
        return AppLocalizations.of(context).goalTypeMeals;
      case GoalType.basic:
        return AppLocalizations.of(context).goalTypeBasic;
      case GoalType.advanced:
        return AppLocalizations.of(context).goalTypeAdvanced;
    }
  }
}

class PlanForm extends ConsumerStatefulWidget {
  // Mutated in-place by descendant onSaved/onTap callbacks (e.g. setting
  // [NutritionalPlan.description] or [startDate]); the field reference itself
  // is fixed at construction so the widget stays @immutable-compatible.
  final NutritionalPlan _plan;

  PlanForm([NutritionalPlan? plan]) : _plan = plan ?? NutritionalPlan.empty();

  @override
  ConsumerState<PlanForm> createState() => _PlanFormState();
}

class _PlanFormState extends ConsumerState<PlanForm> {
  final _form = GlobalKey<FormState>();

  GoalType _goalType = GoalType.meals;
  GoalType? selectedGoal;

  @override
  void initState() {
    super.initState();

    if (widget._plan.hasAnyAdvancedGoals) {
      _goalType = GoalType.advanced;
    } else if (widget._plan.hasAnyGoals) {
      _goalType = GoalType.basic;
    } else {
      _goalType = GoalType.meals;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);
    final isCreating = widget._plan.id == null;

    return Form(
      key: _form,
      child: ListView(
        children: [
          // Description
          TextFormField(
            key: const Key('field-description'),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).description,
            ),
            controller: TextEditingController(
              text: widget._plan.description,
            ),
            onSaved: (newValue) {
              widget._plan.description = newValue!;
            },
          ),
          // Start Date
          TextFormField(
            key: const Key('field-start-date'),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).startDate,
              suffixIcon: const Icon(
                Icons.calendar_today,
                key: Key('calendarIcon'),
              ),
            ),
            controller: TextEditingController(
              text: dateFormat.format(widget._plan.startDate),
            ),
            readOnly: true,
            onTap: () async {
              // Stop keyboard from appearing
              FocusScope.of(context).requestFocus(FocusNode());

              // Open date picker
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: widget._plan.startDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                setState(() {
                  widget._plan.startDate = pickedDate;
                });
              }
            },
            validator: (value) {
              if (widget._plan.endDate != null &&
                  widget._plan.endDate!.isBefore(widget._plan.startDate)) {
                return 'End date must be after start date';
              }

              return null;
            },
          ),
          // End Date
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('field-end-date'),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).endDate,
                    helperText:
                        'Tip: only for athletes with contest deadlines.  Most users benefit from flexibility',
                    suffixIcon: widget._plan.endDate == null
                        ? const Icon(
                            Icons.calendar_today,
                            key: Key('calendarIcon'),
                          )
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear end date',
                            onPressed: () {
                              setState(() {
                                widget._plan.endDate = null;
                              });
                            },
                          ),
                  ),
                  controller: TextEditingController(
                    text: widget._plan.endDate == null
                        ? ''
                        : dateFormat.format(widget._plan.endDate!),
                  ),
                  readOnly: true,
                  onTap: () async {
                    // Stop keyboard from appearing
                    FocusScope.of(context).requestFocus(FocusNode());

                    // Open date picker
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: widget._plan.endDate,
                      // end must be after start
                      firstDate: widget._plan.startDate.add(const Duration(days: 1)),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        widget._plan.endDate = pickedDate;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).onlyLogging),
            subtitle: Text(AppLocalizations.of(context).onlyLoggingHelpText),
            value: widget._plan.onlyLogging,
            onChanged: (value) {
              setState(() {
                widget._plan.onlyLogging = value;
              });
            },
          ),
          Row(
            children: [
              Text(
                AppLocalizations.of(context).goalMacro,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<GoalType>(
                  initialValue: _goalType,
                  items: GoalType.values
                      .map(
                        (e) => DropdownMenuItem<GoalType>(
                          value: e,
                          child: Text(e.getI18nLabel(context)),
                        ),
                      )
                      .toList(),
                  onChanged: (GoalType? g) {
                    setState(() {
                      if (g == null) {
                        return;
                      }
                      switch (g) {
                        case GoalType.meals:
                          widget._plan.goalEnergy = null;
                          widget._plan.goalProtein = null;
                          widget._plan.goalCarbohydrates = null;
                          widget._plan.goalFat = null;
                          widget._plan.goalFiber = null;
                        case GoalType.basic:
                          widget._plan.goalFiber = null;
                          break;
                        default:
                          break;
                      }
                      _goalType = g;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_goalType == GoalType.basic || _goalType == GoalType.advanced)
            Column(
              children: [
                DecimalInputWidget(
                  key: const Key('field-goal-energy'),
                  value: widget._plan.goalEnergy,
                  labelText: AppLocalizations.of(context).goalEnergy,
                  suffixText: AppLocalizations.of(context).kcal,
                  onChanged: (value) => widget._plan.goalEnergy = value,
                ),
                DecimalInputWidget(
                  key: const Key('field-goal-protein'),
                  value: widget._plan.goalProtein,
                  labelText: AppLocalizations.of(context).goalProtein,
                  suffixText: AppLocalizations.of(context).g,
                  onChanged: (value) => widget._plan.goalProtein = value,
                ),
                DecimalInputWidget(
                  key: const Key('field-goal-carbohydrates'),
                  value: widget._plan.goalCarbohydrates,
                  labelText: AppLocalizations.of(context).goalCarbohydrates,
                  suffixText: AppLocalizations.of(context).g,
                  onChanged: (value) => widget._plan.goalCarbohydrates = value,
                ),
                DecimalInputWidget(
                  key: const Key('field-goal-fat'),
                  value: widget._plan.goalFat,
                  labelText: AppLocalizations.of(context).goalFat,
                  suffixText: AppLocalizations.of(context).g,
                  onChanged: (value) => widget._plan.goalFat = value,
                ),
              ],
            ),

          if (_goalType == GoalType.advanced)
            DecimalInputWidget(
              key: const Key('field-goal-fiber'),
              value: widget._plan.goalFiber,
              labelText: AppLocalizations.of(context).goalFiber,
              suffixText: AppLocalizations.of(context).g,
              onChanged: (value) => widget._plan.goalFiber = value,
            ),
          ElevatedButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              // Validate and save the current values to the plan
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              // Save to DB
              final notifier = ref.read(nutritionProvider.notifier);
              if (!isCreating) {
                await notifier.editPlan(widget._plan);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                final saved = await notifier.addPlan(widget._plan);
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(
                    NutritionalPlanScreen.routeName,
                    arguments: saved,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
