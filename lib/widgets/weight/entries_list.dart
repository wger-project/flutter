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
import 'package:wger/providers/user.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/measurement_categories_screen.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/weight/forms.dart';

class WeightEntriesList extends StatelessWidget {
  const WeightEntriesList();
  @override
  Widget build(BuildContext context) {
    final profile = context.read<UserProvider>().profile;
    final weightProvider = Provider.of<BodyWeightProvider>(context, listen: false);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          height: 220,
          child: MeasurementChartWidgetFl(
            weightProvider.items.map((e) => MeasurementChartEntry(e.weight, e.date)).toList(),
            unit: profile!.isMetric
                ? AppLocalizations.of(context).kg
                : AppLocalizations.of(context).lb,
          ),
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => weightProvider.fetchAndSetEntries(),
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: weightProvider.items.length,
              itemBuilder: (context, index) {
                final currentEntry = weightProvider.items[index];
                return Card(
                  child: ListTile(
                    title: Text('${currentEntry.weight} kg'),
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
