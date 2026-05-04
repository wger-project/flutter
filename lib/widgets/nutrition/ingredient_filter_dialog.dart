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
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/nutrition_ingredient_filters_riverpod.dart';
import 'package:wger/widgets/search/language_dropdown.dart';

/// Filter dialog for the ingredient search. Shown via [showDialog] from the
/// filter icon button in the ingredient typeahead.
///
/// All state is owned by [ingredientFiltersProvider]; this widget is purely a
/// view over that state.
class IngredientFilterDialog extends ConsumerWidget {
  const IngredientFilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(i18n.filter),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageDropdown(),
            _DietSwitches(),
            _NutriscoreSliderSection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}

/// Wraps the shared [SearchLanguageDropdown] and binds it to
/// [ingredientFiltersProvider].
class _LanguageDropdown extends ConsumerWidget {
  const _LanguageDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(ingredientFiltersSyncProvider);
    return SearchLanguageDropdown(
      selected: filters.searchLanguage,
      onChanged: (val) => ref.read(ingredientFiltersProvider.notifier).chooseLanguage(val),
    );
  }
}

/// Vegan + Vegetarian toggles, grouped because they are thematically and
/// visually paired.
class _DietSwitches extends ConsumerWidget {
  const _DietSwitches();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final filters = ref.watch(ingredientFiltersSyncProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          title: Text(i18n.isVegan),
          value: filters.isVegan,
          contentPadding: EdgeInsets.zero,
          onChanged: (val) => ref.read(ingredientFiltersProvider.notifier).toggleVegan(val),
        ),
        SwitchListTile(
          title: Text(i18n.isVegetarian),
          value: filters.isVegetarian,
          contentPadding: EdgeInsets.zero,
          onChanged: (val) => ref.read(ingredientFiltersProvider.notifier).toggleVegetarian(val),
        ),
      ],
    );
  }
}

/// Section that wraps [_NutriscoreSlider] and binds it to
/// [ingredientFiltersProvider].
class _NutriscoreSliderSection extends ConsumerWidget {
  const _NutriscoreSliderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(ingredientFiltersSyncProvider);
    return _NutriscoreSlider(
      value: filters.nutriscoreMax,
      onChanged: (grade) => ref.read(ingredientFiltersProvider.notifier).chooseNutriscoreMax(grade),
    );
  }
}

/// Discrete slider that lets the user pick the worst acceptable [NutriScore]
/// grade. Index 0 is the "Off" position (no filter, `null` value) and
/// indices 1..N map to [NutriScore.values].
class _NutriscoreSlider extends StatelessWidget {
  final NutriScore? value;
  final ValueChanged<NutriScore?> onChanged;

  const _NutriscoreSlider({required this.value, required this.onChanged});

  static const int _offIndex = 0;

  int _valueToIndex(NutriScore? v) => v == null ? _offIndex : NutriScore.values.indexOf(v) + 1;

  NutriScore? _indexToValue(int i) => i == _offIndex ? null : NutriScore.values[i - 1];

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final index = _valueToIndex(value);
    final maxIndex = NutriScore.values.length; // 0=Off, then A..E
    final helperText = value == null
        ? i18n.filterNutriscoreNoFilter
        : i18n.filterNutriscoreOrBetter(value!.name.toUpperCase());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            i18n.filterNutriscore,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            helperText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Slider(
            value: index.toDouble(),
            min: 0,
            max: maxIndex.toDouble(),
            divisions: maxIndex,
            label: value == null ? i18n.filterNutriscoreOff : value!.name.toUpperCase(),
            onChanged: (v) => onChanged(_indexToValue(v.round())),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  i18n.filterNutriscoreOff,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                ...NutriScore.values.map(
                  (score) => Text(
                    score.name.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
