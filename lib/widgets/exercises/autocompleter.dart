import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart' hide Consumer;
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
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
            return context.read<ExercisesProvider>().searchExercise(
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
            value: exerciseFilters.searchLanguage == ExerciseSearchLanguage.currentAndEnglish,
            onChanged: (val) {
              ref
                  .read(exerciseFiltersProvider.notifier)
                  .chooseLanguage(
                    val ? ExerciseSearchLanguage.currentAndEnglish : ExerciseSearchLanguage.current,
                  );
            },
            dense: true,
          ),
      ],
    );
  }

  /// The filter icon button — opens dialog with language, category, and search mode options.
  /// Mirrors the filterButton() in IngredientTypeahead.
  Widget _filterButton(BuildContext context) {
    final filters = ref.watch(exerciseFiltersSyncProvider);
    final i18n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isEnglish = languageCode == LANGUAGE_SHORT_ENGLISH;

    // If the device is in English and currentAndEnglish is set, switch to current
    if (isEnglish && filters.searchLanguage == ExerciseSearchLanguage.currentAndEnglish) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(exerciseFiltersProvider.notifier).chooseLanguage(ExerciseSearchLanguage.current);
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
                            // Language option — same as ingredient filter
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(i18n.language),
                              subtitle: Builder(
                                builder: (context) {
                                  final items = <DropdownMenuItem<ExerciseSearchLanguage>>[
                                    DropdownMenuItem(
                                      value: ExerciseSearchLanguage.current,
                                      child: Text(languageCode),
                                    ),
                                    if (!isEnglish)
                                      DropdownMenuItem(
                                        value: ExerciseSearchLanguage.currentAndEnglish,
                                        child: Text('$languageCode + EN'),
                                      ),
                                    const DropdownMenuItem(
                                      value: ExerciseSearchLanguage.all,
                                      child: Text('All languages'),
                                    ),
                                  ];

                                  ExerciseSearchLanguage? selected = filters.searchLanguage;
                                  final containsSelected = items.any((it) => it.value == selected);
                                  if (!containsSelected) selected = null;

                                  return DropdownButton<ExerciseSearchLanguage>(
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
                            // Search mode toggle — new for exercises
                            SwitchListTile(
                              title: const Text('Exact name match'),
                              subtitle: const Text(
                                'Off: fuzzy search. On: exact name only.',
                              ),
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
