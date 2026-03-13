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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/measurement_entries_screen.dart';
import 'package:wger/widgets/measurements/helpers.dart';

import 'charts.dart';
import 'forms.dart';

class CategoriesCard extends StatelessWidget {
  final MeasurementCategory currentCategory;
  final double? elevation;

  const CategoriesCard(this.currentCategory, {this.elevation});

  @override
  Widget build(BuildContext context) {
    final (entriesAll, entries7dAvg) = sensibleRange(
      currentCategory.entries.map((e) => MeasurementChartEntry(e.value, e.date)).toList(),
    );

    return Card(
      elevation: elevation,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                currentCategory.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              height: 220,
              child: MeasurementChartWidgetFl(
                entriesAll,
                currentCategory.unit,
                avgs: entries7dAvg,
              ),
            ),
            if (entries7dAvg.isNotEmpty)
              MeasurementOverallChangeWidget(
                entries7dAvg.first,
                entries7dAvg.last,
                currentCategory.unit,
              ),
            const Divider(),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text(AppLocalizations.of(context).goToDetailPage),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              MeasurementEntriesScreen.routeName,
                              arguments: currentCategory.uuid,
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              FormScreen.routeName,
                              arguments: FormScreenArguments(
                                AppLocalizations.of(context).newEntry,
                                MeasurementEntryForm(currentCategory.uuid),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
