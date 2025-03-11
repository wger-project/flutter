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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';
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
  late Future<Routine> _dataFuture;
  int? selectedDayId;

  @override
  void initState() {
    super.initState();
    _dataFuture = context.read<RoutinesProvider>().fetchAndSetRoutineFull(widget._routine.id!);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    final provider = context.read<RoutinesProvider>();

    Day? selectedDay;
    if (selectedDayId != null) {
      selectedDay = widget._routine.days.firstWhereOrNull((day) => day.id == selectedDayId);
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            RoutineForm(widget._routine, useListView: false),
            Container(height: 10),
            Text(
              i18n.routineDays,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ReorderableDaysList(
              routineId: widget._routine.id!,
              days: widget._routine.days.where((day) => day.id != null).toList(),
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
            const SizedBox(height: 25),
            Text(
              i18n.resultingRoutine,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              key: const ValueKey('refresh-routine'),
              onPressed: () {
                setState(() {
                  _dataFuture = provider.fetchAndSetRoutineFull(widget._routine.id!);
                });
              },
              icon: const Icon(Icons.refresh),
            ),
            const Divider(),
            FutureBuilder<Routine>(
              future: _dataFuture,
              builder: (BuildContext context, AsyncSnapshot<Routine> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return RoutineDetail(snapshot.data!, viewMode: true);
                }
                return const Text('No data available');
              },
            ),
            // RoutineDetail(widget._routine),
          ],
        ),
      ),
    );
  }
}
