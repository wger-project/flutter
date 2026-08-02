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
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:wger/core/form_screen.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/core/snackbar.dart';
import 'package:wger/core/widgets/async_value_widget.dart';
import 'package:wger/core/widgets/progress_indicator.dart';
import 'package:wger/features/account/providers/user_profile_notifier.dart';
import 'package:wger/features/measurements/measurements.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/unit_conversion.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/widgets/chart_range_selector.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/features/nutrition/models/nutritional_plan.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/features/weight/providers/body_weight_provider.dart';
import 'package:wger/features/weight/widgets/forms.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class WeightOverview extends riverpod.ConsumerWidget {
  /// Range the entries were read for. Owned by the screen, because it bounds
  /// the query that reads them, not only the span the chart draws.
  final ChartRange range;
  final ValueChanged<ChartRange> onRangeChanged;

  const WeightOverview({required this.range, required this.onRangeChanged});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final numberFormat = localizedNumberFormat(context);
    final planPeriods = [
      for (final plan in ref.watch(nutritionProvider).value?.plans ?? const <NutritionalPlan>[])
        (
          range: DateTimeRange(start: plan.startDate, end: plan.endDate ?? DateTime.now()),
          name: plan.getLabel(context),
        ),
    ];

    return AsyncValueWidget<MeasurementCategory?>(
      value: ref.watch(bodyWeightCategorySinceProvider(range.readCutoff)),
      loggerName: 'WeightOverview',
      data: (category) {
        // Profile drives the unit display; show a spinner while it loads
        // instead of bang-ing on a null value. The category is created by the
        // server, so a null there just means the initial sync is still running.
        final profile = profileAsync.value;
        if (profile == null || category == null) {
          return const BoxedProgressIndicator();
        }

        final entriesList = category.entries;

        // Entries can be stored in mixed units (kg/lb); normalize everything
        // to the profile's display unit before charting or averaging
        final displayUnit = weightDisplayUnit(profile.isMetric);
        final entriesAll = chartEntriesFor(
          entriesList,
          targetUnit: displayUnit,
          categoryUnit: category.unit,
        );
        final entries7dAvg = moving7dAverage(entriesAll);

        // Restrict the data to the selected range. The average is computed
        // first, over the week the query reads beyond the cutoff as well, so
        // the first days in range average the days before them.
        final cutoff = range.cutoff;
        final entriesRange = cutoff == null ? entriesAll : entriesAll.whereDate(cutoff, null);
        final entries7dAvgRange = cutoff == null
            ? entries7dAvg
            : entries7dAvg.whereDate(cutoff, null);

        final unit = weightUnit(profile.isMetric, context);

        return Column(
          children: [
            ChartRangeSelector(
              value: range,
              onChanged: onRangeChanged,
            ),
            ...getOverviewWidgetsSeries(
              i18n.weight,
              entriesRange,
              entries7dAvgRange,
              planPeriods,
              unit,
              context,
              mainChartTitle: range.chartTitle(i18n, i18n.weight),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/measurement-categories',
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(AppLocalizations.of(context).measurements),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: entriesList.length,
                itemBuilder: (context, index) {
                  final currentEntry = entriesList[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        '${numberFormat.format(currentEntry.valueIn(displayUnit, categoryUnit: category.unit))} ${weightUnit(profile.isMetric, context)}',
                      ),
                      subtitle: Text(
                        localizedDate(context).add_Hm().format(currentEntry.date),
                      ),
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
                                        WeightForm(category, currentEntry),
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: Text(AppLocalizations.of(context).delete),
                                    onTap: () async {
                                      await ref
                                          .read(measurementProvider.notifier)
                                          .deleteEntry(currentEntry.id!);

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
      },
    );
  }
}
