import 'package:drift/drift.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/measurements/measurement_entry.dart';

@UseRowClass(MeasurementCategory)
class MeasurementCategoryTable extends Table {
  @override
  String get tableName => 'measurements_category';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get unit => text()();
}

@UseRowClass(MeasurementEntry)
class MeasurementEntryTable extends Table {
  @override
  String get tableName => 'measurements_measurement';

  IntColumn get id => integer()();
  DateTimeColumn get date => dateTime()();
  RealColumn get value => real()();
  TextColumn get notes => text()();
}
