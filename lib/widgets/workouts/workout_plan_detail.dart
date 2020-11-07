import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wger/providers/workout_plan.dart';

class WorkoutPlansDetail extends StatelessWidget {
  WorkoutPlan _workoutPlan;
  WorkoutPlansDetail(this._workoutPlan);

  @override
  Widget build(BuildContext context) {
    //print('yyyyyyyyyyyyyyyyyy');
    //print(_workoutPlan.description);
    //print(_workoutPlan.days);
    //print('yyyyyyyyyyyyyyyyyy');
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Workout ${DateFormat('dd.MM.yyyy').format(_workoutPlan.creationDate)}',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Divider(),
          if (_workoutPlan.description != null)
            Text(
              _workoutPlan.description,
              style: Theme.of(context).textTheme.headline5,
            ),
          _workoutPlan.days != null
              ? Container(
                  child: ListView.builder(
                    itemCount: _workoutPlan.days.length,
                    itemBuilder: (context, index) {
                      print(index);
                      return Text("Day");
                      //Day workoutDay = _workoutPlan.days[index];
                      //return WorkoutDayWidget(workoutDay);
                    },
                  ),
                )
              : Text('No days'),
        ],
      ),
    );
  }
}
