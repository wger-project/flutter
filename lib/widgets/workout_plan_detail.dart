import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/providers/workout_plan.dart';

class WorkoutPlansDetail extends StatelessWidget {
  WorkoutPlan _workoutPlan;

  WorkoutPlansDetail(this._workoutPlan);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Workout ${DateFormat('dd.MM.yyyy').format(_workoutPlan.creation_date)}',
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
          Divider()
        ],
      ),
    );
  }
}
