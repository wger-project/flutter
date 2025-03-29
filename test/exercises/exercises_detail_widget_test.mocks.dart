// Mocks generated by Mockito 5.4.5 from annotations
// in wger/test/exercises/exercises_detail_widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i10;
import 'dart:ui' as _i11;

import 'package:mockito/mockito.dart' as _i1;
import 'package:wger/database/exercises/exercise_database.dart' as _i3;
import 'package:wger/models/exercises/category.dart' as _i5;
import 'package:wger/models/exercises/equipment.dart' as _i6;
import 'package:wger/models/exercises/exercise.dart' as _i4;
import 'package:wger/models/exercises/language.dart' as _i8;
import 'package:wger/models/exercises/muscle.dart' as _i7;
import 'package:wger/providers/base_provider.dart' as _i2;
import 'package:wger/providers/exercises.dart' as _i9;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeWgerBaseProvider_0 extends _i1.SmartFake implements _i2.WgerBaseProvider {
  _FakeWgerBaseProvider_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeExerciseDatabase_1 extends _i1.SmartFake implements _i3.ExerciseDatabase {
  _FakeExerciseDatabase_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeExercise_2 extends _i1.SmartFake implements _i4.Exercise {
  _FakeExercise_2(Object parent, Invocation parentInvocation) : super(parent, parentInvocation);
}

class _FakeExerciseCategory_3 extends _i1.SmartFake implements _i5.ExerciseCategory {
  _FakeExerciseCategory_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeEquipment_4 extends _i1.SmartFake implements _i6.Equipment {
  _FakeEquipment_4(Object parent, Invocation parentInvocation) : super(parent, parentInvocation);
}

class _FakeMuscle_5 extends _i1.SmartFake implements _i7.Muscle {
  _FakeMuscle_5(Object parent, Invocation parentInvocation) : super(parent, parentInvocation);
}

class _FakeLanguage_6 extends _i1.SmartFake implements _i8.Language {
  _FakeLanguage_6(Object parent, Invocation parentInvocation) : super(parent, parentInvocation);
}

/// A class which mocks [ExercisesProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockExercisesProvider extends _i1.Mock implements _i9.ExercisesProvider {
  MockExercisesProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WgerBaseProvider get baseProvider => (super.noSuchMethod(
        Invocation.getter(#baseProvider),
        returnValue: _FakeWgerBaseProvider_0(
          this,
          Invocation.getter(#baseProvider),
        ),
      ) as _i2.WgerBaseProvider);

  @override
  _i3.ExerciseDatabase get database => (super.noSuchMethod(
        Invocation.getter(#database),
        returnValue: _FakeExerciseDatabase_1(
          this,
          Invocation.getter(#database),
        ),
      ) as _i3.ExerciseDatabase);

  @override
  set database(_i3.ExerciseDatabase? _database) => super.noSuchMethod(
        Invocation.setter(#database, _database),
        returnValueForMissingStub: null,
      );

  @override
  List<_i4.Exercise> get exercises => (super.noSuchMethod(
        Invocation.getter(#exercises),
        returnValue: <_i4.Exercise>[],
      ) as List<_i4.Exercise>);

  @override
  set exercises(List<_i4.Exercise>? _exercises) => super.noSuchMethod(
        Invocation.setter(#exercises, _exercises),
        returnValueForMissingStub: null,
      );

  @override
  List<_i4.Exercise> get filteredExercises => (super.noSuchMethod(
        Invocation.getter(#filteredExercises),
        returnValue: <_i4.Exercise>[],
      ) as List<_i4.Exercise>);

  @override
  set filteredExercises(List<_i4.Exercise>? newFilteredExercises) => super.noSuchMethod(
        Invocation.setter(#filteredExercises, newFilteredExercises),
        returnValueForMissingStub: null,
      );

  @override
  Map<int, List<_i4.Exercise>> get exerciseByVariation => (super.noSuchMethod(
        Invocation.getter(#exerciseBasesByVariation),
        returnValue: <int, List<_i4.Exercise>>{},
      ) as Map<int, List<_i4.Exercise>>);

  @override
  List<_i5.ExerciseCategory> get categories => (super.noSuchMethod(
        Invocation.getter(#categories),
        returnValue: <_i5.ExerciseCategory>[],
      ) as List<_i5.ExerciseCategory>);

  @override
  List<_i7.Muscle> get muscles => (super.noSuchMethod(
        Invocation.getter(#muscles),
        returnValue: <_i7.Muscle>[],
      ) as List<_i7.Muscle>);

  @override
  List<_i6.Equipment> get equipment => (super.noSuchMethod(
        Invocation.getter(#equipment),
        returnValue: <_i6.Equipment>[],
      ) as List<_i6.Equipment>);

  @override
  List<_i8.Language> get languages => (super.noSuchMethod(
        Invocation.getter(#languages),
        returnValue: <_i8.Language>[],
      ) as List<_i8.Language>);

  @override
  set languages(List<_i8.Language>? languages) => super.noSuchMethod(
        Invocation.setter(#languages, languages),
        returnValueForMissingStub: null,
      );

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false) as bool);

  @override
  _i10.Future<void> setFilters(_i9.Filters? newFilters) => (super.noSuchMethod(
        Invocation.method(#setFilters, [newFilters]),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  void initFilters() => super.noSuchMethod(
        Invocation.method(#initFilters, []),
        returnValueForMissingStub: null,
      );

  @override
  _i10.Future<void> findByFilters() => (super.noSuchMethod(
        Invocation.method(#findByFilters, []),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  void clear() => super.noSuchMethod(
        Invocation.method(#clear, []),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Exercise findExerciseById(int? id) => (super.noSuchMethod(
        Invocation.method(#findExerciseById, [id]),
        returnValue: _FakeExercise_2(
          this,
          Invocation.method(#findExerciseById, [id]),
        ),
      ) as _i4.Exercise);

  @override
  List<_i4.Exercise> findExercisesByVariationId(
    int? variationId, {
    int? exerciseIdToExclude,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #findExercisesByVariationId,
          [variationId],
          {#exerciseIdToExclude: exerciseIdToExclude},
        ),
        returnValue: <_i4.Exercise>[],
      ) as List<_i4.Exercise>);

  @override
  _i5.ExerciseCategory findCategoryById(int? id) => (super.noSuchMethod(
        Invocation.method(#findCategoryById, [id]),
        returnValue: _FakeExerciseCategory_3(
          this,
          Invocation.method(#findCategoryById, [id]),
        ),
      ) as _i5.ExerciseCategory);

  @override
  _i6.Equipment findEquipmentById(int? id) => (super.noSuchMethod(
        Invocation.method(#findEquipmentById, [id]),
        returnValue: _FakeEquipment_4(
          this,
          Invocation.method(#findEquipmentById, [id]),
        ),
      ) as _i6.Equipment);

  @override
  _i7.Muscle findMuscleById(int? id) => (super.noSuchMethod(
        Invocation.method(#findMuscleById, [id]),
        returnValue: _FakeMuscle_5(
          this,
          Invocation.method(#findMuscleById, [id]),
        ),
      ) as _i7.Muscle);

  @override
  _i8.Language findLanguageById(int? id) => (super.noSuchMethod(
        Invocation.method(#findLanguageById, [id]),
        returnValue: _FakeLanguage_6(
          this,
          Invocation.method(#findLanguageById, [id]),
        ),
      ) as _i8.Language);

  @override
  _i10.Future<void> fetchAndSetCategoriesFromApi() => (super.noSuchMethod(
        Invocation.method(#fetchAndSetCategoriesFromApi, []),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> fetchAndSetMusclesFromApi() => (super.noSuchMethod(
        Invocation.method(#fetchAndSetMusclesFromApi, []),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> fetchAndSetEquipmentsFromApi() => (super.noSuchMethod(
        Invocation.method(#fetchAndSetEquipmentsFromApi, []),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> fetchAndSetLanguagesFromApi() => (super.noSuchMethod(
        Invocation.method(#fetchAndSetLanguagesFromApi, []),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<_i4.Exercise?> fetchAndSetExercise(int? exerciseId) => (super.noSuchMethod(
        Invocation.method(#fetchAndSetExercise, [exerciseId]),
        returnValue: _i10.Future<_i4.Exercise?>.value(),
      ) as _i10.Future<_i4.Exercise?>);

  @override
  _i10.Future<_i4.Exercise> handleUpdateExerciseFromApi(
    _i3.ExerciseDatabase? database,
    int? exerciseId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(#handleUpdateExerciseFromApi, [
          database,
          exerciseId,
        ]),
        returnValue: _i10.Future<_i4.Exercise>.value(
          _FakeExercise_2(
            this,
            Invocation.method(#handleUpdateExerciseFromApi, [
              database,
              exerciseId,
            ]),
          ),
        ),
      ) as _i10.Future<_i4.Exercise>);

  @override
  _i10.Future<void> initCacheTimesLocalPrefs({dynamic forceInit = false}) => (super.noSuchMethod(
        Invocation.method(#initCacheTimesLocalPrefs, [], {
          #forceInit: forceInit,
        }),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> clearAllCachesAndPrefs() => (super.noSuchMethod(
        Invocation.method(#clearAllCachesAndPrefs, []),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> fetchAndSetInitialData() => (super.noSuchMethod(
        Invocation.method(#fetchAndSetInitialData, []),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> setExercisesFromDatabase(
    _i3.ExerciseDatabase? database, {
    bool? forceDeleteCache = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setExercisesFromDatabase,
          [database],
          {#forceDeleteCache: forceDeleteCache},
        ),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> updateExerciseCache(_i3.ExerciseDatabase? database) => (super.noSuchMethod(
        Invocation.method(#updateExerciseCache, [database]),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> fetchAndSetMuscles(_i3.ExerciseDatabase? database) => (super.noSuchMethod(
        Invocation.method(#fetchAndSetMuscles, [database]),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> fetchAndSetCategories(_i3.ExerciseDatabase? database) => (super.noSuchMethod(
        Invocation.method(#fetchAndSetCategories, [database]),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> fetchAndSetLanguages(_i3.ExerciseDatabase? database) => (super.noSuchMethod(
        Invocation.method(#fetchAndSetLanguages, [database]),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> fetchAndSetEquipments(_i3.ExerciseDatabase? database) => (super.noSuchMethod(
        Invocation.method(#fetchAndSetEquipments, [database]),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<List<_i4.Exercise>> searchExercise(
    String? name, {
    String? languageCode = 'en',
    bool? searchEnglish = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #searchExercise,
          [name],
          {#languageCode: languageCode, #searchEnglish: searchEnglish},
        ),
        returnValue: _i10.Future<List<_i4.Exercise>>.value(
          <_i4.Exercise>[],
        ),
      ) as _i10.Future<List<_i4.Exercise>>);

  @override
  void addListener(_i11.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(#addListener, [listener]),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i11.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(#removeListener, [listener]),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(#dispose, []),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(#notifyListeners, []),
        returnValueForMissingStub: null,
      );
}
