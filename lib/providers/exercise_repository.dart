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

import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/core/language.dart';
import 'package:wger/models/core/search_options.dart';
import 'package:wger/models/exercises/alias.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/exercise_filters.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/exercises/video.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercises_notifier.dart';
import 'package:wger/providers/wger_base.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final base = ref.read(wgerBaseProvider);
  final db = ref.read(driftPowerSyncDatabase);
  return ExerciseRepository(base, db);
});

/// Read access for the exercise catalogue.
///
/// The catalogue is denormalised across many tables (translations, muscles,
/// equipment, category, images, videos), this repository owns the join +
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

  /// Searches by name with extended options: language scope, fulltext-vs-exact
  /// match, and category filter. Returns ID list for hydration on the caller.
  Future<List<int>> searchExerciseServerWithSearchMode(
    String term, {
    String languageCode = LANGUAGE_SHORT_ENGLISH,
    SearchLanguage searchLanguage = SearchLanguage.currentAndEnglish,
    ExerciseSearchMode searchMode = ExerciseSearchMode.fulltext,
    Set<ExerciseCategory> categories = const {},
  }) async {
    if (term.length <= 1) {
      return [];
    }
    _logger.info('Online search for exercises (mode=$searchMode): $term');

    final languageCodes = [languageCode];
    if (searchLanguage == SearchLanguage.currentAndEnglish &&
        languageCode != LANGUAGE_SHORT_ENGLISH) {
      languageCodes.add(LANGUAGE_SHORT_ENGLISH);
    } else if (searchLanguage == SearchLanguage.all) {
      languageCodes.clear();
    }

    final query = <String, String>{};
    if (searchMode == ExerciseSearchMode.fulltext) {
      query['name__search'] = term;
    } else {
      query['name__exact'] = term;
    }
    if (languageCodes.isNotEmpty) {
      query['language__code'] = languageCodes.join(',');
    }
    if (categories.isNotEmpty) {
      query['category__in'] = categories.map((c) => c.id).join(',');
    }
    query['limit'] = API_RESULTS_PAGE_SIZE;

    final result = await _base.fetch(_base.makeUrl(exerciseInfoUrlPath, query: query));
    return (result['results'] as List).map<int>((data) => data['id'] as int).toList();
  }

  /// Streams the full exercise catalogue, hydrated with translations,
  /// muscles, equipment, category, images and videos.
  ///
  /// Only the exercise + translation (+ translation language) part runs as
  /// a SQL JOIN. The reference tables (muscles, equipment, categories) and
  /// the fan-out tables (M2N relations, images, videos) are streamed
  /// separately and joined in Dart. This is more effective and we don't have to
  /// pay drift's per-row mapping for every joined column.
  Stream<ExerciseState> watchAllDrift() {
    _logger.finer('Watching all local exercises');

    final exerciseTranslationStream = _db.select(_db.exerciseTable).join([
      leftOuterJoin(
        _db.exerciseTranslationTable,
        _db.exerciseTranslationTable.exerciseId.equalsExp(_db.exerciseTable.id),
      ),
    ]).watch();

    List<TypedResult>? exerciseRows;
    List<Muscle>? muscles;
    List<Equipment>? equipment;
    List<ExerciseCategory>? categories;
    List<Language>? languages;
    List<ExerciseMuscleM2NData>? primaryM2N;
    List<ExerciseSecondaryMuscleM2NData>? secondaryM2N;
    List<ExerciseEquipmentM2NData>? equipmentM2N;
    List<ExerciseImage>? images;
    List<Video>? videos;
    List<Alias>? aliases;
    List<Comment>? comments;

    late StreamController<ExerciseState> controller;
    final subs = <StreamSubscription>[];

    void emit() {
      if (exerciseRows == null ||
          muscles == null ||
          equipment == null ||
          categories == null ||
          languages == null ||
          primaryM2N == null ||
          secondaryM2N == null ||
          equipmentM2N == null ||
          images == null ||
          videos == null ||
          aliases == null ||
          comments == null) {
        return;
      }

      final muscleById = {for (final m in muscles!) m.id: m};
      final equipmentById = {for (final e in equipment!) e.id: e};
      final categoryById = {for (final c in categories!) c.id: c};
      final languageById = {for (final l in languages!) l.id: l};

      final primaryByExercise = <int, List<int>>{};
      for (final row in primaryM2N!) {
        primaryByExercise.putIfAbsent(row.exerciseId, () => []).add(row.muscleId);
      }
      final secondaryByExercise = <int, List<int>>{};
      for (final row in secondaryM2N!) {
        secondaryByExercise.putIfAbsent(row.exerciseId, () => []).add(row.muscleId);
      }
      final equipmentByExercise = <int, List<int>>{};
      for (final row in equipmentM2N!) {
        equipmentByExercise.putIfAbsent(row.exerciseId, () => []).add(row.equipmentId);
      }
      final imagesByExercise = <int, List<ExerciseImage>>{};
      for (final img in images!) {
        imagesByExercise.putIfAbsent(img.exerciseId, () => []).add(img);
      }
      final videosByExercise = <int, List<Video>>{};
      for (final v in videos!) {
        videosByExercise.putIfAbsent(v.exerciseId, () => []).add(v);
      }
      final aliasesByTranslation = <int, List<Alias>>{};
      for (final a in aliases!) {
        if (a.translationId != null) {
          aliasesByTranslation.putIfAbsent(a.translationId!, () => []).add(a);
        }
      }
      final commentsByTranslation = <int, List<Comment>>{};
      for (final c in comments!) {
        commentsByTranslation.putIfAbsent(c.translationId, () => []).add(c);
      }

      // First pass over the exercise+translation JOIN: collect one row per
      // exercise (the exercise side repeats per translation) and group the
      // hydrated translations by exercise id.
      final exerciseRowById = <int, ExerciseRow>{};
      final translationsByExercise = <int, List<Translation>>{};
      for (final row in exerciseRows!) {
        final exerciseRow = row.readTable(_db.exerciseTable);
        exerciseRowById[exerciseRow.id] = exerciseRow;

        final translationRow = row.readTableOrNull(_db.exerciseTranslationTable);
        if (translationRow == null) {
          continue;
        }
        // Skip translations whose language has not synced yet: the language
        // table catches up on a later emission, so the translation reappears
        // then. This keeps Translation.language a non-null guarantee.
        final language = languageById[translationRow.languageId];
        if (language == null) {
          continue;
        }
        final list = translationsByExercise.putIfAbsent(exerciseRow.id, () => []);
        if (list.any((t) => t.id == translationRow.id)) {
          continue;
        }
        list.add(
          Translation(
            id: translationRow.id,
            uuid: translationRow.uuid,
            created: translationRow.created,
            name: translationRow.name,
            description: translationRow.description,
            exerciseId: translationRow.exerciseId,
            language: language,
            aliases: aliasesByTranslation[translationRow.id] ?? const [],
            notes: commentsByTranslation[translationRow.id] ?? const [],
          ),
        );
      }

      // Second pass: assemble the immutable exercises. Skip any whose
      // category has not synced yet (same transient-window argument as the
      // translation language above).
      final exercises = <Exercise>[];
      for (final exerciseRow in exerciseRowById.values) {
        final category = categoryById[exerciseRow.categoryId];
        if (category == null) {
          continue;
        }
        exercises.add(
          Exercise(
            id: exerciseRow.id,
            uuid: exerciseRow.uuid,
            created: exerciseRow.created,
            lastUpdate: exerciseRow.lastUpdate,
            variationGroup: exerciseRow.variationGroup,
            category: category,
            muscles: [
              for (final id in primaryByExercise[exerciseRow.id] ?? const <int>[])
                if (muscleById[id] != null) muscleById[id]!,
            ],
            musclesSecondary: [
              for (final id in secondaryByExercise[exerciseRow.id] ?? const <int>[])
                if (muscleById[id] != null) muscleById[id]!,
            ],
            equipment: [
              for (final id in equipmentByExercise[exerciseRow.id] ?? const <int>[])
                if (equipmentById[id] != null) equipmentById[id]!,
            ],
            images: imagesByExercise[exerciseRow.id] ?? const [],
            videos: videosByExercise[exerciseRow.id] ?? const [],
            translations: translationsByExercise[exerciseRow.id] ?? const [],
          ),
        );
      }

      controller.add(ExerciseState(exercises));
    }

    controller = StreamController<ExerciseState>(
      onListen: () {
        void addSub<T>(Stream<T> source, void Function(T) assign) {
          subs.add(
            source.listen(
              (value) {
                assign(value);
                emit();
              },
              onError: controller.addError,
            ),
          );
        }

        addSub(exerciseTranslationStream, (v) => exerciseRows = v);
        addSub(_db.select(_db.muscleTable).watch(), (v) => muscles = v);
        addSub(_db.select(_db.equipmentTable).watch(), (v) => equipment = v);
        addSub(_db.select(_db.exerciseCategoryTable).watch(), (v) => categories = v);
        addSub(_db.select(_db.languageTable).watch(), (v) => languages = v);
        addSub(_db.select(_db.exerciseMuscleM2N).watch(), (v) => primaryM2N = v);
        addSub(
          _db.select(_db.exerciseSecondaryMuscleM2N).watch(),
          (v) => secondaryM2N = v,
        );
        addSub(_db.select(_db.exerciseEquipmentM2N).watch(), (v) => equipmentM2N = v);
        addSub(_db.select(_db.exerciseImageTable).watch(), (v) => images = v);
        addSub(_db.select(_db.exerciseVideoTable).watch(), (v) => videos = v);
        addSub(_db.select(_db.exerciseAliasTable).watch(), (v) => aliases = v);
        addSub(_db.select(_db.exerciseCommentTable).watch(), (v) => comments = v);
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );

    return controller.stream;
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

  /// Streams the list of supported languages, reference data for exercise
  /// translations.
  Stream<List<Language>> watchLanguagesDrift() {
    return _db.select(_db.languageTable).watch();
  }
}
