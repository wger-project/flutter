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
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/ingredient_notifier.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/nutrition/ingredient_filter_row.dart';
import 'package:wger/widgets/nutrition/ingredient_list_tile.dart';

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});

  static const routeName = '/ingredients';

  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen> {
  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(searchedIngredientsProvider);
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${i18n.ingredient}'
          's',
        ),
      ),
      body: WidescreenWrapper(
        child: Column(
          children: [
            const IngredientFilterRow(),
            Expanded(
              child: ingredientsAsync.when(
                data: (list) => _IngredientsList(
                  ingredientList: list,
                ),

                loading: () => const Center(child: CenteredProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientsList extends StatelessWidget {
  const _IngredientsList({required this.ingredientList});

  final List<Ingredient> ingredientList;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const Divider(thickness: 1);
      },
      itemCount: ingredientList.length,
      itemBuilder: (context, index) => IngredientListTile(ingredient: ingredientList[index]),
    );
  }
}
