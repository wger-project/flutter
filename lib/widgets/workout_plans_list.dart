import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/workout_plans.dart';

class WorkoutPlansList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workoutPlansData = Provider.of<WorkoutPlans>(context);
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: workoutPlansData.items.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          leading: FlutterLogo(size: 56.0),
          title: Text(
            DateFormat('dd.MM.yyyy')
                .format(workoutPlansData.items[index].creation_date)
                .toString(),
          ),
          subtitle: Text(workoutPlansData.items[index].description),
        ),
      ),
    );
  }
}
