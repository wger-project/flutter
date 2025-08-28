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
import 'package:wger/helpers/date.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/slot_data.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/exercises/exercises.dart';
import 'package:wger/widgets/exercises/images.dart';

class SetConfigDataWidget extends StatelessWidget {
  final Exercise exercise;
  final Widget textRepetitionsWidget;

  const SetConfigDataWidget({required this.exercise, required this.textRepetitionsWidget});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return ListTile(
      leading: InkWell(
        child: SizedBox(
          width: 45,
          child: ExerciseImageWidget(image: exercise.getMainImage),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(exercise.getTranslation(languageCode).name),
                content: ExerciseDetail(exercise),
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
      title: Text(exercise.getTranslation(languageCode).name),
      subtitle: textRepetitionsWidget,
    );
  }
}

class RoutineDayWidget extends StatelessWidget {
  final DayData _dayData;
  final int _routineId;
  final bool _viewMode;

  const RoutineDayWidget(this._dayData, this._routineId, this._viewMode);

  Widget getSlotDataRow(SlotData slotData, BuildContext context) {
    return Column(
      children: [
        if (slotData.comment.isNotEmpty) MutedText(slotData.comment),

        // If there's a single exercise with different sets, group them all into
        // the one exercise and don't show separate rows for each one.
        ...slotData.setConfigs
            .fold<Map<Exercise, List<String>>>({}, (acc, entry) {
              acc.putIfAbsent(entry.exercise, () => []).add(entry.textRepr);
              return acc;
            })
            .entries
            .map((entry) {
              return SetConfigDataWidget(
                exercise: entry.key,
                textRepetitionsWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entry.value.map((text) => Text(text)).toList(),
                ),
              );
            }),
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
            DayHeader(day: _dayData, routineId: _routineId, viewMode: _viewMode),
            ..._dayData.slots.map((e) => getSlotDataRow(e, context)),
          ],
        ),
      ),
    );
  }
}

class DayHeader extends StatelessWidget {
  final DayData _dayData;
  final int _routineId;
  final bool _viewMode;

  const DayHeader({required DayData day, required int routineId, bool viewMode = false})
      : _dayData = day,
        _viewMode = viewMode,
        _routineId = routineId;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    if (_dayData.day == null || _dayData.day!.isRest) {
      return ListTile(
        tileColor: Theme.of(context).focusColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          i18n.restDay,
          style: Theme.of(context).textTheme.headlineSmall,
          overflow: TextOverflow.ellipsis,
        ),
        leading: const Icon(Icons.hotel),
        trailing: _dayData.date.isSameDayAs(DateTime.now()) ? const Icon(Icons.today) : null,
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
      leading: _viewMode ? null : const Icon(Icons.play_arrow),
      trailing: _dayData.date.isSameDayAs(DateTime.now()) ? const Icon(Icons.today) : null,
      minLeadingWidth: 8,
      onTap: () {
        if (!_viewMode) {
          Navigator.of(context).pushNamed(
            GymModeScreen.routeName,
            arguments: GymModeArguments(_routineId, _dayData.day!.id!, _dayData.iteration),
          );
        }
      },
    );
  }
}
