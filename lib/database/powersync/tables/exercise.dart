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
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/exercises/video.dart';

import 'language.dart';

@UseRowClass(Exercise)
class ExerciseTable extends Table {
  @override
  String get tableName => 'exercises_exercise';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get variationId => integer().nullable().named('variation_id')();
  IntColumn get categoryId =>
      integer().named('category_id').references(ExerciseCategoryTable, #id)();
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastUpdate => dateTime().named('last_update')();
}

@UseRowClass(Translation)
class ExerciseTranslationTable extends Table {
  @override
  String get tableName => 'exercises_translation';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get exerciseId => integer().named('exercise_id').references(ExerciseTable, #id)();
  IntColumn get languageId => integer().named('language_id').references(LanguageTable, #id)();
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

class ExerciseEquipmentM2N extends Table {
  @override
  String get tableName => 'exercises_exercise_equipment';

  IntColumn get id => integer()();
  IntColumn get exerciseId => integer().named('exercise_id').references(ExerciseTable, #id)();
  IntColumn get equipmentId => integer().named('equipment_id').references(EquipmentTable, #id)();
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
  IntColumn get exerciseId => integer().named('exercise_id').references(ExerciseTable, #id)();
  IntColumn get muscleId => integer().named('muscle_id').references(MuscleTable, #id)();
}

class ExerciseSecondaryMuscleM2N extends Table {
  @override
  String get tableName => 'exercises_exercise_muscles_secondary';

  IntColumn get id => integer()();
  IntColumn get exerciseId => integer().named('exercise_id').references(ExerciseTable, #id)();
  IntColumn get muscleId => integer().named('muscle_id').references(MuscleTable, #id)();
}

@UseRowClass(ExerciseImage)
class ExerciseImageTable extends Table {
  @override
  String get tableName => 'exercises_exerciseimage';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get exerciseId => integer().named('exercise_id').references(ExerciseTable, #id)();
  TextColumn get url => text()();
  BoolColumn get isMain => boolean().named('is_main')();
}

@UseRowClass(Video)
class ExerciseVideoTable extends Table {
  @override
  String get tableName => 'exercises_exercisevideo';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get exerciseId => integer().named('exercise_id').references(ExerciseTable, #id)();
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
