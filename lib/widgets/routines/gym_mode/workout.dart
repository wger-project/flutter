/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2025 wger Team
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
import 'package:logging/logging.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/day_data.dart';
import 'package:wger/models/workouts/slot_data.dart';

class SlotDataRegular extends StatelessWidget {
  final _logger = Logger('SlotDataRegular');

  final SlotData _slotData;

  SlotDataRegular(this._slotData) : assert(!_slotData.isSuperset);

  @override
  Widget build(BuildContext context) {
    if (_slotData.setConfigs.isEmpty) {
      _logger.warning('Encountered an empty _slotData.setConfigs');
      return const SizedBox.shrink();
    }

    final exercise = _slotData.setConfigs.first.exercise;
    return ListTile(
      title: Text(exercise.getTranslation(Localizations.localeOf(context).languageCode).name),
      subtitle: Text(_slotData.setConfigs.map((e) => e.textReprWithType).join('\n')),
    );
  }
}

class SlotDataSuperset extends StatelessWidget {
  final SlotData _slotData;

  SlotDataSuperset(this._slotData) : assert(_slotData.isSuperset);

  String _indexToLetters(int index) {
    final sb = StringBuffer();
    var i = index;
    while (i >= 0) {
      final rem = i % 26;
      sb.writeCharCode('A'.codeUnitAt(0) + rem);
      i = (i ~/ 26) - 1;
    }
    return sb.toString().split('').reversed.join();
  }

  Map<int, String> _idsToLetters(List<int> ids) {
    final Map<int, String> result = {};
    final seen = <int>{};
    var counter = 0;
    for (final id in ids) {
      if (seen.add(id)) {
        result[id] = _indexToLetters(counter++);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Maps exercise IDs to letters (A, B, C, ...) so they can be referenced in the set configs
    final exerciseLetterMap = _idsToLetters(_slotData.exerciseIds);
    final exercises = _slotData.setConfigs.map((e) => e.exercise).toSet();

    final exerciseText = exercises
        .map(
          (exercise) =>
              '${exerciseLetterMap[exercise.id!]}: ${exercise.getTranslation(Localizations.localeOf(context).languageCode).name}',
        )
        .join('\n');

    final repText = _slotData.setConfigs
        .map((e) {
          final letter = exerciseLetterMap[e.exercise.id]!;
          return '$letter: ${e.textReprWithType}';
        })
        .join('\n');

    return ListTile(
      title: Text(AppLocalizations.of(context).superset),
      subtitle: Text(
        '$exerciseText \n\n$repText',
      ),
    );
  }
}

class WorkoutProgression extends StatelessWidget {
  final DayData _dayData;

  const WorkoutProgression(this._dayData);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ..._dayData.slots.map(
            (slotData) =>
                slotData.isSuperset ? SlotDataSuperset(slotData) : SlotDataRegular(slotData),
          ),
        ],
      ),
    );
  }
}
