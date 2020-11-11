import 'package:flutter/material.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';

class SettingWidget extends StatelessWidget {
  Setting setting;

  SettingWidget({this.setting});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        child: setting.exercise.images.length > 0
            ? FadeInImage(
                placeholder: AssetImage('assets/images/placeholder.png'),
                image: NetworkImage(setting.exercise.getMainImage.url),
                fit: BoxFit.cover,
              )
            : Image(
                image: AssetImage('assets/images/placeholder.png'),
                color: Color.fromRGBO(255, 255, 255, 0.3),
                colorBlendMode: BlendMode.modulate),
        width: 65,
      ),
      title: Text(setting.exercise.name),
      subtitle: Text(setting.repsText),
    );
  }
}

class WorkoutDayWidget extends StatelessWidget {
  Day _day;

  WorkoutDayWidget(this._day);

  Widget getSetRow(Set set) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Text('#${set.order}'),
        Expanded(
          child: Column(
            children: set.settings
                .map(
                  (setting) => SettingWidget(setting: setting),
                )
                .toList(),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          Text(
            _day.description,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(_day.getAllDays),
          Divider(),
          ..._day.sets
              .map(
                (set) => getSetRow(set),
              )
              .toList(),
        ],
      ),
    );
  }
}
