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
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/slot_entry.dart';
import 'package:wger/widgets/exercises/images.dart';
import 'package:wger/widgets/routines/forms/reps.dart';
import 'package:wger/widgets/routines/forms/reps_unit.dart';
import 'package:wger/widgets/routines/forms/rir.dart';
import 'package:wger/widgets/routines/forms/weight.dart';
import 'package:wger/widgets/routines/forms/weight_unit.dart';

class ExerciseSetting extends StatelessWidget {
  final Exercise _exerciseBase;
  late final int _numberOfSets;
  final bool _detailed;
  final Function removeExercise;
  final List<SlotEntry> _settings;

  ExerciseSetting(
    this._exerciseBase,
    this._settings,
    this._detailed,
    double sliderValue,
    this.removeExercise,
  ) {
    _numberOfSets = sliderValue.round();
  }

  Widget getRows(BuildContext context) {
    final List<Widget> out = [];
    for (var i = 0; i < _numberOfSets; i++) {
      final setting = _settings[i];

      if (_detailed) {
        out.add(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).exerciseNr(i + 1),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 2,
                    child: RepsInputWidget(setting, _detailed),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    flex: 3,
                    child: RepetitionUnitInputWidget(setting),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 2,
                    child: WeightInputWidget(setting, _detailed),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    flex: 3,
                    child: WeightUnitInputWidget(setting, key: Key(i.toString())),
                  ),
                ],
              ),
              Flexible(flex: 2, child: RiRInputWidget( setting.exerciseId, onChanged: (String value) {  }, )),
              const SizedBox(height: 15),
            ],
          ),
        );
      } else {
        out.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AppLocalizations.of(context).exerciseNr(i + 1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Flexible(child: RepsInputWidget(setting, _detailed)),
              const SizedBox(width: 4),
              Flexible(child: WeightInputWidget(setting, _detailed)),
            ],
          ),
        );
      }
    }
    return Column(children: out);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            ListTile(
              title: Text(
                _exerciseBase.getExercise(Localizations.localeOf(context).languageCode).name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(_exerciseBase.category!.name),
              contentPadding: EdgeInsets.zero,
              leading: ExerciseImageWidget(image: _exerciseBase.getMainImage),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  removeExercise(_exerciseBase);
                },
              ),
            ),
            const Divider(),

            //ExerciseImage(imageUrl: _exercise.images.first.url),
            if (!_detailed)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(AppLocalizations.of(context).repetitions),
                  Text(AppLocalizations.of(context).weight),
                ],
              ),
            getRows(context),
          ],
        ),
      ),
    );
  }
}
