/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/widgets/weight/charts.dart';
import 'package:wger/widgets/weight/forms.dart';

class WeightEntriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _weightProvider = Provider.of<BodyWeight>(context, listen: false);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          height: 220,
          child: WeightChartWidget(_weightProvider.items),
        ),
        Divider(),
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
                          "Deleted weight entry for the ${DateFormat.yMd().format(currentEntry.date).toString()}",
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
                        AppLocalizations.of(context)!.edit,
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
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(right: 20),
                  margin: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Icon(
                    Icons.edit,
                    //color: Colors.white,
                  ),
                ),
                child: Card(
                  child: ListTile(
                    onTap: () {},
                    title: Text('${currentEntry.weight} kg'),
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
      ],
    );
  }
}
