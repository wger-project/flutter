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
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/widgets/routines/forms/day.dart';
import 'package:wger/widgets/routines/forms/routine.dart';
import 'package:wger/widgets/routines/routine_detail.dart';

class RoutineEdit extends StatefulWidget {
  final Routine _routine;

  const RoutineEdit(this._routine);

  @override
  State<RoutineEdit> createState() => _RoutineEditState();
}

class _RoutineEditState extends State<RoutineEdit> {
  int? selectedDayId;

  @override
  Widget build(BuildContext context) {
    Day? selectedDay;
    if (selectedDayId != null) {
      selectedDay = widget._routine.days.firstWhere((day) => day.id == selectedDayId);
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            RoutineForm(widget._routine),
            Container(height: 10),
            ReorderableDaysList(
              routineId: widget._routine.id!,
              days: widget._routine.days,
              selectedDayId: selectedDayId,
              onDaySelected: (id) {
                setState(() {
                  if (selectedDayId == id) {
                    selectedDayId = null;
                  } else {
                    selectedDayId = id;
                  }
                });
              },
            ),
            if (selectedDay != null)
              DayFormWidget(
                key: ValueKey(selectedDayId),
                day: selectedDay,
                routineId: widget._routine.id!,
              ),
            const SizedBox(height: 50),
            Text(
              'Resulting routine',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            RoutineDetail(widget._routine),
          ],
        ),
      ),
    );
  }
}
