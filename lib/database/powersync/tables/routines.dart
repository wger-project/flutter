import 'package:drift/drift.dart';
import 'package:powersync/powersync.dart' show uuid;

// @UseRowClass(Log)
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
