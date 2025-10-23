import 'package:drift/drift.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/exercises/video.dart';

@UseRowClass(Exercise)
class ExerciseTable extends Table {
  @override
  String get tableName => 'exercises_exercise';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get variationId => integer().nullable().named('variation_id')();
  IntColumn get categoryId => integer().named('category_id')();
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastUpdate => dateTime().named('last_update')();
}

@UseRowClass(Translation)
class ExerciseTranslationTable extends Table {
  @override
  String get tableName => 'exercises_translation';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get exerciseId => integer().named('exercise_id')();
  IntColumn get languageId => integer().named('language_id')();
  TextColumn get name => text()();
  TextColumn get description => text()();
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastUpdate => dateTime().named('last_update')();
}

@UseRowClass(ExerciseCategory)
class ExerciseCategoryTable extends Table {
  @override
  String get tableName => 'exercises_exercisecategory';

  IntColumn get id => integer()();
  TextColumn get name => text()();
}

@UseRowClass(Equipment)
class EquipmentTable extends Table {
  @override
  String get tableName => 'exercises_equipment';

  IntColumn get id => integer()();
  TextColumn get name => text()();
}

@UseRowClass(Muscle)
class MuscleTable extends Table {
  @override
  String get tableName => 'exercises_muscle';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get nameEn => text().named('name_en')();
  BoolColumn get isFront => boolean().named('is_front')();
}

class ExerciseMuscleM2N extends Table {
  @override
  String get tableName => 'exercises_exercise_muscles';

  IntColumn get id => integer()();
  IntColumn get exerciseId => integer().named('exercise_id')();
  IntColumn get muscleId => integer().named('muscle_id')();
}

class ExerciseSecondaryMuscleM2N extends Table {
  @override
  String get tableName => 'exercises_exercise_muscles_secondary';

  IntColumn get id => integer()();
  IntColumn get exerciseId => integer().named('exercise_id')();
  IntColumn get muscleId => integer().named('muscle_id')();
}

@UseRowClass(ExerciseImage)
class ExerciseImageTable extends Table {
  @override
  String get tableName => 'exercises_exerciseimage';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get exerciseId => integer().named('exercise_id')();
  TextColumn get url => text()();
  BoolColumn get isMain => boolean().named('is_main')();
}

@UseRowClass(Video)
class ExerciseVideoTable extends Table {
  @override
  String get tableName => 'exercises_exercisevideo';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get exerciseId => integer().named('exercise_id')();
  TextColumn get url => text()();
  IntColumn get size => integer()();
  IntColumn get duration => integer()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  TextColumn get codec => text()();
  TextColumn get codecLong => text().named('codec_long')();
  IntColumn get licenseId => integer().named('license_id')();
  TextColumn get licenseAuthor => text().named('license_author')();
}
