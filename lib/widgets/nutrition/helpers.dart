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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/nutritional_goals.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/nutrition/macro_nutrients_table.dart';

List<String> getNutritionColumnNames(BuildContext context) => [
      AppLocalizations.of(context).energy,
      AppLocalizations.of(context).protein,
      AppLocalizations.of(context).carbohydrates,
      AppLocalizations.of(context).fat,
    ];

List<String> getNutritionalValues(NutritionalValues values, BuildContext context) => [
      AppLocalizations.of(context).kcalValue(values.energy.toStringAsFixed(0)),
      AppLocalizations.of(context).gValue(values.protein.toStringAsFixed(0)),
      AppLocalizations.of(context).gValue(values.carbohydrates.toStringAsFixed(0)),
      AppLocalizations.of(context).gValue(values.fat.toStringAsFixed(0)),
    ];

List<int> getNutritionColumnFlexes(BuildContext context) {
  return getNutritionColumnNames(context).map((e) {
    final l = e.characters.length;
    // if the word is really small (e.g. "fat"),
    // we still want to have a minimum value to keep some spacing,
    // especially because column values might become like "123 g"
    return (l <= 3) ? 4 : l;
  }).toList();
}

List<Widget> muted(List<String> children) => children
    .map((e) => MutedText(
          e,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
        ))
    .toList();

// return a row of elements in the standard macros spacing
Row getNutritionRow(BuildContext context, List<Widget> children) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: children.indexed
        .map(
          (e) => Flexible(
            fit: FlexFit.tight,
            flex: getNutritionColumnFlexes(context)[e.$1],
            child: e.$2,
          ),
        )
        .toList(),
  );
}

String getShortNutritionValues(NutritionalValues values, BuildContext context) {
  final loc = AppLocalizations.of(context);
  final e = '${loc.energyShort} ${loc.kcalValue(values.energy.toStringAsFixed(0))}';
  final p = '${loc.proteinShort} ${loc.gValue(values.protein.toStringAsFixed(0))}';
  final c = '${loc.carbohydratesShort} ${loc.gValue(values.carbohydrates.toStringAsFixed(0))}';
  final f = '${loc.fatShort} ${loc.gValue(values.fat.toStringAsFixed(0))}';
  return '$e / $p / $c / $f';
}

String getKcalConsumed(Meal meal, BuildContext context) {
  final consumed =
      meal.diaryEntriesToday.map((e) => e.nutritionalValues.energy).fold(0.0, (a, b) => a + b);
  return AppLocalizations.of(context).kcalValue(consumed.toStringAsFixed(0));
}

String getKcalConsumedVsPlanned(Meal meal, BuildContext context) {
  final planned = meal.plannedNutritionalValues.energy;
  final consumed =
      meal.diaryEntriesToday.map((e) => e.nutritionalValues.energy).fold(0.0, (a, b) => a + b);
  final loc = AppLocalizations.of(context);

  return '${consumed.toStringAsFixed(0)} / ${planned.toStringAsFixed(0)} ${loc.kcal}';
}

void showIngredientDetails(BuildContext context, int id, {String? image}) {
  // when loading recently used ingredients, we never get an image :'(
  // we also don't get an image when querying the API
  // however, the typeahead suggestion does get an image, so we allow passing it...

  final url = context.read<NutritionPlansProvider>().baseProvider.auth.serverUrl;

  showDialog(
    context: context,
    builder: (context) => FutureBuilder<Ingredient>(
      future: Provider.of<NutritionPlansProvider>(context, listen: false).fetchIngredient(id),
      builder: (BuildContext context, AsyncSnapshot<Ingredient> snapshot) {
        Ingredient? ingredient;
        NutritionalGoals? goals;

        if (snapshot.hasData) {
          ingredient = snapshot.data!;
          goals = NutritionalGoals(
            energy: ingredient.nutritionalValues.energy,
            protein: ingredient.nutritionalValues.protein,
            carbohydrates: ingredient.nutritionalValues.carbohydrates,
            carbohydratesSugar: ingredient.nutritionalValues.carbohydratesSugar,
            fat: ingredient.nutritionalValues.fat,
            fatSaturated: ingredient.nutritionalValues.fatSaturated,
            fiber: ingredient.nutritionalValues.fiber,
            sodium: ingredient.nutritionalValues.sodium,
          );
        }
        return AlertDialog(
          title: (snapshot.hasData) ? Text(ingredient!.name) : null,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image != null)
                  CircleAvatar(backgroundImage: NetworkImage(url! + image), radius: 128),
                if (image != null) const SizedBox(height: 12),
                if (snapshot.hasError)
                  Text(
                    'Ingredient lookup error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                if (!snapshot.hasData && !snapshot.hasError) const CircularProgressIndicator(),
                if (snapshot.hasData)
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 400),
                    child: MacronutrientsTable(
                      nutritionalGoals: goals!,
                      plannedValuesPercentage: goals.energyPercentage(),
                      nutritionalGoalsGperKg: null,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
