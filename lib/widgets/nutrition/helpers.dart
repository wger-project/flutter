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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wger/models/nutrition/nutritrional_values.dart';
import 'package:wger/widgets/core/core.dart';

List<Widget> getMutedNutritionalValues(
    NutritionalValues values, BuildContext context) {
  final List<Widget> out = [
    MutedText(
      '${AppLocalizations.of(context).energy}: '
      '${values.energy.toStringAsFixed(0)}'
      '${AppLocalizations.of(context).kcal}',
    ),
    MutedText(
      '${AppLocalizations.of(context).protein}: '
      '${values.protein.toStringAsFixed(0)}'
      '${AppLocalizations.of(context).g}',
    ),
    MutedText(
      '${AppLocalizations.of(context).carbohydrates}: '
      '${values.carbohydrates.toStringAsFixed(0)} '
      '${AppLocalizations.of(context).g} '
      '(${values.carbohydratesSugar.toStringAsFixed(0)} ${AppLocalizations.of(context).sugars})',
    ),
    MutedText(
      '${AppLocalizations.of(context).fat}: '
      '${values.fat.toStringAsFixed(0)}'
      '${AppLocalizations.of(context).g} '
      '(${values.fatSaturated.toStringAsFixed(0)} ${AppLocalizations.of(context).saturatedFat})',
    ),
  ];
  return out;
}

String getFirstWord(String macroNutrientName) => macroNutrientName.isNotEmpty
    ? macroNutrientName.trim().split(' ').map((l) => l[0]).join()
    : '';
