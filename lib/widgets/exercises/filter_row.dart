/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise_filters.dart';
import 'package:wger/providers/exercise_filters_riverpod.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/screens/add_exercise_screen.dart';

import 'filter_modal.dart';

class FilterRow extends ConsumerStatefulWidget {
  const FilterRow({super.key});

  @override
  ConsumerState<FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends ConsumerState<FilterRow> {
  late final TextEditingController _exerciseNameController;

  @override
  void initState() {
    super.initState();

    _exerciseNameController = TextEditingController()
      ..addListener(() {
        if (!mounted) return;

        final exerciseProvider = Provider.of<ExercisesProvider>(context, listen: false);
        final filters = exerciseProvider.filters;

        if (filters != null && filters.searchTerm != _exerciseNameController.text) {
          final exerciseFilters = ref.read(exerciseFiltersSyncProvider);
          final languageCode = Localizations.localeOf(context).languageCode;
          exerciseProvider.setFilters(
            exerciseProvider.filters!.copyWith(searchTerm: _exerciseNameController.text),
            exerciseFilters: exerciseFilters,
            languageCode: languageCode,
          );
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _exerciseNameController,
              decoration: InputDecoration(
                hintText: '${AppLocalizations.of(context).exerciseName}...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              
            ),
          ),
          Row(
            children: [
              _filterButton(context),
              IconButton(
                onPressed: () async {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const ExerciseFilterModalBody(),
                  );
                },
                icon: const Icon(Icons.filter_alt),
              ),
              PopupMenuButton<ExerciseMoreOption>(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<ExerciseMoreOption>(
                      value: ExerciseMoreOption.ADD_EXERCISE,
                      child: Text(AppLocalizations.of(context).contributeExercise),
                    ),
                  ];
                },
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                onSelected: (ExerciseMoreOption selectedOption) {
                  switch (selectedOption) {
                    case ExerciseMoreOption.ADD_EXERCISE:
                      Navigator.of(context).pushNamed(AddExerciseScreen.routeName);
                      break;
                  }
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ],
      ),
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

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }
}

enum ExerciseMoreOption { ADD_EXERCISE }
