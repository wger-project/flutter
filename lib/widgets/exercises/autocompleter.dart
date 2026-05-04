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
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart' hide Consumer;
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/core/search_options.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/providers/exercise_filters_riverpod.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/screens/add_exercise_screen.dart';
import 'package:wger/widgets/exercises/exercise_filter_dialog.dart';
import 'package:wger/widgets/exercises/images.dart';

typedef ExerciseSelectedCallback = void Function(Exercise exercise);

class ExerciseAutocompleter extends ConsumerStatefulWidget {
  final ExerciseSelectedCallback onExerciseSelected;

  const ExerciseAutocompleter({required this.onExerciseSelected});

  @override
  ConsumerState<ExerciseAutocompleter> createState() => _ExerciseAutocompleterState();
}

class _ExerciseAutocompleterState extends ConsumerState<ExerciseAutocompleter> {
  final _exercisesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final exerciseFilters = ref.watch(exerciseFiltersSyncProvider);

    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        TypeAheadField<Exercise>(
          key: const Key('field-typeahead'),
          debounceDuration: const Duration(milliseconds: 500),
          decorationBuilder: (context, child) {
            return Material(
              type: MaterialType.card,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: child,
            );
          },
          controller: _exercisesController,
          builder: (context, controller, focusNode) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).searchExercise,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _filterButton(context),
                errorMaxLines: 2,
                border: InputBorder.none,
              ),
            );
          },
          suggestionsCallback: (pattern) {
            if (pattern == '') {
              return null;
            }
            return context.read<ExercisesProvider>().searchExerciseWithSearchMode(
              pattern,
              languageCode: Localizations.localeOf(context).languageCode,
              searchLanguage: exerciseFilters.searchLanguage,
              searchMode: exerciseFilters.searchMode,
              categories: exerciseFilters.selectedCategories,
            );
          },
          itemBuilder:
              (
                BuildContext context,
                Exercise exerciseSuggestion,
              ) => ListTile(
                key: Key('exercise-${exerciseSuggestion.id}'),
                leading: SizedBox(
                  width: 45,
                  child: ExerciseImageWidget(
                    image: exerciseSuggestion.getMainImage,
                  ),
                ),
                title: Text(
                  exerciseSuggestion
                      .getTranslation(Localizations.localeOf(context).languageCode)
                      .name,
                ),
                subtitle: Text(
                  '${exerciseSuggestion.category!.name} / ${exerciseSuggestion.equipment.map((e) => e.name).join(', ')}',
                ),
              ),
          emptyBuilder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context).noMatchingExerciseFound),
                ),
                ListTile(
                  title: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AddExerciseScreen.routeName);
                    },
                    child: Text(AppLocalizations.of(context).contributeExercise),
                  ),
                ),
              ],
            );
          },
          transitionBuilder: (context, animation, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
            child: child,
          ),
          onSelected: (Exercise exerciseSuggestion) {
            widget.onExerciseSelected(exerciseSuggestion);
            _exercisesController.text = '';
          },
        ),
      ],
    );
  }

  /// The filter icon button — shows an active-filter badge and opens
  /// [ExerciseFilterDialog] on tap.
  Widget _filterButton(BuildContext context) {
    final filters = ref.watch(exerciseFiltersSyncProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    // Auto-correct: in an English locale "current + English" collapses to
    // "current" — fix it once if a stored preference landed on the
    // non-locale-aware default.
    if (languageCode == LANGUAGE_SHORT_ENGLISH &&
        filters.searchLanguage == SearchLanguage.currentAndEnglish) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(exerciseFiltersProvider.notifier).chooseLanguage(SearchLanguage.current);
      });
    }

    final activeFilterCount = filters.activeFilterCount(languageCode);

    return IconButton(
      icon: Badge(
        label: Text('$activeFilterCount'),
        isLabelVisible: activeFilterCount > 0,
        child: const Icon(Icons.tune),
      ),
      onPressed: () => showDialog(
        context: context,
        builder: (_) => const ExerciseFilterDialog(),
      ),
    );
  }
}
