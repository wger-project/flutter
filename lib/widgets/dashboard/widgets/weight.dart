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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/measurements/helpers.dart';
import 'package:wger/widgets/weight/forms.dart';

class DashboardWeightWidget extends StatelessWidget {
  const DashboardWeightWidget();

  @override
  Widget build(BuildContext context) {
    final profile = context.read<UserProvider>().profile;
    final weightProvider = context.read<BodyWeightProvider>();

    final (entriesAll, entries7dAvg) = sensibleRange(
      weightProvider.items.map((e) => MeasurementChartEntry(e.weight, e.date)).toList(),
    );

    return Consumer<BodyWeightProvider>(
      builder: (context, _, __) => Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context).weight,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              leading: FaIcon(
                FontAwesomeIcons.weightScale,
                color: Theme.of(context).textTheme.headlineSmall!.color,
              ),
            ),
            Column(
              children: [
                if (weightProvider.items.isNotEmpty)
                  Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: MeasurementChartWidgetFl(
                          entriesAll,
                          weightUnit(profile!.isMetric, context),
                          avgs: entries7dAvg,
                        ),
                      ),
                      if (entries7dAvg.isNotEmpty)
                        MeasurementOverallChangeWidget(
                          entries7dAvg.first,
                          entries7dAvg.last,
                          weightUnit(profile.isMetric, context),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: Text(
                              AppLocalizations.of(context).goToDetailPage,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamed(WeightScreen.routeName);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                FormScreen.routeName,
                                arguments: FormScreenArguments(
                                  AppLocalizations.of(context).newEntry,
                                  WeightForm(weightProvider
                                      .getNewestEntry()
                                      ?.copyWith(id: null, date: DateTime.now())),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  NothingFound(
                    AppLocalizations.of(context).noWeightEntries,
                    AppLocalizations.of(context).newEntry,
                    WeightForm(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
