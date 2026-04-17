/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'package:powersync/powersync.dart' as ps;
import 'package:wger/database/converters/int_to_string_converter.dart';
import 'package:wger/database/converters/time_of_day_converter.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/models/workouts/weight_unit.dart';

@UseRowClass(Log)
class WorkoutLogTable extends Table {
  @override
  String get tableName => 'manager_workoutlog';

  TextColumn get id => text().clientDefault(() => ps.uuid.v7())();
  IntColumn get exerciseId => integer().named('exercise_id')();
  IntColumn get routineId => integer().named('routine_id')();
  IntColumn get sessionId => integer().named('session_id').nullable()();
  IntColumn get iteration => integer().nullable()();
  IntColumn get slotEntryId => integer().named('slot_entry_id').nullable()();

  RealColumn get rir => real().nullable()();
  RealColumn get rirTarget => real().named('rir_target').nullable()();

  RealColumn get repetitions => real().nullable()();
  RealColumn get repetitionsTarget => real().nullable().named('repetitions_target')();
  IntColumn get repetitionsUnitId => integer().named('repetitions_unit_id').nullable()();

  RealColumn get weight => real().nullable()();
  RealColumn get weightTarget => real().nullable().named('weight_target')();
  IntColumn get weightUnitId => integer().nullable().named('weight_unit_id').nullable()();

  DateTimeColumn get date => dateTime()();
}

const PowersyncWorkoutLogTable = ps.Table(
  'manager_workoutlog',
  [
    ps.Column.integer('exercise_id'),
    ps.Column.integer('routine_id'),
    ps.Column.integer('session_id'),
    ps.Column.integer('iteration'),
    ps.Column.integer('slot_entry_id'),
    ps.Column.real('rir'),
    ps.Column.real('rir_target'),
    ps.Column.real('repetitions'),
    ps.Column.real('repetitions_target'),
    ps.Column.integer('repetitions_unit_id'),
    ps.Column.real('weight'),
    ps.Column.real('weight_target'),
    ps.Column.integer('weight_unit_id'),
    ps.Column.text('date'),
  ],
  indexes: [
    ps.Index('exercise_idx', [ps.IndexedColumn('exercise_id')]),
    ps.Index('slot_entry_idx', [ps.IndexedColumn('slot_entry_id')]),
    ps.Index('routine_idx', [ps.IndexedColumn('routine_id')]),
    ps.Index('session_idx', [ps.IndexedColumn('session_id')]),
    ps.Index('repetitions_unit_idx', [ps.IndexedColumn('repetitions_unit_id')]),
    ps.Index('weight_unit_idx', [ps.IndexedColumn('weight_unit_id')]),
  ],
);

@UseRowClass(WorkoutSession)
class WorkoutSessionTable extends Table {
  @override
  String get tableName => 'manager_workoutsession';

  TextColumn get id => text().clientDefault(() => ps.uuid.v7())();
  IntColumn get routineId => integer().named('routine_id').nullable()();
  IntColumn get dayId => integer().named('day_id').nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get impression => text().map(const IntToStringConverter())();
  TextColumn get timeStart =>
      text().named('time_start').nullable().map(const TimeOfDayConverter())();
  TextColumn get timeEnd => text().named('time_end').nullable().map(const TimeOfDayConverter())();
}

const PowersyncWorkoutSessionTable = ps.Table(
  'manager_workoutsession',
  [
    ps.Column.integer('routine_id'),
    ps.Column.integer('day_id'),
    ps.Column.text('date'),
    ps.Column.text('notes'),
    ps.Column.text('impression'),
    ps.Column.text('time_start'),
    ps.Column.text('time_end'),
  ],
  indexes: [
    ps.Index('routine_idx', [ps.IndexedColumn('routine_id')]),
    ps.Index('day_idx', [ps.IndexedColumn('day_id')]),
  ],
);

@UseRowClass(RepetitionUnit)
class RoutineRepetitionUnitTable extends Table {
  @override
  String get tableName => 'core_repetitionunit';

  IntColumn get id => integer()();
  TextColumn get name => text()();
}

const PowersyncRoutineRepetitionUnitTable = ps.Table(
  'core_repetitionunit',
  [
    ps.Column.text('name'),
  ],
);

@UseRowClass(WeightUnit)
class RoutineWeightUnitTable extends Table {
  @override
  String get tableName => 'core_weightunit';

  IntColumn get id => integer()();
  TextColumn get name => text()();
}

const PowersyncRoutineWeightUnitTable = ps.Table(
  'core_weightunit',
  [
    ps.Column.text('name'),
  ],
);
