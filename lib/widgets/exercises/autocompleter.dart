import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart' hide Consumer;
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/core/search_options.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/exercise_filters.dart';
import 'package:wger/providers/exercise_filters_riverpod.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/screens/add_exercise_screen.dart';
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
                // suffixIcon: IconButton(
                //   icon: const Icon(Icons.help),
                //   onPressed: () {
                //     showDialog(
                //       context: context,
                //       builder: (context) => AlertDialog(
                //         content: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Text(AppLocalizations.of(context).selectExercises),
                //             const SizedBox(height: 10),
                //             Text(AppLocalizations.of(context).sameRepetitions),
                //           ],
                //         ),
                //         actions: [
                //           TextButton(
                //             child: Text(
                //               MaterialLocalizations.of(context).closeButtonLabel,
                //             ),
                //             onPressed: () {
                //               Navigator.of(context).pop();
                //             },
                //           ),
                //         ],
                //       ),
                //     );
                //   },
                // ),
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
              category: exerciseFilters.selectedCategory,
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
        if (Localizations.localeOf(context).languageCode != LANGUAGE_SHORT_ENGLISH)
          SwitchListTile(
            title: Text(AppLocalizations.of(context).searchNamesInEnglish),
            value: exerciseFilters.searchLanguage == SearchLanguage.currentAndEnglish,
            onChanged: (val) {
              ref
                  .read(exerciseFiltersProvider.notifier)
                  .chooseLanguage(
                    val ? SearchLanguage.currentAndEnglish : SearchLanguage.current,
                  );
            },
            dense: true,
          ),
      ],
    );
  }

  /// The filter icon button — opens dialog with language, category, and search mode options.
  /// similar to the filterButton() in IngredientTypeahead.
  Widget _filterButton(BuildContext context) {
    final filters = ref.watch(exerciseFiltersSyncProvider);
    final i18n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isEnglish = languageCode == LANGUAGE_SHORT_ENGLISH;

    // If the device is in English and currentAndEnglish is set, switch to current
    if (isEnglish && filters.searchLanguage == SearchLanguage.currentAndEnglish) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(exerciseFiltersProvider.notifier).chooseLanguage(SearchLanguage.current);
      });
    }

    return IconButton(
      icon: const Icon(Icons.tune),
      color: Colors.blueGrey,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return Consumer(
                  builder: (context, ref, _) {
                    final filters = ref.watch(exerciseFiltersSyncProvider);

                    return AlertDialog(
                      title: Text(i18n.filter),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(i18n.language),
                              subtitle: Builder(
                                builder: (context) {
                                  final items = <DropdownMenuItem<SearchLanguage>>[
                                    DropdownMenuItem(
                                      value: SearchLanguage.current,
                                      child: Text(i18n.searchLanguageCurrent(languageCode)),
                                    ),
                                    if (!isEnglish)
                                      DropdownMenuItem(
                                        value: SearchLanguage.currentAndEnglish,
                                        child: Text(i18n.searchLanguageEnglish(languageCode)),
                                      ),
                                    DropdownMenuItem(
                                      value: SearchLanguage.all,
                                      child: Text(i18n.searchLanguageAll),
                                    ),
                                  ];

                                  SearchLanguage? selected = filters.searchLanguage;
                                  final containsSelected = items.any((it) => it.value == selected);
                                  if (!containsSelected) selected = null;

                                  return DropdownButton<SearchLanguage>(
                                    value: selected,
                                    isExpanded: true,
                                    onChanged: (val) {
                                      setDialogState(() {
                                        if (val != null) {
                                          ref
                                              .read(exerciseFiltersProvider.notifier)
                                              .chooseLanguage(val);
                                        }
                                      });
                                    },
                                    items: items,
                                  );
                                },
                              ),
                            ),
                            SwitchListTile(
                              title: const Text(i18n.exerciseSearchExactName),
                              subtitle: const Text(i18n.exerciseSearchExactNameSubtitle),
                              value: filters.searchMode == ExerciseSearchMode.exact,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) {
                                setDialogState(() {
                                  ref
                                      .read(exerciseFiltersProvider.notifier)
                                      .chooseSearchMode(
                                        val
                                            ? ExerciseSearchMode.exact
                                            : ExerciseSearchMode.fulltext,
                                      );
                                });
                              },
                            ),

                            // Categories
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                i18n.category,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Consumer(
                              builder: (context, ref, _) {
                                final exerciseProvider = Provider.of<ExercisesProvider>(
                                  context,
                                  listen: false,
                                );
                                final allCategories = exerciseProvider.categories;

                                final filters = ref.watch(exerciseFiltersSyncProvider);

                                return Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: allCategories.map((category) {
                                    final isSelected = filters.selectedCategory?.id == category.id;

                                    return FilterChip(
                                      label: Text(category.name),
                                      selected: isSelected,
                                      selectedColor: Colors.blueGrey.withValues(alpha: 0.3),
                                      checkmarkColor: Colors.blueGrey,
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.black : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      onSelected: (bool selected) {
                                        setDialogState(() {
                                          // toggle it off (null). otherwise, set the new category
                                          final newSelection = selected ? category : null;

                                          ref
                                              .read(exerciseFiltersProvider.notifier)
                                              .selectCategory(newSelection);
                                        });
                                      },
                                      avatar: Container(
                                        width: 8.0,
                                        height: 8.0,
                                        color: Colors.grey[350],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
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
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
