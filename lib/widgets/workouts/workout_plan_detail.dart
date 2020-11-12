import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/widgets/workouts/day.dart';

class WorkoutPlansDetail extends StatelessWidget {
  WorkoutPlan _workoutPlan;
  WorkoutPlansDetail(this._workoutPlan);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              DateFormat('dd.MM.yyyy').format(_workoutPlan.creationDate).toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          if (_workoutPlan.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _workoutPlan.description,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          _workoutPlan.days != null
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _workoutPlan.days.length,
                    itemBuilder: (context, index) {
                      Day workoutDay = _workoutPlan.days[index];
                      return WorkoutDayWidget(workoutDay);
                    },
                  ),
                )
              : Text('No days'),
        ],
      ),
    );
  }
}
