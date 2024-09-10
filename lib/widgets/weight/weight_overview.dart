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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/measurement_categories_screen.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/weight/forms.dart';

class WeightOverview extends StatelessWidget {
  const WeightOverview();
  @override
  Widget build(BuildContext context) {
    final profile = context.read<UserProvider>().profile;
    final weightProvider = Provider.of<BodyWeightProvider>(context, listen: false);
    final plan = Provider.of<NutritionPlansProvider>(context, listen: false).currentPlan;

    final entriesAll =
        weightProvider.items.map((e) => MeasurementChartEntry(e.weight, e.date)).toList();
    final entries7dAvg = moving7dAverage(entriesAll);

    List<Widget> getOverviewWidgets(String title, bool isMetric, List<MeasurementChartEntry> raw,
        List<MeasurementChartEntry> avg, BuildContext context) {
      return [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Container(
          padding: const EdgeInsets.all(15),
          height: 220,
          child: MeasurementChartWidgetFl(
            raw,
            weightUnit(isMetric, context),
            avgs: avg,
          ),
        ),
        MeasurementOverallChangeWidget(
          avg.first,
          avg.last,
          weightUnit(isMetric, context),
        ),
        const SizedBox(height: 8),
      ];
    }

    return Column(
      children: [
        ...getOverviewWidgets(
          'Weight all-time',
          profile!.isMetric,
          entriesAll,
          entries7dAvg,
          context,
        ),
        if (plan != null)
          ...getOverviewWidgets(
            'Weight during nutritional plan ${plan.description}',
            profile.isMetric,
            entriesAll.where((e) => e.date.isAfter(plan.creationDate)).toList(),
            entries7dAvg.where((e) => e.date.isAfter(plan.creationDate)).toList(),
            context,
          ),
        // if all time is significantly longer than 30 days (let's say > 75 days)
        // and if there is is a plan and it also was > 75 days,
        // then let's show a separate chart just focusing on the last 30 days
        if (entriesAll.first.date
                .isBefore(entriesAll.last.date.subtract(const Duration(days: 75))) &&
            (plan == null ||
                entriesAll
                    .firstWhere((e) => e.date.isAfter(plan.creationDate))
                    .date
                    .isBefore(entriesAll.last.date.subtract(const Duration(days: 30)))))
          ...getOverviewWidgets(
            'Weight last 30 days',
            profile.isMetric,
            entriesAll
                .where((e) => e.date.isAfter(DateTime.now().subtract(const Duration(days: 30))))
                .toList(),
            entries7dAvg
                .where((e) => e.date.isAfter(DateTime.now().subtract(const Duration(days: 30))))
                .toList(),
            context,
          ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Indicator(color: Theme.of(context).colorScheme.primary, text: 'raw', isSquare: true),
            Indicator(color: Theme.of(context).colorScheme.tertiary, text: 'avg', isSquare: true),
          ],
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(
            context,
            MeasurementCategoriesScreen.routeName,
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
          child: RefreshIndicator(
            onRefresh: () => weightProvider.fetchAndSetEntries(),
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: weightProvider.items.length,
              itemBuilder: (context, index) {
                final currentEntry = weightProvider.items[index];
                return Card(
                  child: ListTile(
                    title: Text('${currentEntry.weight} ${weightUnit(profile.isMetric, context)}'),
                    subtitle: Text(
                      DateFormat.yMd(
                        Localizations.localeOf(context).languageCode,
                      ).format(currentEntry.date),
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
                              // Delete entry from DB
                              await weightProvider.deleteEntry(currentEntry.id!);

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
        ),
      ],
    );
  }
}
