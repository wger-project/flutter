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
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/measurements/charts.dart';

import 'forms.dart';

class EntriesList extends StatelessWidget {
  final MeasurementCategory _category;

  const EntriesList(this._category);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(10),
        height: 220,
        child: MeasurementChartWidgetFl(
          _category.entries.map((e) => MeasurementChartEntry(e.value, e.date)).toList(),
          unit: _category.unit,
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: _category.entries.length,
          itemBuilder: (context, index) {
            final currentEntry = _category.entries[index];
            final provider = Provider.of<MeasurementProvider>(context, listen: false);

            return Card(
              child: ListTile(
                title: Text('${currentEntry.value} ${_category.unit}'),
                subtitle: Text(
                  DateFormat.yMd(Localizations.localeOf(context).languageCode)
                      .format(currentEntry.date),
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
                            MeasurementEntryForm(
                              currentEntry.category,
                              currentEntry,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        child: Text(AppLocalizations.of(context).delete),
                        onTap: () async {
                          // Delete entry from DB
                          await provider.deleteEntry(
                            currentEntry.id!,
                            currentEntry.category,
                          );

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
    ]);
  }
}
