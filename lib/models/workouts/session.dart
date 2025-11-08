/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';

const IMPRESSION_MAP = {1: 'bad', 2: 'neutral', 3: 'good'};

class WorkoutSession {
  String? id;
  late int? routineId;
  int? dayId;
  late DateTime date;
  late int impression;
  late String? notes;
  late TimeOfDay? timeStart;
  late TimeOfDay? timeEnd;

  List<Log> logs = [];

  WorkoutSession({
    this.id,
    this.dayId,
    required this.routineId,
    this.impression = 2,
    this.notes = '',
    this.timeStart,
    this.timeEnd,
    this.logs = const [],
    DateTime? date,
  }) {
    this.date = date ?? DateTime.now();
  }

  WorkoutSessionTableCompanion toCompanion({bool includeId = false}) {
    return WorkoutSessionTableCompanion(
      id: includeId && id != null ? drift.Value(id!) : const drift.Value.absent(),
      routineId: routineId != null ? drift.Value(routineId) : const drift.Value.absent(),
      dayId: dayId != null ? drift.Value(dayId) : const drift.Value.absent(),
      date: drift.Value(date.toUtc()),
      notes: drift.Value(notes),
      impression: drift.Value(impression),
      timeStart: timeStart != null ? drift.Value(timeStart) : const drift.Value.absent(),
      timeEnd: timeEnd != null ? drift.Value(timeEnd) : const drift.Value.absent(),
    );
  }

  List<Exercise> get exercises {
    final Set<Exercise> exerciseSet = {};
    for (final log in logs) {
      exerciseSet.add(log.exerciseObj);
    }
    return exerciseSet.toList();
  }

  String get impressionAsString {
    return IMPRESSION_MAP[impression]!;
  }
}
