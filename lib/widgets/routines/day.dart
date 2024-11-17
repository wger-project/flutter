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
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/set_config_data.dart';
import 'package:wger/models/workouts/slot_data.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/exercises/exercises.dart';
import 'package:wger/widgets/exercises/images.dart';

class SetConfigDataWidget extends StatelessWidget {
  final SetConfigData setConfigData;

  const SetConfigDataWidget({required this.setConfigData});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return ListTile(
      leading: InkWell(
        child: SizedBox(
          width: 45,
          child: ExerciseImageWidget(image: setConfigData.exercise.getMainImage),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(setConfigData.exercise.getExercise(languageCode).name),
                content: ExerciseDetail(setConfigData.exercise),
                actions: [
                  TextButton(
                    child: Text(
                      MaterialLocalizations.of(context).closeButtonLabel,
                    ),
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
      title: Text(setConfigData.exercise.getExercise(languageCode).name),
      subtitle: Text(setConfigData.textRepr),
    );
  }
}

class RoutineDayWidget extends StatelessWidget {
  final DayData _dayData;

  const RoutineDayWidget(this._dayData);

  Widget getSlotDataRow(SlotData slotData) {
    return Column(
      children: [
        if (slotData.comment.isNotEmpty) MutedText(slotData.comment),
        ...slotData.setConfigs.map(
          (setting) => SetConfigDataWidget(setConfigData: setting),
        ),
        // const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DayHeader(day: _dayData),
            ..._dayData.slots.map((e) => getSlotDataRow(e)).toList(),
          ],
        ),
      ),
    );
  }
}

class DayHeader extends StatelessWidget {
  final DayData _dayData;

  const DayHeader({required DayData day}) : _dayData = day;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    if (_dayData.day == null || _dayData.day!.isRest) {
      return ListTile(
        // tileColor: Colors.amber,
        tileColor: Theme.of(context).focusColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          i18n.restDay,
          style: Theme.of(context).textTheme.headlineSmall,
          overflow: TextOverflow.ellipsis,
        ),
        leading: const Icon(Icons.hotel),
        minLeadingWidth: 8,
      );
    }

    return ListTile(
      tileColor: Theme.of(context).focusColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        _dayData.day!.name,
        style: Theme.of(context).textTheme.headlineSmall,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_dayData.day!.description),
      leading: const Icon(Icons.play_arrow),
      minLeadingWidth: 8,
      onTap: () {
        Navigator.of(context).pushNamed(
          GymModeScreen.routeName,
          arguments: _dayData,
        );
      },
    );
  }
}
