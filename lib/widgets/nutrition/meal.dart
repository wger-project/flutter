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
            DismissibleMealHeader(_expanded, _toggleExpanded,
                meal: widget._meal),
            if (_expanded)
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      // Delete the meal
                      Provider.of<NutritionPlansProvider>(context,
                              listen: false)
                          .deleteMeal(widget._meal);

                      // and inform the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).successfullyDeleted,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.delete),
                  ),
                  if (widget._meal.mealItems.length > 0)
                    Ink(
                      decoration: const ShapeDecoration(
                        color: wgerPrimaryButtonColor,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.history_edu),
                        color: Colors.white,
                        onPressed: () {
                          Provider.of<NutritionPlansProvider>(context,
                                  listen: false)
                              .logMealToDiary(widget._meal);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context).mealLogged,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        FormScreen.routeName,
                        arguments: FormScreenArguments(
                          AppLocalizations.of(context).edit,
                          MealForm(widget._meal.planId, widget._meal),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit),
                  ),
                ],
              ),
            Divider(),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      child: MutedText(
                        AppLocalizations.of(context).energy,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: MutedText(
                        AppLocalizations.of(context).protein,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: MutedText(
                        AppLocalizations.of(context).carbohydrates,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: MutedText(
                        AppLocalizations.of(context).fat,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ...widget._meal.mealItems
                .map((item) => MealItemWidget(item, _expanded))
                .toList(),
            OutlinedButton(
              child: Text(AppLocalizations.of(context).addIngredient),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    AppLocalizations.of(context).addIngredient,
                    MealItemForm(widget._meal),
                    hasListView: true,
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
    // TODO: add real support for weight units
    /*
    String unit = _item.weightUnitId == null
        ? AppLocalizations.of(context).g
        : _item.weightUnitObj!.weightUnit.name;

     */
    String unit = AppLocalizations.of(context).g;
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
                      Provider.of<NutritionPlansProvider>(context,
                              listen: false)
                          .deleteMealItem(_item);

                      // and inform the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                          AppLocalizations.of(context).successfullyDeleted,
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
              children: [
                Expanded(
                  child: MutedText(
                    '${values.energy.toStringAsFixed(0)} ${AppLocalizations.of(context).kcal}',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: MutedText(
                    '${values.protein.toStringAsFixed(0)}${AppLocalizations.of(context).g}',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: MutedText(
                    '${values.carbohydrates.toStringAsFixed(0)}${AppLocalizations.of(context).g}',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: MutedText(
                    '${values.fat.toStringAsFixed(0)}${AppLocalizations.of(context).g}',
                    textAlign: TextAlign.center,
                  ),
                ),
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
    return Dismissible(
      key: Key(_meal.id.toString()),
      direction: DismissDirection.startToEnd,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _meal.time!.format(context),
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon:
                  _expanded ? Icon(Icons.unfold_less) : Icon(Icons.unfold_more),
              onPressed: () {
                _toggle();
              },
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
              AppLocalizations.of(context).logMeal,
              style: TextStyle(color: Colors.white),
            ),
            Icon(
              Icons.history_edu,
              color: Colors.white,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Delete
        if (direction == DismissDirection.startToEnd) {
          Provider.of<NutritionPlansProvider>(context, listen: false)
              .logMealToDiary(_meal);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).mealLogged,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return false;
      },
    );
  }
}
