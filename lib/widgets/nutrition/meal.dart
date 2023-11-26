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
import 'package:wger/helpers/misc.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/helpers.dart';

class MealWidget extends StatefulWidget {
  final Meal _meal;
  final List<MealItem> _listMealItems;

  const MealWidget(
    this._meal,
    this._listMealItems,
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
      padding: const EdgeInsets.all(3),
      child: Card(
        child: Column(
          children: [
            DismissibleMealHeader(_expanded, _toggleExpanded, meal: widget._meal),
            if (_expanded)
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      // Delete the meal
                      Provider.of<NutritionPlansProvider>(context, listen: false)
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
                    icon: const Icon(Icons.delete),
                  ),
                  if (widget._meal.mealItems.isNotEmpty)
                    Ink(
                      decoration: ShapeDecoration(
                        color: Theme.of(context).primaryColor, //wgerPrimaryButtonColor,
                        shape: const CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.history_edu),
                        color: Colors.white,
                        onPressed: () {
                          Provider.of<NutritionPlansProvider>(context, listen: false)
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
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
            if (_expanded) const Divider(),
            ...widget._meal.mealItems.map((item) => MealItemWidget(item, _expanded)),
            OutlinedButton(
              child: Text(AppLocalizations.of(context).addIngredient),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    AppLocalizations.of(context).addIngredient,
                    MealItemForm(widget._meal, widget._listMealItems),
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

  const MealItemWidget(this._item, this._expanded);

  @override
  Widget build(BuildContext context) {
    // TODO(x): add real support for weight units
    /*
    String unit = _item.weightUnitId == null
        ? AppLocalizations.of(context).g
        : _item.weightUnitObj!.weightUnit.name;

     */
    final String unit = AppLocalizations.of(context).g;
    final values = _item.nutritionalValues;

    return ListTile(
      leading: _item.ingredientObj.image != null
          ? GestureDetector(
              child: CircleAvatar(backgroundImage: NetworkImage(_item.ingredientObj.image!.image)),
              onTap: () async {
                if (_item.ingredientObj.image!.objectUrl != '') {
                  return launchURL(_item.ingredientObj.image!.objectUrl, context);
                } else {
                  return;
                }
              },
            )
          : const CircleIconAvatar(Icon(Icons.image, color: Colors.grey)),
      title: Text(
        '${_item.amount.toStringAsFixed(0)}$unit ${_item.ingredientObj.name}',
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [if (_expanded) ...getMutedNutritionalValues(values, context)],
      ),
      trailing: _expanded
          ? IconButton(
              icon: const Icon(Icons.delete),
              iconSize: ICON_SIZE_SMALL,
              onPressed: () {
                // Delete the meal item
                Provider.of<NutritionPlansProvider>(context, listen: false).deleteMealItem(_item);

                // and inform the user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                    AppLocalizations.of(context).successfullyDeleted,
                    textAlign: TextAlign.center,
                  )),
                );
              },
            )
          : const SizedBox(),
    );
  }
}

class DismissibleMealHeader extends StatelessWidget {
  final bool _expanded;
  final Function _toggle;

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
      background: Container(
        color: Theme.of(context).primaryColor, //wgerPrimaryButtonColor,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).logMeal,
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(
              Icons.history_edu,
              color: Colors.white,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Delete
        if (direction == DismissDirection.startToEnd) {
          Provider.of<NutritionPlansProvider>(context, listen: false).logMealToDiary(_meal);
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
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.inversePrimary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_meal.name != '')
              Text(
                _meal.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _meal.time!.format(context),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: _expanded ? const Icon(Icons.unfold_less) : const Icon(Icons.unfold_more),
                  onPressed: () {
                    _toggle();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
