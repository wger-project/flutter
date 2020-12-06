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

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/theme/theme.dart';

class WeightEntriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weightEntriesData = Provider.of<BodyWeight>(context);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          height: 220,
          child: charts.TimeSeriesChart(
            [
              charts.Series<WeightEntry, DateTime>(
                id: 'Weight',
                colorFn: (_, __) => wgerChartSecondaryColor,
                domainFn: (WeightEntry weightEntry, _) => weightEntry.date,
                measureFn: (WeightEntry weightEntry, _) => weightEntry.weight,
                data: weightEntriesData.items,
              )
            ],
            defaultRenderer: new charts.LineRendererConfig(includePoints: true),
          ),
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: weightEntriesData.items.length,
            itemBuilder: (context, index) {
              final currentEntry = weightEntriesData.items[index];
              return Dismissible(
                key: Key(currentEntry.id.toString()),
                onDismissed: (direction) {
                  // Delete workout from DB
                  Provider.of<BodyWeight>(context, listen: false).deleteEntry(currentEntry.id);

                  // and inform the user
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Deleted weight entry for the ${DateFormat('dd.MM.yyyy').format(currentEntry.date).toString()}",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                background: Container(
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
                direction: DismissDirection.endToStart,
                child: Card(
                  child: ListTile(
                    //onTap: () => Navigator.of(context).pushNamed(
                    //  WorkoutPlanScreen.routeName,
                    //  arguments: currentPlan,
                    //),
                    onTap: () {},
                    title: Text(
                      DateFormat('dd.MM.yyyy').format(currentEntry.date).toString(),
                    ),
                    subtitle: Text('${currentEntry.weight} kg'),
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
