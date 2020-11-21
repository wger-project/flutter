import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/workout_plan_screen.dart';

class WorkoutPlansList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workoutPlansData = Provider.of<WorkoutPlans>(context);
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: workoutPlansData.items.length,
      itemBuilder: (context, index) {
        final currentWorkout = workoutPlansData.items[index];
        return Dismissible(
          key: Key(currentWorkout.id.toString()),
          onDismissed: (direction) {
            // Delete workout from DB
            Provider.of<WorkoutPlans>(context, listen: false).deleteWorkout(currentWorkout.id);

            // and inform the user
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Workout "${currentWorkout.description}" deleted',
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
              onTap: () => Navigator.of(context).pushNamed(
                WorkoutPlanScreen.routeName,
                arguments: currentWorkout,
              ),
              title: Text(
                DateFormat('dd.MM.yyyy').format(currentWorkout.creationDate).toString(),
              ),
              subtitle: Text(currentWorkout.description),
            ),
          ),
        );
      },
    );
  }
}
