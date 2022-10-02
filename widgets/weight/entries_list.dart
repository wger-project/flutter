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
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/measurement_categories_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/charts.dart';
import 'package:wger/widgets/weight/forms.dart';

class WeightEntriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _weightProvider = Provider.of<BodyWeightProvider>(context, listen: false);

    return Column(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.all(15),
          height: 220,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MeasurementChartWidget(
                _weightProvider.items.map((e) => MeasurementChartEntry(e.weight, e.date)).toList()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(),
              ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ))),
                onPressed: () => Navigator.pushNamed(
                  context,
                  MeasurementCategoriesScreen.routeName,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      AppLocalizations.of(context).measurements,
                    ),
                    const Icon(Icons.chevron_right)
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: _weightProvider.items.length,
            itemBuilder: (context, index) {
              final currentEntry = _weightProvider.items[index];
              return Dismissible(
                key: Key(currentEntry.id.toString()),
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    // Delete entry from DB
                    _weightProvider.deleteEntry(currentEntry.id!);

                    // and inform the user
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
                confirmDismiss: (direction) async {
                  // Edit entry
                  if (direction == DismissDirection.startToEnd) {
                    Navigator.pushNamed(
                      context,
                      FormScreen.routeName,
                      arguments: FormScreenArguments(
                        AppLocalizations.of(context).edit,
                        WeightForm(currentEntry),
                      ),
                    );
                    return false;
                  }
                  return true;
                },
                secondaryBackground: Container(
                  color: Theme.of(context).errorColor,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  color: wgerPrimaryButtonColor,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
                child: Card(
                  child: ListTile(
                    title: Text(
                      '${currentEntry.weight} kg',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    subtitle: Text(
                      DateFormat.yMd(Localizations.localeOf(context).languageCode)
                          .format(currentEntry.date),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
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
