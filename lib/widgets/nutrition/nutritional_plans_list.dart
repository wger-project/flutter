import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/nutritional_plans.dart';

class NutritionalPlansList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final nutritrionalPlansData = Provider.of<NutritionalPlans>(context);
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: nutritrionalPlansData.items.length,
      itemBuilder: (context, index) {
        final currentPlan = nutritrionalPlansData.items[index];
        return Dismissible(
          key: Key(currentPlan.id.toString()),
          onDismissed: (direction) {
            // Delete workout from DB
            Provider.of<NutritionalPlans>(context, listen: false).deletePlan(currentPlan.id);

            // and inform the user
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Workout ${currentPlan.id} deleted",
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
                DateFormat('dd.MM.yyyy').format(currentPlan.creationDate).toString(),
              ),
              subtitle: Text(currentPlan.description),
            ),
          ),
        );
      },
    );
  }
}
