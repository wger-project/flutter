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
import 'package:wger/database/converters/exercise_image_style_converter.dart';
import 'package:wger/models/exercises/alias.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/video.dart';

import 'language.dart';

@DataClassName('ExerciseRow')
class ExerciseTable extends Table {
  @override
  String get tableName => 'exercises_exercise';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  TextColumn get variationGroup => text().nullable().named('variation_group')();
  IntColumn get categoryId =>
      integer().named('category_id').references(ExerciseCategoryTable, #id)();
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastUpdate => dateTime().named('last_update')();
}

/// Raw table: native SQLite storage instead of the default JSON-view layer.
/// Exercises are server-owned (read-only on the client) and dominate the
/// per-row JSON decode cost, so bypassing the view layer is the lever with
/// the biggest impact. The actual `CREATE TABLE` + `CREATE INDEX` statements
/// live next to `PowerSyncDatabase.initialize()` in `database/powersync/powersync.dart`.
const PowersyncExerciseTable = ps.RawTable.inferred(
  name: 'exercises_exercise',
  schema: ps.RawTableSchema(),
);

@DataClassName('ExerciseTranslationRow')
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

/// See [PowersyncExerciseTable]: translations live in the same raw-table
/// store for the same reason (2k+ rows, wide text columns).
const PowersyncTranslationTable = ps.RawTable.inferred(
  name: 'exercises_translation',
  schema: ps.RawTableSchema(),
);

@UseRowClass(Alias)
class ExerciseAliasTable extends Table {
  @override
  String get tableName => 'exercises_alias';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get translationId =>
      integer().named('translation_id').references(ExerciseTranslationTable, #id)();
  TextColumn get alias => text()();
}

const PowersyncExerciseAliasTable = ps.Table(
  'exercises_alias',
  [
    ps.Column.text('uuid'),
    ps.Column.integer('translation_id'),
    ps.Column.text('alias'),
  ],
  indexes: [
    ps.Index('translation', [ps.IndexedColumn('translation_id')]),
  ],
);

@UseRowClass(Comment)
class ExerciseCommentTable extends Table {
  @override
  String get tableName => 'exercises_exercisecomment';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get translationId =>
      integer().named('translation_id').references(ExerciseTranslationTable, #id)();
  TextColumn get comment => text()();
}

const PowersyncExerciseCommentTable = ps.Table(
  'exercises_exercisecomment',
  [
    ps.Column.text('uuid'),
    ps.Column.integer('translation_id'),
    ps.Column.text('comment'),
  ],
  indexes: [
    ps.Index('translation', [ps.IndexedColumn('translation_id')]),
  ],
);

@UseRowClass(ExerciseCategory)
class ExerciseCategoryTable extends Table {
  @override
  String get tableName => 'exercises_exercisecategory';

  IntColumn get id => integer()();
  TextColumn get name => text()();
}

const PowersyncExerciseCategoryTable = ps.Table(
  'exercises_exercisecategory',
  [
    ps.Column.text('name'),
  ],
);

@UseRowClass(Equipment)
class EquipmentTable extends Table {
  @override
  String get tableName => 'exercises_equipment';

  IntColumn get id => integer()();
  TextColumn get name => text()();
}

const PowersyncEquipmentTable = ps.Table(
  'exercises_equipment',
  [
    ps.Column.text('name'),
  ],
);

class ExerciseEquipmentM2N extends Table {
  @override
  String get tableName => 'exercises_exercise_equipment';

