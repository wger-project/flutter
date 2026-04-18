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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as pr;
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
        final exerciseProvider = pr.Provider.of<ExercisesProvider>(context, listen: false);
        final filters = exerciseProvider.filters;
        if (filters != null && filters.searchTerm != _exerciseNameController.text) {
          final exerciseFilters = ref.read(exerciseFiltersSyncProvider);
          final languageCode = Localizations.localeOf(context).languageCode;
          exerciseProvider.setFilters(
            filters.copyWith(searchTerm: _exerciseNameController.text),
            exerciseFilters: exerciseFilters,
            languageCode: languageCode,
          );
        }
      });

    // Run ONCE after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageCode = Localizations.localeOf(context).languageCode;
      final isEnglish = languageCode == 'en';
      if (isEnglish) {
        final current = ref.read(exerciseFiltersSyncProvider);
        if (current.searchLanguage == ExerciseSearchLanguage.currentAndEnglish) {
          ref.read(exerciseFiltersProvider.notifier).chooseLanguage(ExerciseSearchLanguage.current);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _exerciseNameController,
              decoration: InputDecoration(
                hintText: '${i18n.exerciseName}...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
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
            itemBuilder: (context) => [
              PopupMenuItem<ExerciseMoreOption>(
                value: ExerciseMoreOption.ADD_EXERCISE,
                child: Text(i18n.contributeExercise),
              ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            onSelected: (ExerciseMoreOption selected) {
              if (selected == ExerciseMoreOption.ADD_EXERCISE) {
                Navigator.of(context).pushNamed(AddExerciseScreen.routeName);
              }
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  /// The filter icon button — opens dialog with language, category, and search mode options.
  Widget _filterButton(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final exerciseProvider = pr.Provider.of<ExercisesProvider>(context, listen: false);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isEnglish = languageCode == 'en';

    return IconButton(
      icon: const Icon(Icons.tune),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return Consumer(
                  builder: (context, ref, _) {
                    final filters = ref.watch(exerciseFiltersSyncProvider);
                    final categories = exerciseProvider.categories;

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
                            // Category filter — new for exercises
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Category'),
                              subtitle: DropdownButton<int?>(
                                value: filters.selectedCategory?.id,
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('All categories'),
                                  ),
                                  ...categories.map(
                                    (cat) => DropdownMenuItem<int?>(
                                      value: cat.id,
                                      child: Text(cat.name),
                                    ),
                                  ),
                                ],
                                onChanged: (int? categoryId) {
                                  setDialogState(() {
                                    final selected = categoryId == null
                                        ? null
                                        : categories.firstWhere((c) => c.id == categoryId);
                                    ref
                                        .read(exerciseFiltersProvider.notifier)
                                        .selectCategory(selected);
                                  });
                                },
                              ),
                            ),
                            // Search mode toggle
                            SwitchListTile(
                              title: const Text('Exact name match'),
                              subtitle: const Text(
                                'Off: partial match. On: exact name match.',
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
