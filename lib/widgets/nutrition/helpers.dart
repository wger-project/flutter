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
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/widgets/core/core.dart';

List<Widget> getMutedNutritionalValues(NutritionalValues values, BuildContext context) => [
      MutedText(
        AppLocalizations.of(context).kcalValue(values.energy.toStringAsFixed(0)),
        textAlign: TextAlign.right,
      ),
      MutedText(
        AppLocalizations.of(context).gValue(values.protein.toStringAsFixed(0)),
        textAlign: TextAlign.right,
      ),
      MutedText(
        AppLocalizations.of(context).gValue(values.carbohydrates.toStringAsFixed(0)),
        textAlign: TextAlign.right,
      ),
      MutedText(
        AppLocalizations.of(context).gValue(values.fat.toStringAsFixed(0)),
        textAlign: TextAlign.right,
      ),
    ];

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
  final loc = AppLocalizations.of(context);

  return '${consumed.toStringAsFixed(0)} ${loc.kcal}';
}

String getKcalConsumedVsPlanned(Meal meal, BuildContext context) {
  final planned = meal.plannedNutritionalValues.energy;
  final consumed =
      meal.diaryEntriesToday.map((e) => e.nutritionalValues.energy).fold(0.0, (a, b) => a + b);
  final loc = AppLocalizations.of(context);

  return '${consumed.toStringAsFixed(0)} / ${planned.toStringAsFixed(0)} ${loc.kcal}';
}