  IntColumn get id => integer()();
  IntColumn get exerciseId => integer().named('exercise_id').references(ExerciseTable, #id)();
  IntColumn get equipmentId => integer().named('equipment_id').references(EquipmentTable, #id)();
}

const PowersyncExerciseEquipmentM2N = ps.Table(
  'exercises_exercise_equipment',
  [
    ps.Column.text('exercise_id'),
    ps.Column.text('equipment_id'),
  ],
  indexes: [
    ps.Index('equipment', [ps.IndexedColumn('equipment_id')]),
    ps.Index('exercise', [ps.IndexedColumn('exercise_id')]),
  ],
);

@UseRowClass(Muscle)
class MuscleTable extends Table {
  @override
  String get tableName => 'exercises_muscle';

  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get nameEn => text().named('name_en')();
  BoolColumn get isFront => boolean().named('is_front')();
}

const PowersyncMuscleTable = ps.Table(
  'exercises_muscle',
  [
    ps.Column.text('name'),
    ps.Column.text('name_en'),
    ps.Column.text('is_front'),
  ],
);

class ExerciseMuscleM2N extends Table {
  @override
  String get tableName => 'exercises_exercise_muscles';

  IntColumn get id => integer()();
  IntColumn get exerciseId => integer().named('exercise_id').references(ExerciseTable, #id)();
  IntColumn get muscleId => integer().named('muscle_id').references(MuscleTable, #id)();
}

const PowersyncExerciseMuscleM2N = ps.Table(
  'exercises_exercise_muscles',
  [
    ps.Column.integer('exercise_id'),
    ps.Column.integer('muscle_id'),
  ],
  indexes: [
    ps.Index('muscle', [ps.IndexedColumn('muscle_id')]),
    ps.Index('exercise', [ps.IndexedColumn('exercise_id')]),
  ],
);

class ExerciseSecondaryMuscleM2N extends Table {
  @override
  String get tableName => 'exercises_exercise_muscles_secondary';

  IntColumn get id => integer()();
  IntColumn get exerciseId => integer().named('exercise_id').references(ExerciseTable, #id)();
  IntColumn get muscleId => integer().named('muscle_id').references(MuscleTable, #id)();
}

const PowersyncExerciseSecondaryMuscleM2N = ps.Table(
  'exercises_exercise_muscles_secondary',
  [
    ps.Column.integer('exercise_id'),
    ps.Column.integer('muscle_id'),
  ],
  indexes: [
    ps.Index('muscle', [ps.IndexedColumn('muscle_id')]),
    ps.Index('exercise', [ps.IndexedColumn('exercise_id')]),
  ],
);

@UseRowClass(ExerciseImage)
class ExerciseImageTable extends Table {
  @override
  String get tableName => 'exercises_exerciseimage';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get exerciseId => integer().named('exercise_id').references(ExerciseTable, #id)();
  // Relative path under MEDIA_ROOT (Django's ImageField stores this)
  TextColumn get image => text()();
  BoolColumn get isMain => boolean().named('is_main')();
  BoolColumn get isAiGenerated => boolean().named('is_ai_generated')();
  TextColumn get style => text().map(const ExerciseImageStyleConverter())();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastUpdate => dateTime().named('last_update')();

  // License (TASL — Title / Author / Source / License). license_author may be
  // null on the server (TextField with null=True); the others are not-null
  // strings (possibly empty) on the server.
  IntColumn get licenseId => integer().named('license_id')();
  TextColumn get licenseTitle => text().named('license_title')();
  TextColumn get licenseObjectUrl => text().named('license_object_url')();
  TextColumn get licenseAuthor => text().named('license_author').nullable()();
  TextColumn get licenseAuthorUrl => text().named('license_author_url')();
  TextColumn get licenseDerivativeSourceUrl => text().named('license_derivative_source_url')();
}

const PowersyncExerciseImageTable = ps.Table(
  'exercises_exerciseimage',
  [
    ps.Column.text('uuid'),
    ps.Column.integer('exercise_id'),
    ps.Column.text('image'),
    ps.Column.integer('is_main'),
    ps.Column.integer('is_ai_generated'),
    ps.Column.text('style'),
    ps.Column.integer('width'),
    ps.Column.integer('height'),
    ps.Column.text('created'),
    ps.Column.text('last_update'),
    ps.Column.integer('license_id'),
    ps.Column.text('license_title'),
    ps.Column.text('license_object_url'),
    ps.Column.text('license_author'),
    ps.Column.text('license_author_url'),
    ps.Column.text('license_derivative_source_url'),
  ],
  indexes: [
    ps.Index('exercise', [ps.IndexedColumn('exercise_id')]),
    ps.Index('license', [ps.IndexedColumn('license_id')]),
  ],
);

@UseRowClass(Video)
class ExerciseVideoTable extends Table {
  @override
  String get tableName => 'exercises_exercisevideo';

  IntColumn get id => integer()();
  TextColumn get uuid => text()();
  IntColumn get exerciseId => integer().named('exercise_id').references(ExerciseTable, #id)();
  BoolColumn get isMain => boolean().named('is_main')();
  TextColumn get url => text()();
  IntColumn get size => integer()();
  IntColumn get duration => integer()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  TextColumn get codec => text()();
  TextColumn get codecLong => text().named('codec_long')();
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastUpdate => dateTime().named('last_update')();

  // License (TASL — Title / Author / Source / License). license_author may be
  // null on the server (TextField with null=True); the others are not-null
  // strings (possibly empty) on the server.
  IntColumn get licenseId => integer().named('license_id')();
  TextColumn get licenseTitle => text().named('license_title')();
  TextColumn get licenseObjectUrl => text().named('license_object_url')();
  TextColumn get licenseAuthor => text().named('license_author').nullable()();
  TextColumn get licenseAuthorUrl => text().named('license_author_url')();
  TextColumn get licenseDerivativeSourceUrl => text().named('license_derivative_source_url')();
}

const PowersyncExerciseVideoTable = ps.Table(
  'exercises_exercisevideo',
  [
    ps.Column.text('uuid'),
    ps.Column.integer('exercise_id'),
    ps.Column.integer('is_main'),
    ps.Column.text('url'),
    ps.Column.integer('size'),
    ps.Column.integer('duration'),
    ps.Column.integer('width'),
    ps.Column.integer('height'),
    ps.Column.text('codec'),
    ps.Column.text('codec_long'),
    ps.Column.text('created'),
    ps.Column.text('last_update'),
    ps.Column.integer('license_id'),
    ps.Column.text('license_title'),
    ps.Column.text('license_object_url'),
    ps.Column.text('license_author'),
    ps.Column.text('license_author_url'),
    ps.Column.text('license_derivative_source_url'),
  ],
  indexes: [
    ps.Index('exercise', [ps.IndexedColumn('exercise_id')]),
    ps.Index('license', [ps.IndexedColumn('license_id')]),
  ],
);
