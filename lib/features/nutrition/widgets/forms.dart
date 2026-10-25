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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/colors.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/core/number_input.dart';
import 'package:wger/core/snackbar.dart';
import 'package:wger/core/validators.dart';
import 'package:wger/core/widgets/datetime_input.dart';
import 'package:wger/core/widgets/decimal_input.dart';
import 'package:wger/core/widgets/form_submit_button.dart';
import 'package:wger/features/nutrition/models/ingredient.dart';
import 'package:wger/features/nutrition/models/ingredient_weight_unit.dart';
import 'package:wger/features/nutrition/models/log.dart';
import 'package:wger/features/nutrition/models/meal.dart';
import 'package:wger/features/nutrition/models/meal_item.dart';
import 'package:wger/features/nutrition/models/nutritional_plan.dart';
import 'package:wger/features/nutrition/models/nutritional_values.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/features/nutrition/screens/nutritional_plan_screen.dart';
import 'package:wger/features/nutrition/widgets/helpers.dart';
import 'package:wger/features/nutrition/widgets/ingredient_images.dart';
import 'package:wger/features/nutrition/widgets/widgets.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

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
            FormSubmitButton(
              key: const Key(SUBMIT_BUTTON_KEY_NAME),
              label: AppLocalizations.of(context).save,
              onPressed: () async {
                if (!_form.currentState!.validate()) {
                  return;
                }
                _form.currentState!.save();

                final notifier = ref.read(nutritionProvider.notifier);
                isCreating
                    ? await notifier.addMeal(_meal, _planId)
                    : await notifier.editMeal(_meal);

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
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
    // The recent list is ephemeral display data, planId isn't used for
    // persistence, so an empty sentinel is fine.
    recent: recent.map((e) => LogItem.fromMealItem(e, '', e.mealId)).toList(),
    onSave: (BuildContext context, WidgetRef ref, MealItem mealItem, DateTime? dt, String? mealId) {
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
    meals: plan.meals,
    onSave: (BuildContext context, WidgetRef ref, MealItem mealItem, DateTime? dt, String? mealId) {
      ref.read(nutritionProvider.notifier).logIngredientToDiary(mealItem, plan.id!, dt, mealId);
      showSnackbar(context, AppLocalizations.of(context).ingredientLogged, center: true);
    },
    withDate: true,
  );
}

/// IngredientForm is a form that lets the user pick an ingredient (and amount) to
/// log to the diary or to add to a meal.
class IngredientForm extends ConsumerStatefulWidget {
  final Function(
    BuildContext context,
    WidgetRef ref,
    MealItem mealItem,
    DateTime? dt,
    String? mealId,
  )
  onSave;
  final List<LogItem> recent;
  final bool withDate;
  final String barcode;
  final bool test;

  /// When not empty, the form offers to assign the entry to one of these meals
  final List<Meal> meals;

  const IngredientForm({
    required this.recent,
    required this.onSave,
    required this.withDate,
    this.barcode = '',
    this.test = false,
    this.meals = const [],
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
  String? _selectedMealId;

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

  void _selectWeightUnit(IngredientWeightUnit? unit) {
    setState(() {
      _selectedWeightUnit = unit;
      _mealItem.weightUnitId = unit?.id;
      _mealItem.weightUnitObj = unit;
    });
  }

  // note: does not reset text search and amount inputs
  void unSelectIngredient() {
    setState(() {
      _mealItem.ingredientId = 0;
      _ingredientIdController.text = '';
    });
  }

  /// Drops the selected ingredient and everything derived from it, keeping
  /// only the typed amount.
  void _clearIngredient() {
    setState(() {
      _mealItem.ingredient = null;
      _mealItem.ingredientId = 0;
      _ingredientController.text = '';
      _ingredientIdController.text = '';
      _searchQuery = '';
      _weightUnits = [];
    });
    _selectWeightUnit(null);
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
    // Drop suggestions whose ingredient is still being hydrated by PowerSync.
    // Without the row they would only render as "…", which is useless to pick.
    final suggestions = widget.recent
        .where((e) => e.ingredient?.name.toLowerCase().contains(queryLower) ?? false)
        .toList();
    final numberFormat = localizedNumberFormat(context);

    return Container(
      margin: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_mealItem.ingredient != null && _ingredientIdController.text.isNotEmpty)
                Padding(
                  key: const Key('selected-ingredient'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    spacing: 12,
                    children: [
                      ClipOval(
                        child: ColoredBox(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: SizedBox.square(
                            dimension: 64,
                            child: IngredientImageWidget(image: _mealItem.ingredient!.image),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mealItem.ingredient!.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              '${i18n.kcalValue(_mealItem.ingredient!.energy.toString())} / 100 ${i18n.g}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => showIngredientDetails(context, ref, _mealItem.ingredient!),
                      ),
                      IconButton(
                        key: const Key('clear-ingredient'),
                        icon: const Icon(Icons.close),
                        tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                        onPressed: _clearIngredient,
                      ),
                    ],
                  ),
                )
              else
                IngredientTypeahead(
                  _ingredientIdController,
                  _ingredientController,
                  barcode: widget.barcode,
                  test: widget.test,
                  selectIngredient: selectIngredient,
                  onDeselectIngredient: unSelectIngredient,
                  onUpdateSearchQuery: updateSearchQuery,
                ),
              TextFormField(
                key: const Key('field-weight'),
                decoration: InputDecoration(
                  labelText: i18n.weight,
                  suffixText: _selectedWeightUnit != null
                      ? '× ${_selectedWeightUnit!.name}'
                      : i18n.g,
                ),
                controller: _amountController,
                keyboardType: textInputTypeDecimal,
                inputFormatters: [
                  LocalizedDecimalInputFormatter(numberFormat.symbols.DECIMAL_SEP),
                ],
                onChanged: (value) {
                  setState(() {
                    final v = numberFormat.tryParse(value);
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
                  final parsed = numberFormat.tryParse(text);
                  if (parsed == null) {
                    return i18n.enterValidNumber;
                  }

                  if (parsed < 1 || parsed > 1000) {
                    return i18n.formMinMaxValues(1, 1000);
                  }
                  return null;
                },
              ),
              if (_weightUnits.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(i18n.g),
                          selected: _selectedWeightUnit == null,
                          onSelected: (_) => _selectWeightUnit(null),
                        ),
                        ..._weightUnits.map(
                          (unit) => ChoiceChip(
                            label: Text('${unit.name} (${unit.grams}g)'),
                            selected: _selectedWeightUnit?.id == unit.id,
                            onSelected: (_) => _selectWeightUnit(unit),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_ingredientIdController.text.isNotEmpty &&
                  _amountController.text.isNotEmpty &&
                  _mealItem.ingredient != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: _MacrosSummary(
                    key: const Key('macros-summary'),
                    values: _mealItem.nutritionalValues,
                    grams: _selectedWeightUnit == null
                        ? null
                        : _mealItem.amount * _selectedWeightUnit!.grams,
                  ),
                ),
              if (widget.withDate)
                Row(
                  children: [
                    Expanded(
                      child: DateInputWidget(
                        value: _date,
                        labelText: i18n.date,
                        firstDate: DateTime(DateTime.now().year - 10),
                        lastDate: DateTime.now(),
                        onChanged: (date) => _date = date,
                      ),
                    ),
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
              if (widget.meals.isNotEmpty)
                DropdownButtonFormField<String?>(
                  key: const Key('field-meal'),
                  initialValue: _selectedMealId,
                  decoration: InputDecoration(labelText: i18n.meal),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(i18n.otherLogs),
                    ),
                    ...widget.meals.map(
                      (meal) => DropdownMenuItem<String?>(
                        value: meal.id,
                        child: Text(
                          meal.name.isNotEmpty ? meal.name : meal.time?.format(context) ?? '',
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _selectedMealId = value),
                ),
              FormSubmitButton(
                key: const Key(SUBMIT_BUTTON_KEY_NAME),
                label: AppLocalizations.of(context).save,
                onPressed: () async {
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
                  widget.onSave(context, ref, _mealItem, loggedDate, _selectedMealId);

                  Navigator.of(context).pop();
                },
              ),
              if (suggestions.isNotEmpty) const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Text(AppLocalizations.of(context).recentlyUsedIngredients),
              ),
              ListView.builder(
                itemCount: suggestions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  // ingredient is non-null here, the suggestions list above
                  // filters out items whose ingredient hasn't been hydrated.
                  final ingredient = suggestions[index].ingredient!;
                  void select() {
                    selectIngredient(
                      ingredient,
                      suggestions[index].amount,
                    );
                  }

                  return Card(
                    child: ListTile(
                      onTap: select,
                      title: Text(
                        suggestions[index].weightUnitObj != null
                            ? '${ingredient.name} (${suggestions[index].amount.toStringAsFixed(0)} × ${suggestions[index].weightUnitObj!.name})'
                            : '${ingredient.name} (${suggestions[index].amount.toStringAsFixed(0)}$unit)',
                      ),
                      subtitle: Text(
                        getShortNutritionValues(
                          ingredient.nutritionalValues,
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
                                ingredient,
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Energy of an entry and how it splits into the macronutrients.
class _MacrosSummary extends StatelessWidget {
  const _MacrosSummary({super.key, required this.values, this.grams});

  final NutritionalValues values;

  /// Weight in grams, shown when the amount is entered in another unit
  final num? grams;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Same color mapping as the macro pie chart
    final [carbsColor, proteinColor, fatColor] = chartColorPalette(3, theme.colorScheme);
    final macros = [
      (i18n.protein, values.protein, values.protein * ENERGY_PROTEIN, proteinColor),
      (
        i18n.carbohydrates,
        values.carbohydrates,
        values.carbohydrates * ENERGY_CARBOHYDRATES,
        carbsColor,
      ),
      (i18n.fat, values.fat, values.fat * ENERGY_FAT, fatColor),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: 6,
          children: [
            Text(values.energy.toStringAsFixed(0), style: theme.textTheme.headlineSmall),
            Text(i18n.kcal, style: theme.textTheme.bodyMedium),
            if (grams != null)
              Text(
                '· ${i18n.gValue(grams!.toStringAsFixed(0))}',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 2,
              children: [
                for (final (_, _, energy, color) in macros)
                  if ((energy * 10).round() > 0)
                    Expanded(
                      flex: (energy * 10).round(),
                      child: ColoredBox(color: color),
                    ),
              ],
            ),
          ),
        ),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            for (final (label, amount, _, color) in macros)
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: const SizedBox.square(dimension: 10),
                  ),
                  Text(
                    '$label ${i18n.gValue(amount.toStringAsFixed(0))}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

enum GoalType {
  meals('From meals'),
  basic('Basic'),
  advanced('Advanced');

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
            maxLength: NutritionalPlan.maxDescriptionChars,
            onSaved: (newValue) {
              widget._plan.description = newValue!;
            },
            validator: (value) {
              if (value != null && value.length > NutritionalPlan.maxDescriptionChars) {
                return AppLocalizations.of(
                  context,
                ).enterMaxCharacters(NutritionalPlan.maxDescriptionChars.toString());
              }
              return null;
            },
          ),
          // Start Date
          DateInputWidget(
            key: const Key('field-start-date'),
            value: widget._plan.startDate,
            labelText: AppLocalizations.of(context).startDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onChanged: (pickedDate) {
              setState(() {
                widget._plan.startDate = pickedDate;
              });
            },
            validator: (value) => validateDateRange(
              widget._plan.startDate,
              widget._plan.endDate,
              AppLocalizations.of(context),
            ),
          ),
          // End Date
          Row(
            children: [
              Expanded(
                child: DateInputWidget(
                  key: const Key('field-end-date'),
                  value: widget._plan.endDate,
                  labelText: AppLocalizations.of(context).endDate,
                  helperText:
                      'Tip: only for athletes with contest deadlines.  Most users benefit from flexibility',
                  firstDate: widget._plan.startDate.add(const Duration(days: 1)),
                  lastDate: DateTime(2100),
                  onChanged: (pickedDate) {
                    setState(() {
                      widget._plan.endDate = pickedDate;
                    });
                  },
                  onCleared: () {
                    setState(() {
                      widget._plan.endDate = null;
                    });
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
                  min: 0,
                  max: NutritionalPlan.maxGoalEnergy,
                  onChanged: (value) => widget._plan.goalEnergy = value,
                ),
                DecimalInputWidget(
                  key: const Key('field-goal-protein'),
                  value: widget._plan.goalProtein,
                  labelText: AppLocalizations.of(context).goalProtein,
                  suffixText: AppLocalizations.of(context).g,
                  min: 0,
                  max: NutritionalPlan.maxGoalProtein,
                  onChanged: (value) => widget._plan.goalProtein = value,
                ),
                DecimalInputWidget(
                  key: const Key('field-goal-carbohydrates'),
                  value: widget._plan.goalCarbohydrates,
                  labelText: AppLocalizations.of(context).goalCarbohydrates,
                  suffixText: AppLocalizations.of(context).g,
                  min: 0,
                  max: NutritionalPlan.maxGoalCarbohydrates,
                  onChanged: (value) => widget._plan.goalCarbohydrates = value,
                ),
                DecimalInputWidget(
                  key: const Key('field-goal-fat'),
                  value: widget._plan.goalFat,
                  labelText: AppLocalizations.of(context).goalFat,
                  suffixText: AppLocalizations.of(context).g,
                  min: 0,
                  max: NutritionalPlan.maxGoalFat,
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
              min: 0,
              max: NutritionalPlan.maxGoalFiber,
              onChanged: (value) => widget._plan.goalFiber = value,
            ),
          FormSubmitButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            label: AppLocalizations.of(context).save,
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
                    arguments: saved.id,
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
