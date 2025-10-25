/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2025 wger Team
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
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/muscle.dart';

part 'exercise_data.g.dart';

@Riverpod(keepAlive: true)
final class ExerciseNotifier extends _$ExerciseNotifier {
  final _logger = Logger('ExerciseNotifier');

  @override
  Stream<List<Exercise>> build() {
    ref.keepAlive();
    final db = ref.read(driftPowerSyncDatabase);
    _logger.fine('Building exercise stream');

    final primaryMuscleTable = db.alias(db.muscleTable, 'pm');
    final secondaryMuscleTable = db.alias(db.muscleTable, 'sm');

    final joined = db.select(db.exerciseTable).join([
      // Translations
      leftOuterJoin(
        db.exerciseTranslationTable,
        db.exerciseTranslationTable.exerciseId.equalsExp(db.exerciseTable.id),
      ),

      // Language
      leftOuterJoin(
        db.languageTable,
        db.languageTable.id.equalsExp(db.exerciseTranslationTable.languageId),
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

      // Exercise <-> Equipment
      leftOuterJoin(
        db.exerciseEquipmentM2N,
        db.exerciseEquipmentM2N.exerciseId.equalsExp(db.exerciseTable.id),
      ),
      leftOuterJoin(
        db.equipmentTable,
        db.equipmentTable.id.equalsExp(db.exerciseEquipmentM2N.equipmentId),
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
        final equipment = row.readTableOrNull(db.equipmentTable);
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
          translation.language = row.readTable(db.languageTable);
          entry.translations.add(translation);
        }

        if (image != null && !entry.images.any((t) => t.id == image.id)) {
          entry.images.add(image);
        }

        if (video != null && !entry.videos.any((t) => t.id == video.id)) {
          entry.videos.add(video);
        }

        if (equipment != null && !entry.equipment.any((e) => e.id == equipment.id)) {
          entry.equipment.add(equipment);
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

  Exercise? getById(int id) {
    // Can be null e.g. during initial loading
    final cached = state.asData?.value;
    if (cached == null) {
      return null;
    }

    for (final e in cached) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }
}

@riverpod
final class ExerciseCategoryNotifier extends _$ExerciseCategoryNotifier {
  @override
  Stream<List<ExerciseCategory>> build() {
    final db = ref.read(driftPowerSyncDatabase);
    return db.select(db.exerciseCategoryTable).watch();
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

@riverpod
final class ExerciseMuscleNotifier extends _$ExerciseMuscleNotifier {
  @override
  Stream<List<Muscle>> build() {
    final db = ref.read(driftPowerSyncDatabase);
    return db.select(db.muscleTable).watch();
  }
}
