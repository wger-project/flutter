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
                        "Weight entry for the ${currentEntry.date}",
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
