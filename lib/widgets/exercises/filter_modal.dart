/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 - 2026 wger Team
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
import 'package:wger/helpers/i18n.dart';
import 'package:wger/models/exercises/exercise_filters.dart';
import 'package:wger/providers/exercise_filters_riverpod.dart';
import 'package:wger/providers/exercises.dart';

class ExerciseFilterModalBody extends ConsumerStatefulWidget {
  const ExerciseFilterModalBody({super.key});

  @override
  ConsumerState<ExerciseFilterModalBody> createState() => _ExerciseFilterModalBodyState();
}

class _ExerciseFilterModalBodyState extends ConsumerState<ExerciseFilterModalBody> {
  // Senior Note: Local state is only for transient UI states (like expansion panels).
  // The actual filter data stays in the Provider.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Watch the legacy provider to ensure UI updates when data changes
    final exerciseProvider = pr.Provider.of<ExercisesProvider>(context);
    final filters = exerciseProvider.filters;

    // Safety check if provider hasn't initialized filters yet
    if (filters == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: ExpansionPanelList(
          dividerColor: Colors.transparent,
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              // Toggle expansion locally
              filters.filterCategories[panelIndex].isExpanded = isExpanded;
            });
          },
          elevation: 0,
          children: filters.filterCategories.map((filterCategory) {
            return ExpansionPanel(
              backgroundColor: Colors.transparent,
              isExpanded: filterCategory.isExpanded,
              headerBuilder: (context, isExpanded) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    filterCategory.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                );
              },
              body: Column(
                children: filterCategory.items.entries.map((currentEntry) {
                  return SwitchListTile(
                    title: Text(getServerStringTranslation(currentEntry.key.name, context)),
                    value: currentEntry.value,
                    onChanged: (bool newValue) {
                      // 2. Update the map entry
                      filterCategory.items[currentEntry.key] = newValue;

                      // 3. Extract dependencies for the bridge call
                      final riverpodFilters = ref.read(exerciseFiltersSyncProvider);
                      final languageCode = Localizations.localeOf(context).languageCode;

                      // 4. Update the provider (Triggers API/DB search automatically)
                      // Senior Note: We use copyWith to ensure we preserve the existing searchTerm
                      exerciseProvider.setFilters(
                        filters.copyWith(searchTerm: filters.searchTerm),
                        exerciseFilters: riverpodFilters,
                        languageCode: languageCode,
                      );
                    },
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
