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
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/meal_item.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/log_meal_screen.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/helpers.dart';
import 'package:wger/widgets/nutrition/nutrition_tile.dart';
import 'package:wger/widgets/nutrition/nutrition_tiles.dart';
import 'package:wger/widgets/nutrition/widgets.dart';

enum viewMode {
  base, // just highlevel meal info (name, time)
  withIngredients, // + ingredients
  withAllDetails // + nutritional breakdown of ingredients, + logged today
}

class MealWidget extends StatefulWidget {
  final Meal _meal;
  final List<MealItem> _recentMealItems;
  final bool popTwice;
  final bool readOnly;

  const MealWidget(
    this._meal,
    this._recentMealItems,
    this.popTwice,
    this.readOnly,
  );

  @override
  _MealWidgetState createState() => _MealWidgetState();
}

class _MealWidgetState extends State<MealWidget> {
  var _viewMode = viewMode.base;
  bool _editing = false;

  void _toggleEditing() {
    setState(() {
      _editing = !_editing;
    });
  }

  void _toggleDetails() {
    setState(() {
      if (widget._meal.isRealMeal) {
        _viewMode = switch (_viewMode) {
          viewMode.base => viewMode.withIngredients,
          viewMode.withIngredients => viewMode.withAllDetails,
          viewMode.withAllDetails => viewMode.base,
        };
      } else {
        // the "other logs" fake meal doesn't have ingredients to show
        _viewMode = switch (_viewMode) {
          viewMode.base => viewMode.withAllDetails,
          _ => viewMode.base,
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MealHeader(
              editing: _editing,
              toggleEditing: _toggleEditing,
              popTwice: widget.popTwice,
              readOnly: widget.readOnly,
              viewMode: _viewMode,
              toggleViewMode: _toggleDetails,
              meal: widget._meal,
            ),
            if (_editing)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(context).addIngredient),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          FormScreen.routeName,
                          arguments: FormScreenArguments(
                            AppLocalizations.of(context).addIngredient,
                            MealItemForm(widget._meal, widget._recentMealItems),
                            hasListView: true,
                          ),
                        );
                      },
                    ),
                    TextButton.icon(
                      label: Text(AppLocalizations.of(context).edit),
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
                      icon: const Icon(Icons.timer),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Delete the meal
                        Provider.of<NutritionPlansProvider>(
                          context,
                          listen: false,
                        ).deleteMeal(widget._meal);

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
                      label: Text(AppLocalizations.of(context).delete),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            if (_viewMode == viewMode.withIngredients || _viewMode == viewMode.withAllDetails)
              const Divider(),
            if (_viewMode == viewMode.withIngredients || _viewMode == viewMode.withAllDetails)
              const DiaryheaderTile(),
            if (_viewMode == viewMode.withIngredients || _viewMode == viewMode.withAllDetails)
              if (widget._meal.mealItems.isEmpty && widget._meal.isRealMeal)
                NutritionTile(
                  title: Text(
                    AppLocalizations.of(context).noIngredientsDefined,
                    textAlign: TextAlign.left,
                  ),
                )
              else
                ...widget._meal.mealItems
                    .map((item) => MealItemEditableFullTile(item, _viewMode, _editing)),
            if (_viewMode == viewMode.withIngredients || _viewMode == viewMode.withAllDetails)
              const Divider(),
            if (_viewMode == viewMode.withIngredients || _viewMode == viewMode.withAllDetails)
              NutritionTile(
                vPadding: 0,
                leading: const Text('total'),
                title: getNutritionRow(
                  context,
                  muted(getNutritionalValues(widget._meal.plannedNutritionalValues, context)),
                ),
              ),
            if (_viewMode == viewMode.withAllDetails)
              Column(
                children: [
                  const Divider(),
                  Center(
                    child: Text(
                      AppLocalizations.of(context).loggedToday,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (widget._meal.plannedNutritionalValues.energy != 0)
                    MealDiaryBarChartWidget(
                      planned: widget._meal.plannedNutritionalValues,
                      logged: widget._meal.loggedNutritionalValuesToday,
                    ),
                  ...widget._meal.diaryEntriesToday.map((item) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [DiaryEntryTile(diaryEntry: item)],
                        ),
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// An editable NutritionTile showing the avatar, name, nutritional values
class MealItemEditableFullTile extends StatelessWidget {
  final bool _editing;
  final viewMode _viewMode;
  final MealItem _item;

  const MealItemEditableFullTile(this._item, this._viewMode, this._editing);

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

    return NutritionTile(
      leading: IngredientAvatar(ingredient: _item.ingredient),
      title: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            '${_item.amount.toStringAsFixed(0)}$unit ${_item.ingredient.name}',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
        ],
      ),
      subtitle: (_viewMode != viewMode.withAllDetails && !_editing)
          ? null
          : getNutritionRow(context, muted(getNutritionalValues(values, context))),
      trailing: _editing
          ? IconButton(
              icon: const Icon(Icons.delete, size: ICON_SIZE_SMALL),
              tooltip: AppLocalizations.of(context).delete,
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
                    ),
                  ),
                );
              },
            )
          : null,
    );
  }
}

class MealHeader extends StatelessWidget {
  final Meal _meal;
  final bool _editing;
  final bool popTwice;
  final bool readOnly;
  final viewMode _viewMode;
  final Function() _toggleEditing;
  final Function() _toggleViewMode;

  const MealHeader({
    required Meal meal,
    required bool editing,
    this.popTwice = false,
    this.readOnly = false,
    required viewMode viewMode,
    required Function() toggleEditing,
    required Function() toggleViewMode,
  })  : _meal = meal,
        _editing = editing,
        _viewMode = viewMode,
        _toggleViewMode = toggleViewMode,
        _toggleEditing = toggleEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _meal.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      if (_meal.time != null)
                        Text(
                          _meal.time!.format(context),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      if (_meal.time != null) const SizedBox(width: 12),
                      Text(
                        _meal.isRealMeal
                            ? getKcalConsumedVsPlanned(_meal, context)
                            : getKcalConsumed(_meal, context),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: switch (_viewMode) {
                  viewMode.base => const Icon(Icons.info_outline),
                  viewMode.withIngredients => const Icon(Icons.info),
                  viewMode.withAllDetails => const Icon(Icons.info),
                },
                onPressed: () {
                  _toggleViewMode();
                },
                tooltip: AppLocalizations.of(context).toggleDetails,
              ),
              if (_meal.isRealMeal && !readOnly) const SizedBox(width: 5),
              if (_meal.isRealMeal && !readOnly)
                IconButton(
                  icon: _editing ? const Icon(Icons.done) : const Icon(Icons.edit),
                  tooltip: _editing
                      ? AppLocalizations.of(context).done
                      : AppLocalizations.of(context).edit,
                  onPressed: () {
                    _toggleEditing();
                  },
                ),
              if (_meal.isRealMeal) const SizedBox(width: 5),
              if (_meal.isRealMeal) const SvgIcon(icon: SvgIconData('assets/icons/meal-diary.svg')),
            ],
          ),
          onTap: _meal.isRealMeal
              ? () {
                  Navigator.of(context).pushNamed(
                    LogMealScreen.routeName,
                    arguments: LogMealArguments(_meal, popTwice),
                  );
                }
              : null,
        ),
      ],
    );
  }
}
