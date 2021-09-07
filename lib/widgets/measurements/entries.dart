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
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/charts.dart';

import 'forms.dart';

class EntriesList extends StatelessWidget {
  MeasurementCategory _category;

  EntriesList(this._category);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: EdgeInsets.all(10),
        height: 220,
        child: MeasurementChartWidget(
          _category.entries.map((e) => MeasurementChartEntry(e.value, e.date)).toList(),
          unit: this._category.unit,
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: _category.entries.length,
          itemBuilder: (context, index) {
            final currentEntry = _category.entries[index];
            final provider = Provider.of<MeasurementProvider>(context, listen: false);

            return Dismissible(
              key: Key(currentEntry.id.toString()),
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) {
                  // Delete entry from DB
                  provider.deleteEntry(currentEntry.id!, currentEntry.category);

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
                      MeasurementEntryForm(currentEntry.category, currentEntry),
                    ),
                  );
                  return false;
                }
                return true;
              },
              secondaryBackground: Container(
                color: Theme.of(context).errorColor,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                margin: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              background: Container(
                color: wgerPrimaryButtonColor,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
                margin: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
              child: Card(
                child: ListTile(
                  title: Text('${currentEntry.value.toString()} ${_category.unit}'),
                  subtitle: Text(
                    DateFormat.yMd(Localizations.localeOf(context).languageCode)
                        .format(currentEntry.date),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
