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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/form_screen.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/features/measurements/measurements.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/chart_range_selector.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import 'charts.dart';
import 'forms.dart';

class CategoriesCard extends ConsumerWidget {
  final MeasurementCategory currentCategory;
  final double? elevation;
  final ChartRange range;

  const CategoriesCard(
    this.currentCategory, {
    this.elevation,
    this.range = ChartRange.last3Months,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (currentCategory.isGroup) {
      return _buildGroupCard(context, ref);
    }

    final cutoff = range.cutoff;
    final allEntries = chartEntriesFor(
      currentCategory.entries,
      targetUnit: currentCategory.unit,
      categoryUnit: currentCategory.unit,
    );
    // The average is computed over the full history and only then cut, so the
    // first points of the range average the days before it instead of starting
    // over at the cutoff
    final settings = currentCategory.chartSettings;
    final allAverage = movingAverage(allEntries, days: settings.averageWindow);
    final entriesAll = cutoff == null ? allEntries : allEntries.whereDate(cutoff, null);
    final average = cutoff == null ? allAverage : allAverage.whereDate(cutoff, null);

    return Card(
      elevation: elevation,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                currentCategory.displayName(context),
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
                average,
                currentCategory.unit,
                chartType: currentCategory.chartType,
                settings: settings,
              ),
            ),
            if (average.isNotEmpty && !currentCategory.metricType.isSummedPerDay)
              MeasurementOverallChangeWidget(
                average.first,
                average.last,
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

  /// Card for a multi-value group (e.g. blood pressure): all components in one
  /// chart, then one row per component with its latest reading; new readings
  /// are entered for all components at once.
  Widget _buildGroupCard(BuildContext context, WidgetRef ref) {
    final cutoff = range.cutoff;
    final hasData = groupHasData(currentCategory, cutoff: cutoff);
    // A range is a single bar whose ends speak for themselves, and a stacked
    // bar's segments carry the component colours; only the line chart needs
    // the dots on the rows below to tie a component to its line.
    final asRange =
        currentCategory.children.length == 2 &&
        groupRangeEntries(currentCategory, cutoff: cutoff).isNotEmpty;
    // The stacked chart draws only the components that are parts of the whole,
    // so a row's colour has to come from that list rather than from its
    // position among all children
    final stacked = currentCategory.metricType.isSummedPerDay
        ? stackableComponents(currentCategory)
        : null;

    return Card(
      elevation: elevation,
      // Scrolls like the leaf card above: a group of five components (the
      // sleep stages) is taller than the box the dashboard carousel gives it
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                currentCategory.displayName(context),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasData)
              Container(
                padding: const EdgeInsets.all(10),
                height: 220,
                child: buildGroupChart(context, currentCategory, cutoff: cutoff),
              ),
            ...currentCategory.children.mapIndexed((index, child) {
              // Read separately rather than taken from the entries above: those
              // cover the charted range, and a component measured less often
              // than that still has a last known value worth showing
              final latest = ref.watch(latestMeasurementEntriesProvider).value?[child.id];
              final colorIndex = stacked == null
                  ? index
                  : stacked.indexWhere((c) => c.id == child.id);
              return ListTile(
                dense: true,
                // The dot ties the row to its part of the chart above. A range
                // is a single bar, where the ends speak for themselves, and a
                // roll-up component is no segment of the stack.
                leading: asRange || colorIndex < 0
                    ? null
                    : Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: componentColor(context, colorIndex),
                        ),
                      ),
                title: Text(child.displayName(context)),
                trailing: Text(
                  latest != null
                      ? measurementWithUnit(
                          context,
                          latest.valueIn(child.unit, categoryUnit: child.unit),
                          child.unit,
                        )
                      : '—',
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
            Row(
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
                        GroupMeasurementEntryForm(currentCategory),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
