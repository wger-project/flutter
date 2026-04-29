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
import 'package:intl/intl.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition_notifier.dart';
import 'package:wger/providers/user_profile_notifier.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/core/async_value_widget.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/measurements/helpers.dart';
import 'package:wger/widgets/weight/forms.dart';

class WeightOverview extends riverpod.ConsumerWidget {
  const WeightOverview();

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final plans = ref.watch(nutritionProvider).value?.plans ?? const [];

    return AsyncValueWidget<List<WeightEntry>>(
      value: ref.watch(weightEntryProvider),
      loggerName: 'WeightOverview',
      data: (entriesList) {
        // Profile drives the unit display; show a spinner while it loads
        // instead of bang-ing on a null value.
        final profile = profileAsync.value;
        if (profile == null) {
          return const BoxedProgressIndicator();
        }

        final entriesAll = entriesList.map((e) => MeasurementChartEntry(e.weight, e.date)).toList();
        final entries7dAvg = moving7dAverage(entriesAll);

        final unit = weightUnit(profile.isMetric, context);

        return Column(
          children: [
            ...getOverviewWidgetsSeries(
              AppLocalizations.of(context).weight,
              entriesAll,
              entries7dAvg,
              plans,
              unit,
              context,
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
                        '${numberFormat.format(currentEntry.weight)} ${weightUnit(profile.isMetric, context)}',
                      ),
                      subtitle: Text(
                        DateFormat.yMd(
                          Localizations.localeOf(context).languageCode,
                        ).add_Hm().format(currentEntry.date),
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
                                  WeightForm(currentEntry),
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              child: Text(AppLocalizations.of(context).delete),
                              onTap: () async {
                                await ref
                                    .read(weightEntryProvider.notifier)
                                    .deleteEntry(currentEntry.id!);

                                // and inform the user
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context).successfullyDeleted,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
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
