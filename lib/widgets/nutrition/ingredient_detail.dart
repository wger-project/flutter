/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2025 wger Team
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
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/nutrition/ingredient_images.dart';

class IngredientDetail extends StatelessWidget {
  final Ingredient _ingredient;
  static const PADDING = 9.0;

  const IngredientDetail(this._ingredient, {super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        padding: const EdgeInsets.all(PADDING),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ...getImage(),
            const SizedBox(height: 8),

            // Dietary Tags & Nutri-Score
            getBadges(context),
            const SizedBox(height: 16),

            // Nutritional Info per 100g
            ...getNutritionInfo(context),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> getImage() {
    final List<Widget> out = [];
    if (_ingredient.image != null) {
      out.add(
        Center(
          child: IngredientImageWidget(
            image: _ingredient.image,
            height: 250,
          ),
        ),
      );
      out.add(const SizedBox(height: PADDING));
    }
    return out;
  }

  Widget getBadges(BuildContext context) {
    final List<Widget> out = [];

    if (_ingredient.isVegan == true) {
      out.add(_buildColoredChip('Vegan', wgerTertiaryColor, Colors.white));
    } else if (_ingredient.isVegetarian == true) {
      out.add(_buildColoredChip('Vegetarian', wgerPrimaryColorLight, wgerPrimaryColor));
    }

    if (_ingredient.nutriscore != null) {
      out.add(
        _buildColoredChip(
          'Nutri-Score: ${_ingredient.nutriscore!.name.toUpperCase()}',
          wgerPrimaryColor.withAlpha(200),
          Colors.white,
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: out);
  }

  Widget _buildColoredChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  List<Widget> getNutritionInfo(BuildContext context) {
    final List<Widget> out = [];
    final macros = _ingredient.nutritionalValues;

    out.add(
      Text(
        'Nutritional Values (per 100g)',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
    out.add(const SizedBox(height: PADDING));

    // Build the macro list leveraging the model's getters
    out.add(_buildNutritionRow('Energy', '${macros.energy} kJ'));
    out.add(_buildNutritionRow('Protein', '${macros.protein} g'));
    out.add(_buildNutritionRow('Carbohydrates', '${macros.carbohydrates} g'));
    if (macros.carbohydratesSugar > 0) {
      out.add(_buildNutritionRow('  ↳ Sugars', '${macros.carbohydratesSugar} g', isSubItem: true));
    }
    out.add(_buildNutritionRow('Fat', '${macros.fat} g'));
    if (macros.fatSaturated > 0) {
      out.add(_buildNutritionRow('  ↳ Saturated', '${macros.fatSaturated} g', isSubItem: true));
    }
    out.add(_buildNutritionRow('Fiber', '${macros.fiber} g'));
    out.add(_buildNutritionRow('Sodium', '${macros.sodium} g'));

    out.add(const SizedBox(height: PADDING));
    return out;
  }

  Widget _buildNutritionRow(String label, String value, {bool isSubItem = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: isSubItem ? 16.0 : 0.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSubItem ? Colors.grey[600] : null,
              fontWeight: isSubItem ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
