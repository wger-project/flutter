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
import 'package:wger/screens/ingredient_detail_screen.dart';
import 'package:wger/widgets/nutrition/ingredient_images.dart';

class IngredientListTile extends StatelessWidget {
  const IngredientListTile({super.key, required this.ingredient});

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    const double IMG_SIZE = 60;
    final String macros =
        'P: ${ingredient.protein}g / C: ${ingredient.carbohydrates}g / F: ${ingredient.fat}g';

    return ListTile(
      leading: SizedBox(
        height: IMG_SIZE,
        width: IMG_SIZE,
        child: CircleAvatar(
          backgroundColor: const Color(0x00ffffff),
          child: ClipOval(
            child: SizedBox(
              height: IMG_SIZE,
              width: IMG_SIZE,
              child: IngredientImageWidget(image: ingredient.image),
            ),
          ),
        ),
      ),
      title: Text(ingredient.name, overflow: TextOverflow.ellipsis, maxLines: 2),
      subtitle: Text(
        '${ingredient.energy} kJ • $macros',
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          IngredientDetailScreen.routeName,
          arguments: ingredient.id,
        );
      },
    );
  }
}
