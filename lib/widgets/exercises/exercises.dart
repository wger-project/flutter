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
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wger/models/exercises/exercise.dart';

class ExerciseDetail extends StatelessWidget {
  final Exercise _exercise;

  ExerciseDetail(this._exercise);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category
          Text(
            AppLocalizations.of(context).category,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(_exercise.categoryObj.name),
          SizedBox(height: 8),

          // Equipment
          Text(
            AppLocalizations.of(context).equipment,
            style: Theme.of(context).textTheme.headline6,
          ),
          if (_exercise.equipment.length > 0)
            Text(_exercise.equipment.map((e) => e.name).toList().join('\n')),
          if (_exercise.equipment.length == 0) Text('-/-'),
          SizedBox(height: 8),

          // Muscles
          Text(
            AppLocalizations.of(context).muscles,
            style: Theme.of(context).textTheme.headline6,
          ),
          if (_exercise.muscles.length > 0)
            Text(_exercise.muscles.map((e) => e.name).toList().join('\n')),
          if (_exercise.muscles.length == 0) Text('-/-'),
          SizedBox(height: 8),

          // Muscles secondary
          Text(
            AppLocalizations.of(context).musclesSecondary,
            style: Theme.of(context).textTheme.headline6,
          ),
          if (_exercise.musclesSecondary.length > 0)
            Text(_exercise.musclesSecondary
                .map((e) => e.name)
                .toList()
                .join('\n')),
          if (_exercise.musclesSecondary.length == 0) Text('-/-'),
          SizedBox(height: 8),

          // Description
          Text(
            AppLocalizations.of(context).description,
            style: Theme.of(context).textTheme.headline6,
          ),
          Html(data: _exercise.description),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
