import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wger/database/exercise_DB/type_converters.dart';
import 'package:wger/models/exercises/base.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/variation.dart';

part 'exercise_database.g.dart';

@DataClassName('ExerciseTable')
class ExerciseTableItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exercisebase => text().map(const ExerciseBaseConverter()).nullable()();
  TextColumn get muscle => text().map(const MuscleConverter()).nullable()();
  TextColumn get category => text().map(const ExerciseCategoryConverter()).nullable()();
  TextColumn get variation => text().map(const VariationConverter()).nullable()();
  TextColumn get language => text().map(const LanguageConverter()).nullable()();
  TextColumn get equipment => text().map(const EquipmentConverter()).nullable()();
  DateTimeColumn get expiresIn => dateTime().nullable()();
}

@DriftDatabase(tables: [ExerciseTableItems])
class ExerciseDatabase extends _$ExerciseDatabase {
  ExerciseDatabase() : super(_openConnection());

  @override
  // TODO: implement schemaVersion
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
