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
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/ingredient_notifier.dart';
import 'package:wger/widgets/core/async_value_widget.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/nutrition/ingredient_dialogs.dart';

class IngredientDetailScreen extends ConsumerWidget {
  static const routeName = '/ingredient-detail';

  const IngredientDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ModalRoute.of(context)?.settings.arguments as int?;
    if (id == null) {
      return const Scaffold(body: Center(child: CenteredProgressIndicator()));
    }

    final async = ref.watch(ingredientByIdStreamProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(async.value?.name ?? '')),
      body: AsyncValueWidget<Ingredient?>(
        value: async,
        loggerName: 'IngredientDetailScreen',
        data: (ingredient) {
          if (ingredient == null) {
            // No matching row yet (sync hasn't pulled it down, or the id
            // points at something that has since been deleted upstream).
            return const Center(child: Icon(Icons.help_outline, size: 48));
          }
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: IngredientDetails(ingredient),
            ),
          );
        },
      ),
    );
  }
}
