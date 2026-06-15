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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/ingredient_filters_notifier.dart';
import 'package:wger/widgets/nutrition/ingredient_filter_dialog.dart';

class IngredientFilterRow extends ConsumerStatefulWidget {
  const IngredientFilterRow({super.key});

  @override
  ConsumerState<IngredientFilterRow> createState() => _IngredientFilterRowState();
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

    // We intentionally don't watch the filters provider here: every keystroke
    // pushes the new search term into that provider, and watching it would
    // rebuild the TextFormField + its decoration on each character. Only the
    // clear-icon's visibility depends on the search term, so it lives in
    // its own Consumer
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
                suffixIcon: _ClearSearchTermButton(controller: _ingredientNameController),
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

/// Suffix-area clear button. Lives in its own ConsumerWidget so it can watch
/// `searchTerm.isNotEmpty` without dragging the parent TextFormField rebuild
/// along on every keystroke.
class _ClearSearchTermButton extends ConsumerWidget {
  const _ClearSearchTermButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasText = ref.watch(
      ingredientFiltersSyncProvider.select((f) => f.searchTerm.isNotEmpty),
    );
    if (!hasText) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: const Icon(Icons.clear),
      tooltip: AppLocalizations.of(context).clearSearchTerm,
      onPressed: () {
        ref.read(ingredientFiltersProvider.notifier).setSearchTerm('');
        controller.clear();
      },
    );
  }
}
