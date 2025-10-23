import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';

part 'exercise_data.g.dart';

@riverpod
final class ExerciseNotifier extends _$ExerciseNotifier {
  final _logger = Logger('ExerciseNotifier');

  @override
  Stream<List<Exercise>> build() {
    final db = ref.read(driftPowerSyncDatabase);

    final primaryMuscleTable = db.alias(db.muscleTable, 'pm');
    final secondaryMuscleTable = db.alias(db.muscleTable, 'sm');

    final joined = db.select(db.exerciseTable).join([
      // Translations
      leftOuterJoin(
        db.exerciseTranslationTable,
        db.exerciseTranslationTable.exerciseId.equalsExp(db.exerciseTable.id),
      ),

      // Exercise <-> Muscle
      leftOuterJoin(
        db.exerciseMuscleM2N,
        db.exerciseMuscleM2N.exerciseId.equalsExp(db.exerciseTable.id),
      ),
      leftOuterJoin(
        primaryMuscleTable,
        primaryMuscleTable.id.equalsExp(db.exerciseMuscleM2N.muscleId),
      ),

      // Exercise <-> Secondary Muscle
      leftOuterJoin(
        db.exerciseSecondaryMuscleM2N,
        db.exerciseSecondaryMuscleM2N.exerciseId.equalsExp(db.exerciseTable.id),
      ),
      leftOuterJoin(
        secondaryMuscleTable,
        secondaryMuscleTable.id.equalsExp(db.exerciseSecondaryMuscleM2N.muscleId),
      ),

      // Category
      leftOuterJoin(
        db.exerciseCategoryTable,
        db.exerciseCategoryTable.id.equalsExp(db.exerciseTable.categoryId),
      ),

      // Images
      leftOuterJoin(
        db.exerciseImageTable,
        db.exerciseImageTable.exerciseId.equalsExp(db.exerciseTable.id),
      ),
    ]);

    return joined.watch().map((rows) {
      final Map<int, Exercise> map = {};

      for (final row in rows) {
        final exercise = row.readTable(db.exerciseTable);
        final primaryMuscle = row.readTableOrNull(primaryMuscleTable);
        final secondaryMuscle = row.readTableOrNull(secondaryMuscleTable);
        final image = row.readTableOrNull(db.exerciseImageTable);
        final video = row.readTableOrNull(db.exerciseVideoTable);
        final translation = row.readTableOrNull(db.exerciseTranslationTable);
        final category = row.readTableOrNull(db.exerciseCategoryTable);

        final entry = map.putIfAbsent(
          exercise.id,
          () => exercise,
        );

        if (category != null) {
          entry.category = category;
        }

        if (translation != null && !entry.translations.any((t) => t.id == translation.id)) {
          entry.translations.add(translation);
        }

        if (image != null && !entry.images.any((t) => t.id == image.id)) {
          entry.images.add(image);
        }

        if (video != null && !entry.videos.any((t) => t.id == video.id)) {
          entry.videos.add(video);
        }

        if (primaryMuscle != null && !entry.muscles.any((m) => m.id == primaryMuscle.id)) {
          entry.muscles.add(primaryMuscle);
        }

        if (secondaryMuscle != null &&
            !entry.musclesSecondary.any((m) => m.id == secondaryMuscle.id)) {
          entry.musclesSecondary.add(secondaryMuscle);
        }
      }

      return map.values.toList();
    });
  }
}

@riverpod
final class ExerciseEquipmentNotifier extends _$ExerciseEquipmentNotifier {
  @override
  Stream<List<Equipment>> build() {
    final db = ref.read(driftPowerSyncDatabase);
    return db.select(db.equipmentTable).watch();
  }
}
