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

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/core/language.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/providers/exercise_repository.dart';
import 'package:wger/providers/network_provider.dart';

part 'exercises_notifier.g.dart';

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

  @override
  Stream<ExerciseState> build() {
    ref.keepAlive();
    _logger.finer('Building exercise stream');
    final repo = ref.read(exerciseRepositoryProvider);
    return repo.watchAllDrift();
  }

  List<Exercise> get _exercises => state.value?.exercises ?? const [];

  /// Searches for exercises matching [term].
  ///
  /// Routes to the REST API when the device is online, or to the in-memory
  /// snapshot when offline. Empty term returns an empty list.
  Future<List<Exercise>> searchExercise(
    String term, {
    String languageCode = 'en',
    bool searchEnglish = false,
  }) async {
    if (term.isEmpty) {
      return [];
    }
    if (ref.read(networkStatusProvider)) {
      // The repo's REST search returns just IDs; hydrate them against the
      // already-loaded snapshot (the catalogue is always fully synced) so
      // the caller gets full Exercise objects regardless of which path ran.
      final ids = await ref
          .read(exerciseRepositoryProvider)
          .searchExerciseServer(term, languageCode: languageCode, searchEnglish: searchEnglish);
      return _exercises.where((e) => ids.contains(e.id)).toList();
    }
    return _searchExerciseLocal(term, languageCode: languageCode, searchEnglish: searchEnglish);
  }

  /// Pure in-memory substring search across the configured translations.
  /// Lives on the notifier because the corpus is the already-hydrated
  /// `state.value?.exercises` snapshot.
  Future<List<Exercise>> _searchExerciseLocal(
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
        final title = e.getTranslation(lang).name.toLowerCase();
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
  return ref.read(exerciseRepositoryProvider).watchCategoriesDrift();
}

@riverpod
Stream<List<Equipment>> exerciseEquipment(Ref ref) {
  return ref.read(exerciseRepositoryProvider).watchEquipmentDrift();
}

@riverpod
Stream<List<Muscle>> exerciseMuscles(Ref ref) {
  return ref.read(exerciseRepositoryProvider).watchMusclesDrift();
}

@riverpod
Stream<List<Language>> languages(Ref ref) {
  return ref.read(exerciseRepositoryProvider).watchLanguagesDrift();
}
