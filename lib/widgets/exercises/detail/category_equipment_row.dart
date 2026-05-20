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
import 'package:wger/helpers/i18n.dart';
import 'package:wger/models/exercises/exercise.dart';

class CategoryEquipmentRow extends StatelessWidget {
  final Exercise exercise;

  const CategoryEquipmentRow({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Chip(
            label: Text(getServerStringTranslation(exercise.category.name, context)),
            padding: EdgeInsets.zero,
            backgroundColor: theme.splashColor,
          ),
        ),
        ...exercise.equipment.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Chip(
              label: Text(getServerStringTranslation(e.name, context)),
              padding: EdgeInsets.zero,
              backgroundColor: theme.splashColor,
            ),
          ),
        ),
      ],
    );
  }
}
