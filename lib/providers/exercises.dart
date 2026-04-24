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
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/wger_base.dart';

part 'exercises.g.dart';

class ExerciseState {
  final List<Exercise> exercises;

  const ExerciseState(this.exercises);

  /// Returns the exercise with the given [id], throws if no match
  Exercise getById(int id) => exercises.firstWhere((e) => e.id == id);

  /// Buckets exercises by their `variationGroup` (skipping those without one)
  Map<String, List<Exercise>> getByVariation() {
    final Map<String, List<Exercise>> variations = {};
    for (final exercise in exercises.where((e) => e.variationGroup != null)) {
      variations.putIfAbsent(exercise.variationGroup!, () => []).add(exercise);
    }
    return variations;
  }

  /// All exercises that share the given variation group, optionally excluding one
  List<Exercise> findByVariationGroup(String? variationGroup, {int? exerciseIdToExclude}) {
    if (variationGroup == null) {
      return [];
    }
    var out = exercises.where((b) => b.variationGroup == variationGroup).toList();
    if (exerciseIdToExclude != null) {
      out = out.where((e) => e.id != exerciseIdToExclude).toList();
    }
    return out;
  }
}

@Riverpod(keepAlive: true)
class Exercises extends _$Exercises {
  final _logger = Logger('Exercises');

  static const exerciseInfoUrlPath = 'exerciseinfo';

  @override
  Stream<ExerciseState> build() {
    ref.keepAlive();
    final db = ref.read(driftPowerSyncDatabase);
    _logger.finer('Building exercise stream');

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

      return ExerciseState(map.values.toList());
    });
  }

  /*
   * Search.
   *
   * These read [state.value?.exercises] (the current snapshot, or
   * empty while the stream hasn't emitted yet). They live on the
   * notifier because [searchExerciseOnline] needs `ref` for the HTTP
   * call, and keeping its sibling on the same surface makes the API
   * predictable.
   */

  List<Exercise> get _exercises => state.value?.exercises ?? const [];

  /// Routes to either [searchExerciseOnline] or [searchExerciseLocal]
  /// based on [useOnlineSearch]. Empty term returns an empty list.
  Future<List<Exercise>> searchExercise(
    String term, {
    bool useOnlineSearch = true,
    String languageCode = 'en',
    bool searchEnglish = false,
  }) async {
    if (term.isEmpty) {
      return [];
    }
    final searchMethod = useOnlineSearch ? searchExerciseOnline : searchExerciseLocal;
    return searchMethod(term, languageCode: languageCode, searchEnglish: searchEnglish);
  }

  /// Asks the wger backend to search by name (with `name__search`),
  /// then resolves the returned IDs against the local in-memory list
  /// so the caller gets fully-hydrated [Exercise] instances back.
  Future<List<Exercise>> searchExerciseOnline(
    String term, {
    String languageCode = 'en',
    bool searchEnglish = false,
  }) async {
    if (term.length <= 1) {
      return [];
    }
    final wgerBase = ref.read(wgerBaseProvider);
    _logger.info('Online search for exercises: $term');

    final languages = [languageCode];
    if (searchEnglish && languageCode != LANGUAGE_SHORT_ENGLISH) {
      languages.add(LANGUAGE_SHORT_ENGLISH);
    }

    final result = await wgerBase.fetch(
      wgerBase.makeUrl(
        exerciseInfoUrlPath,
        query: {
          'name__search': term,
          'language__code': languages.join(','),
          'limit': API_RESULTS_PAGE_SIZE,
        },
      ),
    );

    final ids = (result['results'] as List).map<int>((data) => data['id'] as int).toList();
    return _exercises.where((e) => ids.contains(e.id)).toList();
  }

  /// Pure in-memory substring search across the configured translations.
  Future<List<Exercise>> searchExerciseLocal(
    String term, {
    String languageCode = 'en',
    bool searchEnglish = false,
  }) async {
    _logger.fine('Local search for exercises: $term');

    final languages = [languageCode];
    if (searchEnglish && languageCode != 'en') {
      languages.add('en');
    }

    final List<Exercise> out = [];
    final lowerTerm = term.toLowerCase();
    for (final e in _exercises) {
      for (final lang in languages) {
        final title = (e.getTranslation(lang).name ?? '').toLowerCase();
        if (title.contains(lowerTerm)) {
          out.add(e);
          break;
        }
      }
    }
    return out;
  }
}

@riverpod
Stream<List<ExerciseCategory>> exerciseCategories(Ref ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return db.select(db.exerciseCategoryTable).watch();
}

@riverpod
Stream<List<Equipment>> exerciseEquipment(Ref ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return db.select(db.equipmentTable).watch();
}

@riverpod
Stream<List<Muscle>> exerciseMuscles(Ref ref) {
  final db = ref.read(driftPowerSyncDatabase);
  return db.select(db.muscleTable).watch();
}
