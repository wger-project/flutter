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
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/widgets/nutrition/ingredient_detail.dart';

class IngredientDetailScreen extends StatelessWidget {
  static const routeName = '/ingredient-detail';

  const IngredientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract the ingredient from the route arguments
    final ingredient = ModalRoute.of(context)!.settings.arguments as Ingredient;

    return Scaffold(
      appBar: AppBar(
        title: Text(ingredient.name),
        actions: const [],
      ),
      body: WidescreenWrapper(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: IngredientDetail(ingredient),
        ),
      ),
    );
  }
}
