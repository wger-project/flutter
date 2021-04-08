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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/nutrition/forms.dart';

class MealWidget extends StatefulWidget {
  final Meal _meal;

  MealWidget(
    this._meal,
  );

  @override
  _MealWidgetState createState() => _MealWidgetState();
}

class _MealWidgetState extends State<MealWidget> {
  bool _expanded = false;
  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      child: Card(
        child: Column(
          children: [
            DismissibleMealHeader(_expanded, _toggleExpanded, meal: widget._meal),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MutedText(AppLocalizations.of(context)!.energy),
                    MutedText(AppLocalizations.of(context)!.protein),
                    MutedText(AppLocalizations.of(context)!.carbohydrates),
                    MutedText(AppLocalizations.of(context)!.fat),
                  ],
                ),
              ),
            ...widget._meal.mealItems.map((item) => MealItemWidget(item, _expanded)).toList(),
            OutlinedButton(
              child: Text(AppLocalizations.of(context)!.addIngredient),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    AppLocalizations.of(context)!.addIngredient,
                    MealItemForm(widget._meal),
                    true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MealItemWidget extends StatelessWidget {
  final bool _expanded;
  final MealItem _item;

  MealItemWidget(this._item, this._expanded);

  @override
  Widget build(BuildContext context) {
    String unit = _item.weightUnitId == null
        ? AppLocalizations.of(context)!.g
        : _item.weightUnitObj!.weightUnit.name;
    final values = _item.nutritionalValues;

    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Text(
                  '${_item.amount.toStringAsFixed(0)}$unit ${_item.ingredientObj.name}',
                  overflow: TextOverflow.ellipsis,
                )),
                if (_expanded)
                  IconButton(
                    icon: Icon(Icons.delete),
                    iconSize: ICON_SIZE_SMALL,
                    onPressed: () {
                      // Delete the meal item
                      Provider.of<Nutrition>(context, listen: false).deleteMealItem(_item);

                      // and inform the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                          AppLocalizations.of(context)!.successfullyDeleted,
                          textAlign: TextAlign.center,
                        )),
                      );
                    },
                  ),
              ],
            ),
          ),
          if (_expanded)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MutedText(
                    '${values.energy.toStringAsFixed(0)} ${AppLocalizations.of(context)!.kcal}'),
                MutedText('${values.protein.toStringAsFixed(0)}${AppLocalizations.of(context)!.g}'),
                MutedText(
                    '${values.carbohydrates.toStringAsFixed(0)}${AppLocalizations.of(context)!.g}'),
                MutedText('${values.fat.toStringAsFixed(0)}${AppLocalizations.of(context)!.g}'),
              ],
            ),
        ],
      ),
    );
  }
}

class DismissibleMealHeader extends StatelessWidget {
  final bool _expanded;
  final _toggle;

  const DismissibleMealHeader(
    this._expanded,
    this._toggle, {
    required Meal meal,
  }) : _meal = meal;

  final Meal _meal;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        Navigator.pushNamed(
          context,
          FormScreen.routeName,
          arguments: FormScreenArguments(
            AppLocalizations.of(context)!.edit,
            MealForm(_meal.planId, _meal),
          ),
        );
      },
      child: Dismissible(
        key: Key(_meal.id.toString()),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _meal.time != null
                  ? Text(
                      _meal.time.format(context),
                      style: Theme.of(context).textTheme.headline5,
                    )
                  : Text(''),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: _expanded ? Icon(Icons.expand_less) : Icon(Icons.expand_more),
                onPressed: () {
                  _toggle();
                },
              ),
            ],
          ),
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
          color: wgerPrimaryButtonColor, //Theme.of(context).primaryColor,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
            Provider.of<Nutrition>(context, listen: false).deleteMeal(_meal);

            // and inform the user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.successfullyDeleted,
                  textAlign: TextAlign.center,
                ),
              ),
            );

            // Log meal
          } else {
            Provider.of<Nutrition>(context, listen: false).logMealToDiary(_meal);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.mealLogged,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return false;
        },
      ),
    );
  }
}
