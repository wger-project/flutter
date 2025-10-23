import 'package:drift/drift.dart';
import 'package:powersync/powersync.dart' show uuid;
import 'package:wger/models/body_weight/weight_entry.dart';

@UseRowClass(WeightEntry)
class WeightEntryTable extends Table {
  @override
  String get tableName => 'weight_weightentry';

  TextColumn get id => text().clientDefault(() => uuid.v4())();
  RealColumn get weight => real()();
  DateTimeColumn get date => dateTime().nullable()();
}
