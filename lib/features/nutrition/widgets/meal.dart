/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/form_screen.dart';
import 'package:wger/core/widgets/core.dart';
import 'package:wger/core/widgets/progress_indicator.dart';
import 'package:wger/features/nutrition/models/meal.dart';
import 'package:wger/features/nutrition/models/meal_item.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/features/nutrition/screens/log_meal_screen.dart';
import 'package:wger/features/nutrition/widgets/charts.dart';
import 'package:wger/features/nutrition/widgets/forms.dart';
import 'package:wger/features/nutrition/widgets/helpers.dart';
import 'package:wger/features/nutrition/widgets/nutrition_tile.dart';
import 'package:wger/features/nutrition/widgets/nutrition_tiles.dart';
import 'package:wger/features/nutrition/widgets/widgets.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

enum ViewMode {
  base, // just highlevel meal info (name, time)
  withIngredients, // + ingredients
  withAllDetails, // + nutritional breakdown of ingredients, + logged today
}

/// Card widget for a single [Meal] on the NutritionalPlanDetailWidget (NutritionalPlanScreen).
class MealWidget extends ConsumerStatefulWidget {
  final Meal _meal;
  final bool popTwice;
  final bool readOnly;

  const MealWidget(
    this._meal,
    this.popTwice,
    this.readOnly,
  );

  @override
  ConsumerState<MealWidget> createState() => _MealWidgetState();
}

class _MealWidgetState extends ConsumerState<MealWidget> {
  var _viewMode = ViewMode.base;
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
          ViewMode.base => ViewMode.withIngredients,
          ViewMode.withIngredients => ViewMode.withAllDetails,
          ViewMode.withAllDetails => ViewMode.base,
        };
      } else {
        // the "other logs" fake meal doesn't have ingredients to show
        _viewMode = switch (_viewMode) {
          ViewMode.base => ViewMode.withAllDetails,
          _ => ViewMode.base,
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
            MealIngredientsSection(
              meal: widget._meal,
              editing: _editing,
              viewMode: _viewMode,
            ),
            if (_viewMode == ViewMode.withAllDetails)
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
                  ...widget._meal.diaryEntriesToday.map(
                    (item) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [DiaryEntryTile(diaryEntry: item)],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// An editable NutritionTile showing the avatar, name, nutritional values
class MealItemEditableFullTile extends ConsumerWidget {
  final bool _editing;
  final ViewMode _viewMode;
  final MealItem _item;

  const MealItemEditableFullTile(this._item, this._viewMode, this._editing);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = _item.nutritionalValues;
    final i18n = AppLocalizations.of(context);

    final String amountText = _item.weightUnitObj != null
        ? '${_item.amount.toStringAsFixed(0)} × ${_item.weightUnitObj!.name}'
        : i18n.gValue(_item.amount.toStringAsFixed(0));

    // ingredient is null briefly between local insert and PowerSync
    // downloading the row, show a placeholder rather than crashing.
    final ingredient = _item.ingredient;
    return NutritionTile(
      leading: ingredient != null
          ? IngredientAvatar(ingredient: ingredient)
          : const CircleIconAvatar(Icon(Icons.hourglass_empty, color: Colors.grey)),
      title: Text(
        '$amountText ${ingredient?.name ?? '…'}',
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
      ),
      subtitle: (_viewMode != ViewMode.withAllDetails && !_editing)
          ? null
          : getNutritionRow(context, muted(getNutritionalValues(values, context))),
      trailing: _editing
          ? IconButton(
              icon: const Icon(Icons.delete, size: ICON_SIZE_SMALL),
              tooltip: i18n.delete,
              iconSize: ICON_SIZE_SMALL,
              onPressed: () {
                // Delete the meal item, goes through PowerSync, so offline is fine.
                ref.read(nutritionProvider.notifier).deleteMealItem(_item);

                // and inform the user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      i18n.successfullyDeleted,
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
  final ViewMode _viewMode;
  final Function() _toggleEditing;
  final Function() _toggleViewMode;

  const MealHeader({
    required Meal meal,
    required bool editing,
    this.popTwice = false,
    this.readOnly = false,
    required ViewMode viewMode,
    required Function() toggleEditing,
    required Function() toggleViewMode,
  }) : _meal = meal,
       _editing = editing,
       _viewMode = viewMode,
       _toggleViewMode = toggleViewMode,
       _toggleEditing = toggleEditing;

  @override
  Widget build(BuildContext context) {
    final subtitleTime = _meal.time != null ? '${_meal.time!.format(context)} / ' : '';
    final subtitleCalories = _meal.isRealMeal
        ? getKcalConsumedVsPlanned(_meal, context)
        : getKcalConsumed(_meal, context);
    final subtitle = '$subtitleTime $subtitleCalories';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            _meal.name,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.titleSmall,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: switch (_viewMode) {
                  ViewMode.base => const Icon(Icons.info_outline),
                  ViewMode.withIngredients => const Icon(Icons.info),
                  ViewMode.withAllDetails => const Icon(Icons.info),
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

class MealIngredientsSection extends ConsumerWidget {
  const MealIngredientsSection({
    super.key,
    required this.meal,
    required this.editing,
    required this.viewMode,
  });
  final Meal meal;
  final bool editing;
  final ViewMode viewMode;

  bool showIngredientsDetails(ViewMode viewMode) {
    return viewMode == ViewMode.withIngredients || viewMode == ViewMode.withAllDetails;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (editing)
          MealEditingToolbar(
            meal: meal,
          ),
        if (showIngredientsDetails(viewMode)) ...[
          const Divider(),
          const DiaryheaderTile(),
          _buildIngredientList(context),
          const Divider(),
          _buildTotalRow(context),
        ],
      ],
    );
  }

  Widget _buildIngredientList(BuildContext context) {
    if (meal.mealItems.isEmpty && meal.isRealMeal) {
      return NutritionTile(
        title: Text(
          AppLocalizations.of(context).noIngredientsDefined,
          textAlign: TextAlign.left,
        ),
      );
    }

    return Column(
      children: [
        ...meal.mealItems.map(
          (item) => MealItemEditableFullTile(item, viewMode, editing),
        ),
      ],
    );
  }

  Widget _buildTotalRow(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return NutritionTile(
      vPadding: 0,
      leading: Text(i18n.total),
      title: getNutritionRow(
        context,
        muted(getNutritionalValues(meal.plannedNutritionalValues, context)),
      ),
    );
  }
}

class MealEditingToolbar extends ConsumerWidget {
  final Meal meal;
  const MealEditingToolbar({super.key, required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionProvider).value;
    if (state == null) {
      return const Center(child: BoxedProgressIndicator());
    }
    final recentMealItems = state.recentMealItemsInPlan(meal.planId) ?? const <MealItem>[];

    return Padding(
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
                  getMealItemForm(meal, recentMealItems),
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
                  MealForm(meal.planId, meal),
                ),
              );
            },
            icon: const Icon(Icons.timer),
          ),
          TextButton.icon(
            onPressed: () {
              // Delete the meal
              ref.read(nutritionProvider.notifier).deleteMeal(meal);

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
    );
  }
}
