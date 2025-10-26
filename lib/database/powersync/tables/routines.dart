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

import 'package:drift/drift.dart';
import 'package:powersync/powersync.dart' show uuid;
import 'package:wger/database/converters/int_to_string_converter.dart';
import 'package:wger/database/converters/time_of_day_converter.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/session.dart';

@UseRowClass(Log)
class WorkoutLogTable extends Table {
  @override
  String get tableName => 'manager_workoutlog';

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  IntColumn get exerciseId => integer().named('exercise_id')();
  IntColumn get routineId => integer().named('routine_id')();
  IntColumn get sessionId => integer().named('session_id').nullable()();
  IntColumn get iteration => integer().nullable()();
  IntColumn get slotEntryId => integer().named('slot_entry_id').nullable()();

  RealColumn get rir => real().nullable()();
  RealColumn get rirTarget => real().named('rir_target').nullable()();

  RealColumn get repetitions => real()();
  RealColumn get repetitionsTarget => real().named('repetitions_target')();
  IntColumn get repetitionsUnitId => integer().named('repetitions_unit_id').nullable()();

  RealColumn get weight => real()();
  RealColumn get weightTarget => real().named('weight_target')();
  IntColumn get weightUnitId => integer().named('weight_unit_id').nullable()();

  DateTimeColumn get date => dateTime()();
}

@UseRowClass(WorkoutSession)
class WorkoutSessionTable extends Table {
  @override
  String get tableName => 'manager_workoutsession';

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  IntColumn get routineId => integer().named('routine_id').nullable()();
  IntColumn get dayId => integer().named('day_id').nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text()();
  TextColumn get impression => text().map(const IntToStringConverter())();
  TextColumn get timeStart =>
      text().named('time_start').nullable().map(const TimeOfDayConverter())();
  TextColumn get timeEnd => text().named('time_end').nullable().map(const TimeOfDayConverter())();
}
