import 'package:drift/drift.dart';
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart' show uuid;
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
    ExerciseCategoryTable,
    ExerciseImageTable,
    ExerciseVideoTable,

    // User data
    WeightEntryTable,
    MeasurementCategoryTable,
    WorkoutLogTable,
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
