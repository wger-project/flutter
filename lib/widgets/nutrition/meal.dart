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
import 'package:wger/locale/locales.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/providers/nutritional_plans.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/nutrition/forms.dart';

class MealWidget extends StatelessWidget {
  final Meal _meal;

  MealWidget(
    this._meal,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Column(
          children: [
            DismissibleMealHeader(meal: _meal),
            ..._meal.mealItems.map((item) => MealItemWidget(item)).toList(),
            OutlinedButton(
              child: Text('Add ingredient'),
              onPressed: () {
                showFormBottomSheet(context, 'Add ingredient', MealItemForm(_meal));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MealItemWidget extends StatelessWidget {
  final MealItem _item;

  MealItemWidget(this._item);

  @override
  Widget build(BuildContext context) {
    String unit = _item.weightUnit == null ? 'g' : _item.weightUnit.weightUnit.name;
    final values = _item.nutritionalValues;

    return Container(
      padding: EdgeInsets.all(5),
      child: Table(
        children: [
          TableRow(
            children: [
              Text('${_item.amount.toStringAsFixed(0)}$unit ${_item.ingredientObj.name}'),
              Text(
                  '${values["energy"].toStringAsFixed(0)} kcal / ${values["energyKj"].toStringAsFixed(0)} kJ'),
              Text('${values["protein"].toStringAsFixed(0)} g'),
              Text('${values["carbohydrates"].toStringAsFixed(0)} g'),
              Text('${values["fat"].toStringAsFixed(0)} g'),
            ],
          ),
        ],
      ),
    );
  }
}

class DismissibleMealHeader extends StatelessWidget {
  const DismissibleMealHeader({
    Key key,
    @required Meal meal,
  })  : _meal = meal,
        super(key: key);

  final Meal _meal;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(_meal.id.toString()),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.black12),
        padding: const EdgeInsets.all(10),
        child: Text(_meal.time.format(context)),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).accentColor,
        padding: EdgeInsets.only(right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ],
        ),
      ),
      background: Container(
        color: Theme.of(context).primaryColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Log this meal',
              style: TextStyle(color: Colors.white),
            ),
            Icon(
              Icons.bar_chart,
              color: Colors.white,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Delete
        if (direction == DismissDirection.endToStart) {
          // Delete the meal
          Provider.of<NutritionalPlans>(context, listen: false).deleteMeal(_meal);

          // and inform the user
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).successfullyDeleted,
                textAlign: TextAlign.center,
              ),
            ),
          );

          // Log meal
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text('Would log this meal'),
              actions: [
                TextButton(
                  child: Text("Close"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
        return false;
      },
    );
  }
}
