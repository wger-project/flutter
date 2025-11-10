/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
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
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/measurements/helpers.dart';
import 'package:wger/widgets/weight/forms.dart';

class WeightOverview extends riverpod.ConsumerWidget {
  const WeightOverview();

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final profile = context.read<UserProvider>().profile;
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final plans = context.read<NutritionPlansProvider>().items;

    final entries = ref.watch(weightEntryProvider);
    return entries.when(
      data: (entriesList) {
        final entriesAll = entriesList.map((e) => MeasurementChartEntry(e.weight, e.date)).toList();
        final entries7dAvg = moving7dAverage(entriesAll);

        final unit = weightUnit(profile!.isMetric, context);

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
      loading: () => const BoxedProgressIndicator(),
      error: (err, st) {
        return Column(
          children: [
            Text('Error loading local weights: $err'),
            Text(st.toString()),

            const SizedBox(height: 200, child: Center(child: Icon(Icons.error))),
          ],
        );
      },
    );
  }
}
