import 'package:flutter/material.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/setting.dart';

class SettingWidget extends StatelessWidget {
  Setting setting;

  SettingWidget({this.setting});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: setting.exercise.images.length > 0
          ? Image.network(
              setting.exercise.getMainImage.url,
              fit: BoxFit.cover,
            )
          : FlutterLogo(size: 56.0),
      title: Text(setting.exercise.name),
      subtitle: Text(setting.repsText),
    );
  }
}

class WorkoutDayWidget extends StatelessWidget {
  Day _day;

  WorkoutDayWidget(this._day);

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
                (set) => Row(
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
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
