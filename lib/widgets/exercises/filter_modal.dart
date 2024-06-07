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
import 'package:provider/provider.dart';
import 'package:wger/helpers/i18n.dart';
import 'package:wger/providers/exercises.dart';

class ExerciseFilterModalBody extends StatefulWidget {
  const ExerciseFilterModalBody({super.key});

  @override
  _ExerciseFilterModalBodyState createState() => _ExerciseFilterModalBodyState();
}

class _ExerciseFilterModalBodyState extends State<ExerciseFilterModalBody> {
  late Filters filters;

  @override
  void initState() {
    super.initState();
    filters = Provider.of<ExercisesProvider>(context, listen: false).filters!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: ExpansionPanelList(
          dividerColor: Colors.transparent,
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              filters.filterCategories[panelIndex].isExpanded = !isExpanded;
            });
          },
          elevation: 0,
          children: filters.filterCategories.map((filterCategory) {
            return ExpansionPanel(
              backgroundColor: Colors.transparent,
              isExpanded: filterCategory.isExpanded,
              headerBuilder: (context, isExpanded) {
                return Container(
                  child: Text(
                    filterCategory.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                );
              },
              body: Column(
                children: filterCategory.items.entries.map((currentEntry) {
                  return SwitchListTile(
                    title: Text(getTranslation(currentEntry.key.name, context)),
                    value: currentEntry.value,
                    onChanged: (_) {
                      setState(() {
                        filterCategory.items.update(currentEntry.key, (value) => !value);
                        Provider.of<ExercisesProvider>(context, listen: false).setFilters(filters);
                      });
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
