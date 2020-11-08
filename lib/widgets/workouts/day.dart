import 'package:flutter/material.dart';
import 'package:wger/models/workouts/day.dart';

class WorkoutDayWidget extends StatelessWidget {
  Day _day;

  WorkoutDayWidget(this._day);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Day #${_day.id} - ${_day.description}',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Divider(),
        Container(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _day.sets.length,
            itemBuilder: (context, index) {
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Text('#${_day.sets[index].order}'),
                      title: Text('Exercise name here'),
                      subtitle: Text('Set info here'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        /*
        Container(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _day.sets.length,
            itemBuilder: (context, index) {
              return Text('Set #${_day.sets[index].id}');
            },
          ),
        ),
         */
      ],
    );
  }
}
