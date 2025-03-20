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
import 'package:flutter_html/flutter_html.dart';
import 'package:wger/helpers/i18n.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/widgets/exercises/images.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';

class ExerciseOverview extends StatelessWidget {
  final PageController _controller;
  final Exercise _exerciseBase;
  final double _ratioCompleted;
  final Map<Exercise, int> _exercisePages;

  const ExerciseOverview(
    this._controller,
    this._exerciseBase,
    this._ratioCompleted,
    this._exercisePages,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavigationHeader(
          _exerciseBase.getTranslation(Localizations.localeOf(context).languageCode).name,
          _controller,
          exercisePages: _exercisePages,
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              Text(
                getTranslation(_exerciseBase.category!.name, context),
                semanticsLabel: getTranslation(_exerciseBase.category!.name, context),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              ..._exerciseBase.equipment.map((e) => Text(
                    getTranslation(e.name, context),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  )),
              if (_exerciseBase.images.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._exerciseBase.images.map((e) => ExerciseImageWidget(image: e)),
                    ],
                  ),
                ),
              Html(
                data: _exerciseBase
                    .getTranslation(Localizations.localeOf(context).languageCode)
                    .description,
              ),
            ],
          ),
        ),
        NavigationFooter(_controller, _ratioCompleted),
      ],
    );
  }
}
