/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/exercise_repository.dart';

import '../../test_data/exercises.dart';
import '../helpers/in_memory_drift.dart';
import 'exercise_repository_test.mocks.dart';

@GenerateMocks([WgerBaseProvider])
void main() {
  late DriftPowersyncDatabase db;
  late MockWgerBaseProvider mockBase;
  late ExerciseRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    mockBase = MockWgerBaseProvider();
    repo = ExerciseRepository(mockBase, db);
  });

  tearDown(() async {
    await db.close();
  });

  // ---- seed helpers ---------------------------------------------------------

  Future<void> seedLanguage(int id, String shortName, String fullName) async {
    await db
        .into(db.languageTable)
        .insert(
          LanguageTableCompanion.insert(id: id, shortName: shortName, fullName: fullName),
        );
  }

  Future<void> seedCategory(int id, String name) async {
    await db
        .into(db.exerciseCategoryTable)
        .insert(ExerciseCategoryTableCompanion.insert(id: id, name: name));
  }

  Future<void> seedMuscle(int id, String name, {bool isFront = true}) async {
    await db
        .into(db.muscleTable)
        .insert(
          MuscleTableCompanion.insert(id: id, name: name, nameEn: name, isFront: isFront),
        );
  }

  Future<void> seedEquipment(int id, String name) async {
    await db.into(db.equipmentTable).insert(EquipmentTableCompanion.insert(id: id, name: name));
  }

  Future<void> seedExercise(int id, {required int categoryId, String? uuid}) async {
    await db
        .into(db.exerciseTable)
        .insert(
          ExerciseTableCompanion.insert(
            id: id,
            uuid: uuid ?? 'uuid-$id',
            categoryId: categoryId,
            created: DateTime.utc(2024),
            lastUpdate: DateTime.utc(2024),
          ),
        );
  }

  Future<void> seedTranslation(
    int id, {
    required int exerciseId,
    required int languageId,
    required String name,
  }) async {
    await db
        .into(db.exerciseTranslationTable)
        .insert(
          ExerciseTranslationTableCompanion.insert(
            id: id,
            uuid: 'tr-$id',
            exerciseId: exerciseId,
            languageId: languageId,
            name: name,
            description: 'desc',
            created: DateTime.utc(2024),
            lastUpdate: DateTime.utc(2024),
          ),
        );
  }

  Future<void> linkPrimaryMuscle(int exerciseId, int muscleId, {required int linkId}) async {
    await db
        .into(db.exerciseMuscleM2N)
        .insert(
          ExerciseMuscleM2NCompanion.insert(
            id: linkId,
            exerciseId: exerciseId,
            muscleId: muscleId,
          ),
        );
  }

  Future<void> linkSecondaryMuscle(int exerciseId, int muscleId, {required int linkId}) async {
    await db
        .into(db.exerciseSecondaryMuscleM2N)
        .insert(
          ExerciseSecondaryMuscleM2NCompanion.insert(
            id: linkId,
            exerciseId: exerciseId,
            muscleId: muscleId,
          ),
        );
  }

  Future<void> linkEquipment(int exerciseId, int equipmentId, {required int linkId}) async {
    await db
        .into(db.exerciseEquipmentM2N)
        .insert(
          ExerciseEquipmentM2NCompanion.insert(
            id: linkId,
            exerciseId: exerciseId,
            equipmentId: equipmentId,
          ),
        );
  }

  Future<void> seedImage(int id, {required int exerciseId, String? path}) async {
    await db
        .into(db.exerciseImageTable)
        .insert(
          ExerciseImageTableCompanion.insert(
            id: id,
            uuid: 'img-$id',
            exerciseId: exerciseId,
            image: path ?? 'images/$id.jpg',
            isMain: false,
            isAiGenerated: false,
            style: ExerciseImageStyle.photo,
            created: DateTime.utc(2024),
            lastUpdate: DateTime.utc(2024),
            licenseId: 1,
            licenseTitle: '',
            licenseObjectUrl: '',
            licenseAuthorUrl: '',
            licenseDerivativeSourceUrl: '',
          ),
        );
  }

  // ---------------------------------------------------------------------------

  group('watchAllDrift', () {
    test('emits an empty ExerciseState when no exercises exist', () async {
      final state = await repo.watchAllDrift().first;

      expect(state.exercises, isEmpty);
    });

    test(
      'hydrates a single exercise with category, translation, muscle, equipment, image',
      () async {
        await seedLanguage(testEnglish.id, 'en', 'English');
        await seedCategory(testCategoryArms.id, 'Arms');
        await seedMuscle(tMuscle1.id, 'Biceps');
        await seedEquipment(testEquipmentBench.id, 'Bench');
        await seedExercise(1, categoryId: testCategoryArms.id);
        await seedTranslation(101, exerciseId: 1, languageId: testEnglish.id, name: 'Bench Press');
        await linkPrimaryMuscle(1, tMuscle1.id, linkId: 1);
        await linkEquipment(1, testEquipmentBench.id, linkId: 1);
        await seedImage(1, exerciseId: 1);

        final state = await repo.watchAllDrift().first;

        expect(state.exercises, hasLength(1));
        final ex = state.exercises.single;
        expect(ex.id, 1);
        expect(ex.category.name, 'Arms');
        expect(ex.translations, hasLength(1));
        expect(ex.translations.single.name, 'Bench Press');
        expect(ex.translations.single.language.shortName, 'en');
        expect(ex.muscles.map((m) => m.id), [tMuscle1.id]);
        expect(ex.equipment.map((e) => e.id), [testEquipmentBench.id]);
        expect(ex.images, hasLength(1));
      },
    );

    test('keeps multiple translations under the same exercise', () async {
      await seedLanguage(testEnglish.id, 'en', 'English');
      await seedLanguage(testGerman.id, 'de', 'Deutsch');
      await seedCategory(testCategoryArms.id, 'Arms');
      await seedExercise(1, categoryId: testCategoryArms.id);
      await seedTranslation(1, exerciseId: 1, languageId: testEnglish.id, name: 'Bench Press');
      await seedTranslation(2, exerciseId: 1, languageId: testGerman.id, name: 'Bankdrücken');

      final state = await repo.watchAllDrift().first;

      expect(state.exercises.single.translations, hasLength(2));
      expect(
        state.exercises.single.translations.map((t) => t.name).toSet(),
        {'Bench Press', 'Bankdrücken'},
      );
    });

    test('separates primary and secondary muscles', () async {
      await seedCategory(testCategoryArms.id, 'Arms');
      await seedMuscle(tMuscle1.id, 'Pec');
      await seedMuscle(tMuscle2.id, 'Tri');
      await seedExercise(1, categoryId: testCategoryArms.id);
      await linkPrimaryMuscle(1, tMuscle1.id, linkId: 1);
      await linkSecondaryMuscle(1, tMuscle2.id, linkId: 1);

      final state = await repo.watchAllDrift().first;

      final ex = state.exercises.single;
      expect(ex.muscles.map((m) => m.id), [tMuscle1.id]);
      expect(ex.musclesSecondary.map((m) => m.id), [tMuscle2.id]);
    });

    test('keeps multiple equipment entries per exercise', () async {
      await seedCategory(testCategoryArms.id, 'Arms');
      await seedEquipment(testEquipmentBench.id, 'Bench');
      await seedEquipment(testEquipmentDumbbell.id, 'Dumbbell');
      await seedExercise(1, categoryId: testCategoryArms.id);
      await linkEquipment(1, testEquipmentBench.id, linkId: 1);
      await linkEquipment(1, testEquipmentDumbbell.id, linkId: 2);

      final state = await repo.watchAllDrift().first;

      expect(
        state.exercises.single.equipment.map((e) => e.id).toSet(),
        {testEquipmentBench.id, testEquipmentDumbbell.id},
      );
    });

    test('keeps multiple images per exercise', () async {
      await seedCategory(testCategoryArms.id, 'Arms');
      await seedExercise(1, categoryId: testCategoryArms.id);
      await seedImage(1, exerciseId: 1, path: 'one.jpg');
      await seedImage(2, exerciseId: 1, path: 'two.jpg');

      final state = await repo.watchAllDrift().first;

      expect(state.exercises.single.images, hasLength(2));
    });

    test('returns the exercise even if it has no translations or images', () async {
      await seedCategory(testCategoryArms.id, 'Arms');
      await seedExercise(1, categoryId: testCategoryArms.id);

      final state = await repo.watchAllDrift().first;

      expect(state.exercises, hasLength(1));
      expect(state.exercises.single.translations, isEmpty);
      expect(state.exercises.single.images, isEmpty);
    });

    test('keeps each exercise distinct when more than one is present', () async {
      await seedCategory(testCategoryArms.id, 'Arms');
      await seedExercise(1, categoryId: testCategoryArms.id);
      await seedExercise(2, categoryId: testCategoryArms.id);

      final state = await repo.watchAllDrift().first;

      expect(state.exercises.map((e) => e.id).toSet(), {1, 2});
    });
  });

  group('searchExerciseServer', () {
    test('returns an empty list for terms shorter than 2 chars', () async {
      expect(await repo.searchExerciseServer(''), isEmpty);
      expect(await repo.searchExerciseServer('a'), isEmpty);
      verifyNever(mockBase.fetch(any));
    });

    test('queries the exerciseinfo endpoint and extracts ids from results', () async {
      final uri = Uri.https('localhost', 'api/v2/exerciseinfo/');
      when(mockBase.makeUrl('exerciseinfo', query: anyNamed('query'))).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer(
        (_) async => {
          'results': [
            {'id': 7},
            {'id': 9},
          ],
        },
      );

      final ids = await repo.searchExerciseServer('bench');

      expect(ids, [7, 9]);
    });

    test('passes the language code to the query', () async {
      final uri = Uri.https('localhost', 'api/v2/exerciseinfo/');
      when(mockBase.makeUrl('exerciseinfo', query: anyNamed('query'))).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer((_) async => {'results': []});

      await repo.searchExerciseServer('bench', languageCode: 'de');

      final captured =
          verify(
                mockBase.makeUrl('exerciseinfo', query: captureAnyNamed('query')),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['language__code'], 'de');
      expect(captured['name__search'], 'bench');
    });

    test('searchEnglish appends "en" to the language list', () async {
      final uri = Uri.https('localhost', 'api/v2/exerciseinfo/');
      when(mockBase.makeUrl('exerciseinfo', query: anyNamed('query'))).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer((_) async => {'results': []});

      await repo.searchExerciseServer('bench', languageCode: 'de', searchEnglish: true);

      final captured =
          verify(
                mockBase.makeUrl('exerciseinfo', query: captureAnyNamed('query')),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['language__code'], 'de,en');
    });

    test('searchEnglish does not duplicate when languageCode is already "en"', () async {
      final uri = Uri.https('localhost', 'api/v2/exerciseinfo/');
      when(mockBase.makeUrl('exerciseinfo', query: anyNamed('query'))).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer((_) async => {'results': []});

      await repo.searchExerciseServer('bench', languageCode: 'en', searchEnglish: true);

      final captured =
          verify(
                mockBase.makeUrl('exerciseinfo', query: captureAnyNamed('query')),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['language__code'], 'en');
    });
  });

  group('reference-data watchers', () {
    test('watchCategoriesDrift emits the seeded categories', () async {
      await seedCategory(testCategoryArms.id, 'Arms');
      await seedCategory(testCategoryLegs.id, 'Legs');

      final categories = await repo.watchCategoriesDrift().first;

      expect(categories.map((c) => c.id).toSet(), {testCategoryArms.id, testCategoryLegs.id});
    });

    test('watchEquipmentDrift emits the seeded equipment', () async {
      await seedEquipment(testEquipmentBench.id, 'Bench');

      final equipment = await repo.watchEquipmentDrift().first;

      expect(equipment.single.id, testEquipmentBench.id);
    });

    test('watchMusclesDrift emits the seeded muscles', () async {
      await seedMuscle(tMuscle1.id, 'Pec');

      final muscles = await repo.watchMusclesDrift().first;

      expect(muscles.single.id, tMuscle1.id);
    });

    test('watchLanguagesDrift emits the seeded languages', () async {
      await seedLanguage(testEnglish.id, 'en', 'English');

      final languages = await repo.watchLanguagesDrift().first;

      expect(languages.single.id, testEnglish.id);
    });
  });
}
