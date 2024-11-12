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
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/widgets/routines/forms/day.dart';
import 'package:wger/widgets/routines/forms/routine.dart';

class RoutineEdit extends StatelessWidget {
  final Routine _routine;

  const RoutineEdit(this._routine);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView(
        children: [
          RoutineForm(_routine),
          Container(height: 10),
          ReorderableDaysList(_routine.days, _routine.id!),
        ],
      ),
    );
  }
}
