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
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/features/weight/providers/body_weight_provider.dart';
import 'package:wger/features/weight/widgets/forms.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Time range the user can pick to limit how far back the weight chart goes.
enum WeightChartRange { all, lastYear, last3Months }

class WeightOverview extends riverpod.ConsumerStatefulWidget {
  const WeightOverview();

  @override
  riverpod.ConsumerState<WeightOverview> createState() => _WeightOverviewState();
}

class _WeightOverviewState extends riverpod.ConsumerState<WeightOverview> {
  WeightChartRange _range = WeightChartRange.all;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final numberFormat = localizedNumberFormat(context);
    final plans = ref.watch(nutritionProvider).value?.plans ?? const [];

    return AsyncValueWidget<MeasurementCategory?>(
      value: ref.watch(bodyWeightCategoryProvider),
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
        final entriesAll = entriesList.map((e) => MeasurementChartEntry(e.value, e.date)).toList();
        final entries7dAvg = moving7dAverage(entriesAll);

        // Restrict the data to the selected range. The average is computed over
        // the full history first and only filtered afterwards, matching how the
        // per-plan and 30-day sub-charts are built.
        final (DateTime? cutoff, String? mainChartTitle) = switch (_range) {
          WeightChartRange.all => (null, null),
          WeightChartRange.lastYear => (
            DateTime.now().subtract(const Duration(days: 365)),
            i18n.chartLastYearTitle(i18n.weight),
          ),
          WeightChartRange.last3Months => (
            DateTime.now().subtract(const Duration(days: 90)),
            i18n.chartLast3MonthsTitle(i18n.weight),
          ),
        };
        final entriesRange = cutoff == null ? entriesAll : entriesAll.whereDate(cutoff, null);
        final entries7dAvgRange = cutoff == null
            ? entries7dAvg
            : entries7dAvg.whereDate(cutoff, null);

        final unit = weightUnit(profile.isMetric, context);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<WeightChartRange>(
                  key: const ValueKey('weightChartRangeSelector'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: WeightChartRange.all,
                      label: Text(i18n.chartRangeAll),
                    ),
                    ButtonSegment(
                      value: WeightChartRange.lastYear,
                      label: Text(i18n.chartRangeLastYear),
                    ),
                    ButtonSegment(
                      value: WeightChartRange.last3Months,
                      label: Text(i18n.chartRangeLast3Months),
                    ),
                  ],
                  selected: {_range},
                  onSelectionChanged: (selection) => setState(() => _range = selection.first),
                ),
              ),
            ),
            ...getOverviewWidgetsSeries(
              i18n.weight,
              entriesRange,
              entries7dAvgRange,
              plans,
              unit,
              context,
              mainChartTitle: mainChartTitle,
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
                        '${numberFormat.format(currentEntry.value)} ${weightUnit(profile.isMetric, context)}',
                      ),
                      subtitle: Text(
                        localizedDate(context).add_Hm().format(currentEntry.date),
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              child: Text(AppLocalizations.of(context).edit),
                              onTap: () => Navigator.pushNamed(
                                context,
                                FormScreen.routeName,
                                arguments: FormScreenArguments(
                                  AppLocalizations.of(context).edit,
                                  WeightForm(category.id!, currentEntry),
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
