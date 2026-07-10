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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:wger/core/form_screen.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import 'charts.dart';
import 'forms.dart';

class CategoriesCard extends StatelessWidget {
  final MeasurementCategory currentCategory;
  final double? elevation;

  const CategoriesCard(this.currentCategory, {this.elevation});

  @override
  Widget build(BuildContext context) {
    if (currentCategory.isGroup) {
      return _buildGroupCard(context);
    }

    // sensibleRange() operates on raw (pre-aggregation) entries
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                currentCategory.name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              height: 220,
              child: buildChartForMetricType(
                currentCategory.metricType,
                entriesAll,
                entries7dAvg,
                currentCategory.unit,
              ),
            ),
            if (entries7dAvg.isNotEmpty && !currentCategory.metricType.isSummedPerDay)
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
                              arguments: currentCategory.id,
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
                                MeasurementEntryForm(currentCategory.id!),
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

  /// Card for a multi-value group (e.g. blood pressure): one row per
  /// component with its latest reading; new readings are entered for all
  /// components at once.
  Widget _buildGroupCard(BuildContext context) {
    return Card(
      elevation: elevation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              currentCategory.name,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...currentCategory.children.map((child) {
            // Entries arrive sorted by date descending, so first is the latest
            final latest = child.entries.firstOrNull;
            return ListTile(
              dense: true,
              title: Text(child.name),
              trailing: Text(
                latest != null ? '${latest.value} ${child.unit}' : '—',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () => Navigator.pushNamed(
                context,
                MeasurementEntriesScreen.routeName,
                arguments: child.id,
              ),
            );
          }),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    AppLocalizations.of(context).newEntry,
                    GroupMeasurementEntryForm(currentCategory),
                  ),
                );
              },
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
