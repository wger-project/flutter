/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/core/language.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/providers/wger_base.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final base = ref.read(wgerBaseProvider);
  final db = ref.read(driftPowerSyncDatabase);
  return ExerciseRepository(base, db);
});

/// Read access for the exercise catalogue.
///
/// The catalogue is denormalised across many tables (translations, muscles,
/// equipment, category, images, videos) — this repository owns the join +
/// assembly so the [Exercises] notifier stays focused on state-shape and
/// search routing, and so tests can swap a single mock instead of stubbing
/// the whole `DriftPowersyncDatabase`.
class ExerciseRepository {
  final _logger = Logger('ExerciseRepository');
  final WgerBaseProvider _base;
  final DriftPowersyncDatabase _db;

  static const exerciseInfoUrlPath = 'exerciseinfo';

  ExerciseRepository(this._base, this._db);

  /// Asks the wger backend to search by name. Hydration into [Exercise] objects
  /// happens on [Exercises] against its in-memory snapshot.
  Future<List<int>> searchExerciseServer(
    String term, {
    String languageCode = 'en',
    bool searchEnglish = false,
  }) async {
    if (term.length <= 1) {
      return [];
    }
    _logger.info('Online search for exercises: $term');

    final languages = [languageCode];
    if (searchEnglish && languageCode != LANGUAGE_SHORT_ENGLISH) {
      languages.add(LANGUAGE_SHORT_ENGLISH);
    }

    final result = await _base.fetch(
      _base.makeUrl(
        exerciseInfoUrlPath,
        query: {
          'name__search': term,
          'language__code': languages.join(','),
          'limit': API_RESULTS_PAGE_SIZE,
        },
      ),
    );

    return (result['results'] as List).map<int>((data) => data['id'] as int).toList();
  }

  /// Streams the full exercise catalogue, hydrated with translations,
  /// muscles, equipment, category, images and videos.
  Stream<ExerciseState> watchAllDrift() {
    _logger.finer('Watching all local exercises');

    final primaryMuscleTable = _db.alias(_db.muscleTable, 'pm');
    final secondaryMuscleTable = _db.alias(_db.muscleTable, 'sm');

    final joined = _db.select(_db.exerciseTable).join([
      // Translations
      leftOuterJoin(
        _db.exerciseTranslationTable,
        _db.exerciseTranslationTable.exerciseId.equalsExp(_db.exerciseTable.id),
      ),

      // Language
      leftOuterJoin(
        _db.languageTable,
        _db.languageTable.id.equalsExp(_db.exerciseTranslationTable.languageId),
      ),

      // Exercise <-> Muscle
      leftOuterJoin(
        _db.exerciseMuscleM2N,
        _db.exerciseMuscleM2N.exerciseId.equalsExp(_db.exerciseTable.id),
      ),
      leftOuterJoin(
        primaryMuscleTable,
        primaryMuscleTable.id.equalsExp(_db.exerciseMuscleM2N.muscleId),
      ),

      // Exercise <-> Secondary Muscle
      leftOuterJoin(
        _db.exerciseSecondaryMuscleM2N,
        _db.exerciseSecondaryMuscleM2N.exerciseId.equalsExp(_db.exerciseTable.id),
      ),
      leftOuterJoin(
        secondaryMuscleTable,
        secondaryMuscleTable.id.equalsExp(_db.exerciseSecondaryMuscleM2N.muscleId),
      ),

      // Exercise <-> Equipment
      leftOuterJoin(
        _db.exerciseEquipmentM2N,
        _db.exerciseEquipmentM2N.exerciseId.equalsExp(_db.exerciseTable.id),
      ),
      leftOuterJoin(
        _db.equipmentTable,
        _db.equipmentTable.id.equalsExp(_db.exerciseEquipmentM2N.equipmentId),
      ),

      // Category
      leftOuterJoin(
        _db.exerciseCategoryTable,
        _db.exerciseCategoryTable.id.equalsExp(_db.exerciseTable.categoryId),
      ),

      // Images
      leftOuterJoin(
        _db.exerciseImageTable,
        _db.exerciseImageTable.exerciseId.equalsExp(_db.exerciseTable.id),
      ),
    ]);

    return joined.watch().map((rows) {
      final Map<int, Exercise> map = {};

      for (final row in rows) {
        final exercise = row.readTable(_db.exerciseTable);
        final primaryMuscle = row.readTableOrNull(primaryMuscleTable);
        final secondaryMuscle = row.readTableOrNull(secondaryMuscleTable);
        final equipment = row.readTableOrNull(_db.equipmentTable);
        final image = row.readTableOrNull(_db.exerciseImageTable);
        final video = row.readTableOrNull(_db.exerciseVideoTable);
        final translation = row.readTableOrNull(_db.exerciseTranslationTable);
        final category = row.readTableOrNull(_db.exerciseCategoryTable);

        final entry = map.putIfAbsent(
          exercise.id,
          () => exercise,
        );

        if (category != null) {
          entry.category = category;
        }

        if (translation != null && !entry.translations.any((t) => t.id == translation.id)) {
          translation.language = row.readTable(_db.languageTable);
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

      return ExerciseState(map.values.toList());
    });
  }

  /// Streams all exercise categories.
  Stream<List<ExerciseCategory>> watchCategoriesDrift() {
    return _db.select(_db.exerciseCategoryTable).watch();
  }

  /// Streams all exercise equipment.
  Stream<List<Equipment>> watchEquipmentDrift() {
    return _db.select(_db.equipmentTable).watch();
  }

  /// Streams all exercise muscles.
  Stream<List<Muscle>> watchMusclesDrift() {
    return _db.select(_db.muscleTable).watch();
  }

  /// Streams the list of supported languages — reference data for exercise
  /// translations.
  Stream<List<Language>> watchLanguagesDrift() {
    return _db.select(_db.languageTable).watch();
  }
}
