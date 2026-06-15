/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/widgets/exercises/exercises.dart';

class MusclesSection extends StatelessWidget {
  final Exercise exercise;

  const MusclesSection({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).muscles,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: MuscleWidget(
                  muscles: exercise.muscles,
                  musclesSecondary: exercise.musclesSecondary,
                  isFront: true,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: MuscleWidget(
                  muscles: exercise.muscles,
                  musclesSecondary: exercise.musclesSecondary,
                  isFront: false,
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MuscleColorHelper(main: true),
            ...exercise.muscles.map((e) => Text(e.nameTranslated(context))),
          ],
        ),
        const SizedBox(height: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MuscleColorHelper(main: false),
            ...exercise.musclesSecondary.map((e) => Text(e.name)),
          ],
        ),
        const SizedBox(height: 9),
      ],
    );
  }
}
