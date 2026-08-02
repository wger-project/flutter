/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'package:wger/core/snackbar.dart';
import 'package:wger/features/measurements/measurements.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/chart_range_selector.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/features/nutrition/models/nutritional_plan.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import 'forms.dart';

class EntriesList extends ConsumerStatefulWidget {
  final MeasurementCategory category;

  const EntriesList(this.category);

  @override
  ConsumerState<EntriesList> createState() => _EntriesListState();
}

class _EntriesListState extends ConsumerState<EntriesList> {
  ChartRange _range = ChartRange.last3Months;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final category = widget.category;

    // A group carries no entries of its own, its readings live in the
    // components, so everything below would chart an empty list
    if (category.isGroup) {
      return _buildGroup(context, category);
    }

    // Plan periods only matter where a nutrition plan can plausibly move the
    // metric; other categories skip the watch, so nutrition edits don't
    // rebuild them
    final planPeriods = category.metricType.correlatesWithNutrition
        ? [
            for (final plan
                in ref.watch(nutritionProvider).value?.plans ?? const <NutritionalPlan>[])
              (
                range: DateTimeRange(start: plan.startDate, end: plan.endDate ?? DateTime.now()),
                name: plan.getLabel(context),
              ),
          ]
        : const <PlanPeriod>[];
    final numberFormat = localizedNumberFormat(context);
    final provider = ref.read(measurementProvider.notifier);

    // Values are read through the unit helper; for plain categories without
    // per-entry units this is a pass-through to the category unit
    final allEntries = chartEntriesFor(
      category.entries,
      targetUnit: category.unit,
      categoryUnit: category.unit,
    );
    // The average is computed over the full history and only then cut, so the
    // first points of the range average the days before it instead of starting
    // over at the cutoff
    final allAvg = moving7dAverage(allEntries);
    final cutoff = _range.cutoff;
    final entriesAll = cutoff == null ? allEntries : allEntries.whereDate(cutoff, null);
    final entries7dAvg = cutoff == null ? allAvg : allAvg.whereDate(cutoff, null);

    final datetimeFormat = localizedDate(context);

    return Column(
      children: [
        ChartRangeSelector(
          value: _range,
          onChanged: (range) => setState(() => _range = range),
        ),
        ...getOverviewWidgetsSeries(
          category.name,
          entriesAll,
          entries7dAvg,
          planPeriods,
          category.unit,
          context,
          metricType: category.metricType,
          mainChartTitle: _range.chartTitle(i18n, category.name),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: category.entries.length,
            itemBuilder: (context, index) {
              final currentEntry = category.entries[index];

              return Card(
                child: ListTile(
                  title: Text(
                    '${numberFormat.format(currentEntry.valueIn(category.unit, categoryUnit: category.unit))} ${category.unit}',
                  ),
                  subtitle: Text(datetimeFormat.format(currentEntry.date)),
                  // Imported entries are read-only; changes belong in the
                  // source app, deletes would reappear on the next import
                  trailing: currentEntry.source != 'user'
                      ? Tooltip(
                          message: AppLocalizations.of(context).importedEntry,
                          child: const Icon(Icons.monitor_heart_outlined),
                        )
                      : PopupMenuButton(
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                child: Text(AppLocalizations.of(context).edit),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  FormScreen.routeName,
                                  arguments: FormScreenArguments(
                                    AppLocalizations.of(context).edit,
                                    MeasurementEntryForm(
                                      category.id!,
                                      currentEntry,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                child: Text(AppLocalizations.of(context).delete),
                                onTap: () async {
                                  // Delete entry from DB
                                  await provider.deleteEntry(currentEntry.id!);

                                  // and inform the user
                                  if (context.mounted) {
                                    showSnackbar(
                                      context,
                                      AppLocalizations.of(context).successfullyDeleted,
                                      center: true,
                                    );
                                  }
                                },
                              ),
                            ];
                          },
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Detail view of a multi-value group: one chart over all components, a
  /// legend that doubles as the way into each component, and the readings
  /// themselves.
  ///
  /// Readings are shown but not edited here: one of them is several entries,
  /// and the group form only creates. Editing stays on the component screens,
  /// which the legend rows lead to.
  Widget _buildGroup(BuildContext context, MeasurementCategory category) {
    final i18n = AppLocalizations.of(context);
    final numberFormat = localizedNumberFormat(context);
    final datetimeFormat = localizedDate(context);
    final cutoff = _range.cutoff;
    final hasData = groupHasData(category, cutoff: cutoff);
    final readings = groupReadings(category, cutoff: cutoff);
    // Only the stacked chart leaves a component out, so the colours of the
    // rows below have to follow the same list
    final stacked = category.metricType.isSummedPerDay ? stackableComponents(category) : null;

    return Column(
      children: [
        ChartRangeSelector(
          value: _range,
          onChanged: (range) => setState(() => _range = range),
        ),
        Text(
          _range.chartTitle(i18n, category.name),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Container(
          padding: const EdgeInsets.all(15),
          height: 220,
          child: hasData
              ? buildGroupChart(context, category, cutoff: cutoff)
              : Center(
                  child: Text(
                    i18n.noDataAvailable,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
        ),
        ...category.children.mapIndexed((index, child) {
          final colorIndex = stacked == null ? index : stacked.indexWhere((c) => c.id == child.id);
          return ListTile(
            dense: true,
            leading: colorIndex < 0
                ? null
                : Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: componentColor(context, colorIndex),
                    ),
                  ),
            title: Text(child.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(
              context,
              MeasurementEntriesScreen.routeName,
              arguments: child.id,
            ),
          );
        }),
        const Divider(),
        SizedBox(
          height: 300,
          child: ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: readings.length,
            itemBuilder: (context, index) {
              final (date, values) = readings[index];
              final total = category.children
                  .firstWhereOrNull((c) => c.metricType.isGroupTotal)
                  ?.name;
              // A roll-up leads and the parts explain it; without one the
              // values are the reading itself, written the way it is read
              // (a blood pressure as 120/80)
              final headline = total != null && values.containsKey(total)
                  ? '${numberFormat.format(values[total])} ${category.unit}'
                  : '${values.values.sorted((a, b) => b.compareTo(a)).map(numberFormat.format).join('/')} ${category.unit}';
              final parts = [
                for (final MapEntry(key: name, value: value) in values.entries)
                  if (name != total) '$name ${numberFormat.format(value)}',
              ];

              return Card(
                child: ListTile(
                  title: Text(headline),
                  subtitle: Text(
                    [
                      datetimeFormat.format(date),
                      if (parts.isNotEmpty) parts.join(', '),
                    ].join(' · '),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
