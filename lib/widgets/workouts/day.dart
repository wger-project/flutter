import 'package:flutter/material.dart';
import 'package:wger/models/workouts/day.dart';

class WorkoutDayWidget extends StatelessWidget {
  Day _day;

  WorkoutDayWidget(this._day);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Day #${_day.id} - ${_day.description}',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
