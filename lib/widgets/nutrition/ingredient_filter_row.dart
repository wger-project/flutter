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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/ingredient_filters_notifier.dart';
import 'package:wger/widgets/nutrition/ingredient_filter_dialog.dart';

class IngredientFilterRow extends ConsumerStatefulWidget {
  const IngredientFilterRow({super.key});

  @override
  _IngredientFilterRowState createState() => _IngredientFilterRowState();
}

class _IngredientFilterRowState extends ConsumerState<IngredientFilterRow> {
  late final TextEditingController _ingredientNameController;

  @override
  void initState() {
    super.initState();

    final initialSearch = ref.read(ingredientFiltersSyncProvider).searchTerm;

    _ingredientNameController = TextEditingController(text: initialSearch)
      ..addListener(() {
        final text = _ingredientNameController.text;
        final currentFilters = ref.read(ingredientFiltersSyncProvider);
        if (currentFilters.searchTerm != text) {
          ref.read(ingredientFiltersProvider.notifier).setSearchTerm(text);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final currentFilters = ref.watch(ingredientFiltersSyncProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _ingredientNameController,
              decoration: InputDecoration(
                hintText: '${i18n.searchIngredient}...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentFilters.searchTerm.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: i18n.clearSearchTerm,
                        onPressed: () {
                          ref.read(ingredientFiltersProvider.notifier).setSearchTerm('');
                          _ingredientNameController.clear();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const IngredientFilterDialog(),
                ),
                icon: const Icon(Icons.filter_alt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ingredientNameController.dispose();
    super.dispose();
  }
}
