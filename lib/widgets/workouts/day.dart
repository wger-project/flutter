/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/workouts/forms.dart';

class SettingWidget extends StatelessWidget {
  Setting setting;

  SettingWidget({this.setting});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        child: setting.exerciseObj.images.length > 0
            ? FadeInImage(
                placeholder: AssetImage('assets/images/placeholder.png'),
                image: NetworkImage(setting.exerciseObj.getMainImage.url),
                fit: BoxFit.cover,
              )
            : Image(
                image: AssetImage('assets/images/placeholder.png'),
                color: Color.fromRGBO(255, 255, 255, 0.3),
                colorBlendMode: BlendMode.modulate),
        width: 45,
      ),
      title: Text(setting.exerciseObj.name),
      subtitle: Text(setting.repsText),
      trailing: IconButton(
        visualDensity: VisualDensity.compact,
        icon: Icon(Icons.delete),
        //iconSize: 16,
        onPressed: () {
          Provider.of<WorkoutPlans>(context, listen: false).deleteSetting(setting);
        },
      ),
    );
  }
}

class WorkoutDayWidget extends StatelessWidget {
  final Day _day;

  WorkoutDayWidget(this._day);

  Widget getSetRow(Set set) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Column(
            children: [
              ...set.settings
                  .map(
                    (setting) => SettingWidget(setting: setting),
                  )
                  .toList(),
              Divider(),
            ],
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
          DayHeaderDismissible(day: _day),
          ..._day.sets
              .map(
                (set) => getSetRow(set),
              )
              .toList(),
          OutlinedButton(
            child: Text('Add exercise to day'),
            onPressed: () {
              showFormBottomSheet(
                context,
                AppLocalizations.of(context).newSet,
                SetFormWidget(_day),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
          )
        ],
      ),
    );
  }
}

class DayHeaderDismissible extends StatelessWidget {
  const DayHeaderDismissible({
    Key key,
    @required Day day,
  })  : _day = day,
        super(key: key);

  final Day _day;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(_day.id.toString()),
      child: Container(
        decoration: BoxDecoration(color: Colors.black12),
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        child: Column(
          children: [
            Text(
              _day.description,
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(_day.getDaysText),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).primaryColor,
        padding: EdgeInsets.only(right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.bar_chart,
              color: Colors.white,
            ),
            Text(
              'Log weights',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      background: Container(
        color: Theme.of(context).accentColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Gym mode',
              style: TextStyle(color: Colors.white),
            ),
            Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Weight log
        if (direction == DismissDirection.endToStart) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text('Would open weight log form for this day'),
              actions: [
                TextButton(
                  child: Text("Close"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );

          // Gym mode
        } else {
          Navigator.of(context).pushNamed(GymModeScreen.routeName, arguments: _day);
        }
        return false;
      },
    );
  }
}
