/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/exercises/exercises.dart';
import 'package:wger/widgets/exercises/images.dart';
import 'package:wger/widgets/workouts/forms.dart';

class SettingWidget extends StatelessWidget {
  Set set;
  Setting setting;
  final bool expanded;
  final toggle;

  SettingWidget({
    required this.set,
    required this.setting,
    required this.expanded,
    required this.toggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: InkWell(
        child: Container(
          child: ExerciseImageWidget(image: setting.exerciseObj.getMainImage),
          width: 45,
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(setting.exerciseObj.name),
                content: ExerciseDetail(setting.exerciseObj),
                actions: [
                  TextButton(
                    child: Text(AppLocalizations.of(context)!.dismiss),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      title: Text(setting.exerciseObj.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...set.getSmartRepr(setting.exerciseObj).map((e) => Text(e)).toList(),
        ],
      ),
    );
  }
}

class WorkoutDayWidget extends StatefulWidget {
  final Day _day;

  WorkoutDayWidget(this._day);

  @override
  _WorkoutDayWidgetState createState() => _WorkoutDayWidgetState();
}

class _WorkoutDayWidgetState extends State<WorkoutDayWidget> {
  bool _expanded = false;
  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  Widget getSetRow(Set set) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Column(
            children: [
              ...set.settingsFiltered
                  .map(
                    (setting) => SettingWidget(
                      set: set,
                      setting: setting,
                      expanded: _expanded,
                      toggle: _toggleExpanded,
                    ),
                  )
                  .toList(),
              Divider(),
            ],
          ),
        ),
        if (_expanded)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.delete),
            iconSize: ICON_SIZE_SMALL,
            onPressed: () {
              Provider.of<WorkoutPlans>(context, listen: false).deleteSet(set);
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      child: Card(
        child: Column(
          children: [
            DayHeaderDismissible(
              day: widget._day,
              expanded: _expanded,
              toggle: _toggleExpanded,
            ),
            ...widget._day.sets
                .map(
                  (set) => getSetRow(set),
                )
                .toList(),
            OutlinedButton(
              child: Text(AppLocalizations.of(context)!.addExercise),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  FormScreen.routeName,
                  arguments: FormScreenArguments(
                    AppLocalizations.of(context)!.newSet,
                    SetFormWidget(widget._day),
                    true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DayHeaderDismissible extends StatelessWidget {
  final Day _day;
  final bool _expanded;
  final _toggle;

  const DayHeaderDismissible({
    required Day day,
    required bool expanded,
    required Function toggle,
  })   : _day = day,
        _expanded = expanded,
        _toggle = toggle;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(_day.id.toString()),
      direction: DismissDirection.horizontal,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.drag_indicator,
              color: Colors.grey,
              size: ICON_SIZE_SMALL,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _day.description,
                    style: Theme.of(context).textTheme.headline5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(_day.getDaysTextTranslated(Localizations.localeOf(context).languageCode)),
                ],
              ),
            ),
            IconButton(
              icon: _expanded ? Icon(Icons.expand_less) : Icon(Icons.expand_more),
              onPressed: () {
                _toggle();
              },
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).accentColor,
        padding: EdgeInsets.only(right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
          ],
        ),
      ),
      background: Container(
        color: wgerPrimaryButtonColor, //Theme.of(context).primaryColor,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.gymMode,
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
        // Delete day
        if (direction == DismissDirection.endToStart) {
          Provider.of<WorkoutPlans>(context, listen: false).deleteDay(_day);

          // Gym mode
        } else {
          Navigator.of(context).pushNamed(GymModeScreen.routeName, arguments: _day);
        }
        return false;
      },
    );
  }
}
