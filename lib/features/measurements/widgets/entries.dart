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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/form_screen.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/core/snackbar.dart';
import 'package:wger/features/measurements/measurements.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
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
}
