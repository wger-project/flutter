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
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart' show uuid;
import 'package:wger/database/converters/int_to_string_converter.dart';
import 'package:wger/database/converters/time_of_day_converter.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/exercises/video.dart';
import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/session.dart';

import 'powersync.dart';
import 'tables/exercise.dart';
import 'tables/language.dart';
import 'tables/measurements.dart';
import 'tables/routines.dart';
import 'tables/weight.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    // Core
    LanguageTable,

    // Exercises
    ExerciseTable,
    ExerciseTranslationTable,
    MuscleTable,
    ExerciseMuscleM2N,
    ExerciseSecondaryMuscleM2N,
    EquipmentTable,
    ExerciseEquipmentM2N,
    ExerciseCategoryTable,
    ExerciseImageTable,
    ExerciseVideoTable,

    // User data
    WeightEntryTable,
    MeasurementCategoryTable,
    WorkoutLogTable,
    WorkoutSessionTable,
  ],
  //include: {'queries.drift'},
)
class DriftPowersyncDatabase extends _$DriftPowersyncDatabase {
  DriftPowersyncDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        // We don't have to call createAll(), PowerSync instantiates the schema
        // for us. We can use the opportunity to create fts5 indexes though.
      },
      onUpgrade: (m, from, to) async {
        if (from == 1) {
          // await createFts5Tables(
          //   db: this,
          //   tableName: 'todos',
          //   columns: ['description', 'list_id'],
          // );
        }
      },
    );
  }
}

final driftPowerSyncDatabase = Provider((ref) {
  return DriftPowersyncDatabase(
    DatabaseConnection.delayed(
      Future(() async {
        final database = await ref.read(powerSyncInstanceProvider.future);
        return SqliteAsyncDriftConnection(database);
      }),
    ),
  );
});
