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
      itemBuilder: (context, index) => Card(
        child: ListTile(
          onTap: () => Navigator.of(context).pushNamed(
            WorkoutPlanScreen.routeName,
            arguments: workoutPlansData.items[index],
          ),
          leading: FlutterLogo(size: 56.0),
          title: Text(
            DateFormat('dd.MM.yyyy')
                .format(workoutPlansData.items[index].creationDate)
                .toString(),
          ),
          subtitle: Text(workoutPlansData.items[index].description),
        ),
      ),
    );
  }
}
