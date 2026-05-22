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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/widgets/core/wger_image.dart';
import 'package:wger/widgets/nutrition/ingredient_dialogs.dart';
import 'package:wger/widgets/nutrition/macro_nutrients_table.dart';

class IngredientDetailScreen extends ConsumerWidget {
  static const routeName = '/ingredient-detail';

  const IngredientDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredient = ModalRoute.of(context)!.settings.arguments as Ingredient;
    final goals = ingredient.nutritionalValues.toGoals();
    final source = ingredient.sourceName ?? 'unknown';

    const placeholder = Image(
      image: AssetImage('assets/images/placeholder.png'),
      color: Color.fromRGBO(255, 255, 255, 0.3),
      colorBlendMode: BlendMode.modulate,
      semanticLabel: 'Placeholder',
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                ingredient.name,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              background: WgerImage(
                mediaPath: ingredient.image?.image,
                fit: BoxFit.cover,
                errorWidget: placeholder,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Dietary Info (Vegan, Veg, NutriScore)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DietaryInfoSection(ingredient: ingredient),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  AppLocalizations.of(context).macronutrients,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),

                // Macronutrients Table
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MacronutrientsTable(
                      nutritionalGoals: goals,
                      plannedValuesPercentage: goals.energyPercentage(),
                      showGperKg: false,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Divider(color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 8),
                if (ingredient.licenseObjectURl == null)
                  Text('Source: $source', style: Theme.of(context).textTheme.bodySmall)
                else
                  InkWell(
                    onTap: () => launchURL(ingredient.licenseObjectURl!, context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Source: $source',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
