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
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:provider/provider.dart' hide Consumer;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise_filters.dart';
import 'package:wger/providers/exercise_filters_riverpod.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/search/language_dropdown.dart';

/// Filter dialog for the exercise search. Shown via [showDialog] from the
/// filter icon button next to the autocomplete field.
///
/// All state is owned by [exerciseFiltersProvider]; this widget is purely a
/// view over that state.
class ExerciseFilterDialog extends ConsumerWidget {
  const ExerciseFilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(i18n.filter),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer(
              builder: (context, ref, _) {
                final filters = ref.watch(exerciseFiltersSyncProvider);
                return SearchLanguageDropdown(
                  selected: filters.searchLanguage,
                  onChanged: (val) =>
                      ref.read(exerciseFiltersProvider.notifier).chooseLanguage(val),
                );
              },
            ),
            const _SearchModeSegmented(),
            const _CategoryChipsWrap(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => ref.read(exerciseFiltersProvider.notifier).resetAll(),
          child: Text(i18n.reset),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}

/// Toggle between fuzzy and exact name matching.
class _SearchModeSegmented extends ConsumerWidget {
  const _SearchModeSegmented();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final filters = ref.watch(exerciseFiltersSyncProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          i18n.exerciseSearchMode,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        SegmentedButton<ExerciseSearchMode>(
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
            selectedForegroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          segments: [
            ButtonSegment(
              value: ExerciseSearchMode.fulltext,
              label: Text(i18n.searchModeFuzzy),
              icon: const Icon(Icons.search),
            ),
            ButtonSegment(
              value: ExerciseSearchMode.exact,
              label: Text(i18n.searchModeExact),
              icon: const Icon(Icons.text_fields),
            ),
          ],
          selected: {filters.searchMode},
          onSelectionChanged: (set) {
            ref.read(exerciseFiltersProvider.notifier).chooseSearchMode(set.first);
          },
        ),
      ],
    );
  }
}

/// Wrap of selectable category chips. Empty selection means "no category
/// filter applied".
class _CategoryChipsWrap extends ConsumerWidget {
  const _CategoryChipsWrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final filters = ref.watch(exerciseFiltersSyncProvider);
    final allCategories = Provider.of<ExercisesProvider>(context, listen: false).categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          i18n.category,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: allCategories.map((category) {
            final isSelected = filters.selectedCategories.contains(category);
            return FilterChip(
              label: Text(category.name),
              selected: isSelected,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) {
                ref.read(exerciseFiltersProvider.notifier).toggleCategory(category);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
