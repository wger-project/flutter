import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/body_weight.dart';

class WeightEntriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weightEntriesData = Provider.of<BodyWeight>(context);
    return ListView.builder(
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
    );
  }
}
