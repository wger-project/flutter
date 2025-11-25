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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/nutrition/meal.dart';
import 'package:wger/widgets/nutrition/nutrition_tiles.dart';

class LogMealArguments {
  final Meal meal;
  final bool popTwice;

  const LogMealArguments(this.meal, this.popTwice);
}

class LogMealScreen extends StatefulWidget {
  const LogMealScreen();

  static const routeName = '/log-meal';

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  double portionPct = 100;
  final _dateController = TextEditingController(text: '');
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _timeController.text = timeToString(TimeOfDay.now())!;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);
    final i18n = AppLocalizations.of(context);

    final args = ModalRoute.of(context)!.settings.arguments as LogMealArguments;
    final meal = args.meal.copyWith(
      mealItems: args.meal.mealItems
          .map((mealItem) => mealItem.copyWith(amount: mealItem.amount * portionPct / 100))
          .toList(),
    );

    if (_dateController.text.isEmpty) {
      _dateController.text = dateFormat.format(DateTime.now());
    }

    return Scaffold(
      appBar: AppBar(title: Text(i18n.logMeal)),
      body: Consumer<NutritionPlansProvider>(
        builder: (context, nutritionProvider, child) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              children: [
                Text(
                  meal.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (meal.mealItems.isEmpty)
                  ListTile(title: Text(i18n.noIngredientsDefined))
                else
                  Column(
                    children: [
                      const DiaryheaderTile(),
                      ...meal.mealItems.map(
                        (item) => MealItemEditableFullTile(item, viewMode.withAllDetails, false),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Portion: ${portionPct.round()} %',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Slider.adaptive(
                        min: 0,
                        max: 150,
                        divisions: 30,
                        onChanged: (value) => setState(() => portionPct = value),
                        value: portionPct,
                      ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
                    Expanded(
                      child: TextFormField(
                        key: const ValueKey('field-date'),
                        readOnly: true,
                        decoration: InputDecoration(labelText: i18n.date),
                        enableInteractiveSelection: false,
                        controller: _dateController,
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 3000)),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            _dateController.text = dateFormat.format(pickedDate);
                          }
                        },
                        onSaved: (newValue) {
                          _dateController.text = newValue!;
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
                    Expanded(
                      child: TextFormField(
                        key: const ValueKey('field-time'),
                        readOnly: true,
                        decoration: InputDecoration(labelText: i18n.time),
                        controller: _timeController,
                        onTap: () async {
                          // Open time picker
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                          );

                          if (pickedTime != null) {
                            _timeController.text = timeToString(pickedTime)!;
                          }
                        },
                        onSaved: (newValue) {
                          _timeController.text = newValue!;
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (meal.mealItems.isNotEmpty)
                      TextButton(
                        child: Text(i18n.save),
                        onPressed: () async {
                          final loggedDate = dateFormat.parse(
                            '${_dateController.text} ${_timeController.text}',
                          );
                          await Provider.of<NutritionPlansProvider>(
                            context,
                            listen: false,
                          ).logMealToDiary(meal, loggedDate);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  i18n.mealLogged,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );

                            Navigator.of(context).pop();
                            if (args.popTwice) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                      ),
                    TextButton(
                      child: Text(
                        MaterialLocalizations.of(context).cancelButtonLabel,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
