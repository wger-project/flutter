// Mocks generated by Mockito 5.4.3 from annotations
// in wger/test/workout/workout_set_form_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i20;
import 'dart:ui' as _i21;

import 'package:http/http.dart' as _i10;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i24;
import 'package:wger/database/exercises/exercise_database.dart' as _i3;
import 'package:wger/models/exercises/category.dart' as _i5;
import 'package:wger/models/exercises/equipment.dart' as _i6;
import 'package:wger/models/exercises/exercise.dart' as _i4;
import 'package:wger/models/exercises/language.dart' as _i8;
import 'package:wger/models/exercises/muscle.dart' as _i7;
import 'package:wger/models/exercises/translation.dart' as _i23;
import 'package:wger/models/workouts/day.dart' as _i14;
import 'package:wger/models/workouts/log.dart' as _i18;
import 'package:wger/models/workouts/repetition_unit.dart' as _i12;
import 'package:wger/models/workouts/session.dart' as _i17;
import 'package:wger/models/workouts/set.dart' as _i15;
import 'package:wger/models/workouts/setting.dart' as _i16;
import 'package:wger/models/workouts/weight_unit.dart' as _i11;
import 'package:wger/models/workouts/workout_plan.dart' as _i13;
import 'package:wger/providers/auth.dart' as _i9;
import 'package:wger/providers/base_provider.dart' as _i2;
import 'package:wger/providers/exercises.dart' as _i19;
import 'package:wger/providers/workout_plans.dart' as _i22;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeWgerBaseProvider_0 extends _i1.SmartFake implements _i2.WgerBaseProvider {
  _FakeWgerBaseProvider_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeExerciseDatabase_1 extends _i1.SmartFake implements _i3.ExerciseDatabase {
  _FakeExerciseDatabase_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeExercise_2 extends _i1.SmartFake implements _i4.Exercise {
  _FakeExercise_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeExerciseCategory_3 extends _i1.SmartFake implements _i5.ExerciseCategory {
  _FakeExerciseCategory_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeEquipment_4 extends _i1.SmartFake implements _i6.Equipment {
  _FakeEquipment_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeMuscle_5 extends _i1.SmartFake implements _i7.Muscle {
  _FakeMuscle_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLanguage_6 extends _i1.SmartFake implements _i8.Language {
  _FakeLanguage_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAuthProvider_7 extends _i1.SmartFake implements _i9.AuthProvider {
  _FakeAuthProvider_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeClient_8 extends _i1.SmartFake implements _i10.Client {
  _FakeClient_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUri_9 extends _i1.SmartFake implements Uri {
  _FakeUri_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeResponse_10 extends _i1.SmartFake implements _i10.Response {
  _FakeResponse_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWeightUnit_11 extends _i1.SmartFake implements _i11.WeightUnit {
  _FakeWeightUnit_11(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRepetitionUnit_12 extends _i1.SmartFake implements _i12.RepetitionUnit {
  _FakeRepetitionUnit_12(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWorkoutPlan_13 extends _i1.SmartFake implements _i13.WorkoutPlan {
  _FakeWorkoutPlan_13(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDay_14 extends _i1.SmartFake implements _i14.Day {
  _FakeDay_14(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSet_15 extends _i1.SmartFake implements _i15.Set {
  _FakeSet_15(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSetting_16 extends _i1.SmartFake implements _i16.Setting {
  _FakeSetting_16(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWorkoutSession_17 extends _i1.SmartFake implements _i17.WorkoutSession {
  _FakeWorkoutSession_17(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLog_18 extends _i1.SmartFake implements _i18.Log {
  _FakeLog_18(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ExercisesProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockExercisesProvider extends _i1.Mock implements _i19.ExercisesProvider {
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
        Invocation.setter(
          #database,
          _database,
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i4.Exercise> get exercises => (super.noSuchMethod(
        Invocation.getter(#exercises),
        returnValue: <_i4.Exercise>[],
      ) as List<_i4.Exercise>);

  @override
  set exercises(List<_i4.Exercise>? _exercises) => super.noSuchMethod(
        Invocation.setter(
          #exercises,
          _exercises,
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i4.Exercise> get filteredExercises => (super.noSuchMethod(
        Invocation.getter(#filteredExercises),
        returnValue: <_i4.Exercise>[],
      ) as List<_i4.Exercise>);

  @override
  set filteredExercises(List<_i4.Exercise>? newFilteredExercises) => super.noSuchMethod(
        Invocation.setter(
          #filteredExercises,
          newFilteredExercises,
        ),
        returnValueForMissingStub: null,
      );

  @override
  Map<int, List<_i4.Exercise>> get exerciseBasesByVariation => (super.noSuchMethod(
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
        Invocation.setter(
          #languages,
          languages,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  _i20.Future<void> setFilters(_i19.Filters? newFilters) => (super.noSuchMethod(
        Invocation.method(
          #setFilters,
          [newFilters],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> findByFilters() => (super.noSuchMethod(
        Invocation.method(
          #findByFilters,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  void clear() => super.noSuchMethod(
        Invocation.method(
          #clear,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Exercise findExerciseById(int? id) => (super.noSuchMethod(
        Invocation.method(
          #findExerciseById,
          [id],
        ),
        returnValue: _FakeExercise_2(
          this,
          Invocation.method(
            #findExerciseById,
            [id],
          ),
        ),
      ) as _i4.Exercise);

  @override
  List<_i4.Exercise> findExercisesByVariationId(
    int? id, {
    int? exerciseBaseIdToExclude,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #findExercisesByVariationId,
          [id],
          {#exerciseBaseIdToExclude: exerciseBaseIdToExclude},
        ),
        returnValue: <_i4.Exercise>[],
      ) as List<_i4.Exercise>);

  @override
  _i5.ExerciseCategory findCategoryById(int? id) => (super.noSuchMethod(
        Invocation.method(
          #findCategoryById,
          [id],
        ),
        returnValue: _FakeExerciseCategory_3(
          this,
          Invocation.method(
            #findCategoryById,
            [id],
          ),
        ),
      ) as _i5.ExerciseCategory);

  @override
  _i6.Equipment findEquipmentById(int? id) => (super.noSuchMethod(
        Invocation.method(
          #findEquipmentById,
          [id],
        ),
        returnValue: _FakeEquipment_4(
          this,
          Invocation.method(
            #findEquipmentById,
            [id],
          ),
        ),
      ) as _i6.Equipment);

  @override
  _i7.Muscle findMuscleById(int? id) => (super.noSuchMethod(
        Invocation.method(
          #findMuscleById,
          [id],
        ),
        returnValue: _FakeMuscle_5(
          this,
          Invocation.method(
            #findMuscleById,
            [id],
          ),
        ),
      ) as _i7.Muscle);

  @override
  _i8.Language findLanguageById(int? id) => (super.noSuchMethod(
        Invocation.method(
          #findLanguageById,
          [id],
        ),
        returnValue: _FakeLanguage_6(
          this,
          Invocation.method(
            #findLanguageById,
            [id],
          ),
        ),
      ) as _i8.Language);

  @override
  _i20.Future<void> fetchAndSetCategoriesFromApi() => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetCategoriesFromApi,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> fetchAndSetMusclesFromApi() => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetMusclesFromApi,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> fetchAndSetEquipmentsFromApi() => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetEquipmentsFromApi,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> fetchAndSetLanguagesFromApi() => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetLanguagesFromApi,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<_i4.Exercise> fetchAndSetExercise(int? exerciseId) => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetExercise,
          [exerciseId],
        ),
        returnValue: _i20.Future<_i4.Exercise>.value(_FakeExercise_2(
          this,
          Invocation.method(
            #fetchAndSetExercise,
            [exerciseId],
          ),
        )),
      ) as _i20.Future<_i4.Exercise>);

  @override
  _i20.Future<_i4.Exercise> handleUpdateExerciseFromApi(
    _i3.ExerciseDatabase? database,
    int? exerciseId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #handleUpdateExerciseFromApi,
          [
            database,
            exerciseId,
          ],
        ),
        returnValue: _i20.Future<_i4.Exercise>.value(_FakeExercise_2(
          this,
          Invocation.method(
            #handleUpdateExerciseFromApi,
            [
              database,
              exerciseId,
            ],
          ),
        )),
      ) as _i20.Future<_i4.Exercise>);

  @override
  _i20.Future<void> checkExerciseCacheVersion() => (super.noSuchMethod(
        Invocation.method(
          #checkExerciseCacheVersion,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> initCacheTimesLocalPrefs({dynamic forceInit = false}) => (super.noSuchMethod(
        Invocation.method(
          #initCacheTimesLocalPrefs,
          [],
          {#forceInit: forceInit},
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> clearAllCachesAndPrefs() => (super.noSuchMethod(
        Invocation.method(
          #clearAllCachesAndPrefs,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> fetchAndSetInitialData() => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetInitialData,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> setExercisesFromDatabase(
    _i3.ExerciseDatabase? database, {
    bool? forceDeleteCache = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setExercisesFromDatabase,
          [database],
          {#forceDeleteCache: forceDeleteCache},
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> updateExerciseCache(_i3.ExerciseDatabase? database) => (super.noSuchMethod(
        Invocation.method(
          #updateExerciseCache,
          [database],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> fetchAndSetMuscles(_i3.ExerciseDatabase? database) => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetMuscles,
          [database],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> fetchAndSetCategories(_i3.ExerciseDatabase? database) => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetCategories,
          [database],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> fetchAndSetLanguages(_i3.ExerciseDatabase? database) => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetLanguages,
          [database],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> fetchAndSetEquipments(_i3.ExerciseDatabase? database) => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetEquipments,
          [database],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<List<_i4.Exercise>> searchExercise(
    String? name, {
    String? languageCode = r'en',
    bool? searchEnglish = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #searchExercise,
          [name],
          {
            #languageCode: languageCode,
            #searchEnglish: searchEnglish,
          },
        ),
        returnValue: _i20.Future<List<_i4.Exercise>>.value(<_i4.Exercise>[]),
      ) as _i20.Future<List<_i4.Exercise>>);

  @override
  void addListener(_i21.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i21.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [WgerBaseProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockWgerBaseProvider extends _i1.Mock implements _i2.WgerBaseProvider {
  MockWgerBaseProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i9.AuthProvider get auth => (super.noSuchMethod(
        Invocation.getter(#auth),
        returnValue: _FakeAuthProvider_7(
          this,
          Invocation.getter(#auth),
        ),
      ) as _i9.AuthProvider);

  @override
  set auth(_i9.AuthProvider? _auth) => super.noSuchMethod(
        Invocation.setter(
          #auth,
          _auth,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i10.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_8(
          this,
          Invocation.getter(#client),
        ),
      ) as _i10.Client);

  @override
  set client(_i10.Client? _client) => super.noSuchMethod(
        Invocation.setter(
          #client,
          _client,
        ),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, String> getDefaultHeaders({dynamic includeAuth = false}) => (super.noSuchMethod(
        Invocation.method(
          #getDefaultHeaders,
          [],
          {#includeAuth: includeAuth},
        ),
        returnValue: <String, String>{},
      ) as Map<String, String>);

  @override
  Uri makeUrl(
    String? path, {
    int? id,
    String? objectMethod,
    Map<String, dynamic>? query,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #makeUrl,
          [path],
          {
            #id: id,
            #objectMethod: objectMethod,
            #query: query,
          },
        ),
        returnValue: _FakeUri_9(
          this,
          Invocation.method(
            #makeUrl,
            [path],
            {
              #id: id,
              #objectMethod: objectMethod,
              #query: query,
            },
          ),
        ),
      ) as Uri);

  @override
  _i20.Future<Map<String, dynamic>> fetch(Uri? uri) => (super.noSuchMethod(
        Invocation.method(
          #fetch,
          [uri],
        ),
        returnValue: _i20.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i20.Future<Map<String, dynamic>>);

  @override
  _i20.Future<List<dynamic>> fetchPaginated(Uri? uri) => (super.noSuchMethod(
        Invocation.method(
          #fetchPaginated,
          [uri],
        ),
        returnValue: _i20.Future<List<dynamic>>.value(<dynamic>[]),
      ) as _i20.Future<List<dynamic>>);

  @override
  _i20.Future<Map<String, dynamic>> post(
    Map<String, dynamic>? data,
    Uri? uri,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [
            data,
            uri,
          ],
        ),
        returnValue: _i20.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i20.Future<Map<String, dynamic>>);

  @override
  _i20.Future<Map<String, dynamic>> patch(
    Map<String, dynamic>? data,
    Uri? uri,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #patch,
          [
            data,
            uri,
          ],
        ),
        returnValue: _i20.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i20.Future<Map<String, dynamic>>);

  @override
  _i20.Future<_i10.Response> deleteRequest(
    String? url,
    int? id,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteRequest,
          [
            url,
            id,
          ],
        ),
        returnValue: _i20.Future<_i10.Response>.value(_FakeResponse_10(
          this,
          Invocation.method(
            #deleteRequest,
            [
              url,
              id,
            ],
          ),
        )),
      ) as _i20.Future<_i10.Response>);
}

/// A class which mocks [WorkoutPlansProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockWorkoutPlansProvider extends _i1.Mock implements _i22.WorkoutPlansProvider {
  MockWorkoutPlansProvider() {
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
  List<_i13.WorkoutPlan> get items => (super.noSuchMethod(
        Invocation.getter(#items),
        returnValue: <_i13.WorkoutPlan>[],
      ) as List<_i13.WorkoutPlan>);

  @override
  List<_i11.WeightUnit> get weightUnits => (super.noSuchMethod(
        Invocation.getter(#weightUnits),
        returnValue: <_i11.WeightUnit>[],
      ) as List<_i11.WeightUnit>);

  @override
  _i11.WeightUnit get defaultWeightUnit => (super.noSuchMethod(
        Invocation.getter(#defaultWeightUnit),
        returnValue: _FakeWeightUnit_11(
          this,
          Invocation.getter(#defaultWeightUnit),
        ),
      ) as _i11.WeightUnit);

  @override
  List<_i12.RepetitionUnit> get repetitionUnits => (super.noSuchMethod(
        Invocation.getter(#repetitionUnits),
        returnValue: <_i12.RepetitionUnit>[],
      ) as List<_i12.RepetitionUnit>);

  @override
  _i12.RepetitionUnit get defaultRepetitionUnit => (super.noSuchMethod(
        Invocation.getter(#defaultRepetitionUnit),
        returnValue: _FakeRepetitionUnit_12(
          this,
          Invocation.getter(#defaultRepetitionUnit),
        ),
      ) as _i12.RepetitionUnit);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  void clear() => super.noSuchMethod(
        Invocation.method(
          #clear,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i13.WorkoutPlan> getPlans() => (super.noSuchMethod(
        Invocation.method(
          #getPlans,
          [],
        ),
        returnValue: <_i13.WorkoutPlan>[],
      ) as List<_i13.WorkoutPlan>);

  @override
  _i13.WorkoutPlan findById(int? id) => (super.noSuchMethod(
        Invocation.method(
          #findById,
          [id],
        ),
        returnValue: _FakeWorkoutPlan_13(
          this,
          Invocation.method(
            #findById,
            [id],
          ),
        ),
      ) as _i13.WorkoutPlan);

  @override
  int findIndexById(int? id) => (super.noSuchMethod(
        Invocation.method(
          #findIndexById,
          [id],
        ),
        returnValue: 0,
      ) as int);

  @override
  void setCurrentPlan(int? id) => super.noSuchMethod(
        Invocation.method(
          #setCurrentPlan,
          [id],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void resetCurrentPlan() => super.noSuchMethod(
        Invocation.method(
          #resetCurrentPlan,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i20.Future<void> fetchAndSetAllPlansFull() => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetAllPlansFull,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> fetchAndSetAllPlansSparse() => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetAllPlansSparse,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<_i13.WorkoutPlan> fetchAndSetPlanSparse(int? planId) => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetPlanSparse,
          [planId],
        ),
        returnValue: _i20.Future<_i13.WorkoutPlan>.value(_FakeWorkoutPlan_13(
          this,
          Invocation.method(
            #fetchAndSetPlanSparse,
            [planId],
          ),
        )),
      ) as _i20.Future<_i13.WorkoutPlan>);

  @override
  _i20.Future<_i13.WorkoutPlan> fetchAndSetWorkoutPlanFull(int? workoutId) => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetWorkoutPlanFull,
          [workoutId],
        ),
        returnValue: _i20.Future<_i13.WorkoutPlan>.value(_FakeWorkoutPlan_13(
          this,
          Invocation.method(
            #fetchAndSetWorkoutPlanFull,
            [workoutId],
          ),
        )),
      ) as _i20.Future<_i13.WorkoutPlan>);

  @override
  _i20.Future<_i13.WorkoutPlan> addWorkout(_i13.WorkoutPlan? workout) => (super.noSuchMethod(
        Invocation.method(
          #addWorkout,
          [workout],
        ),
        returnValue: _i20.Future<_i13.WorkoutPlan>.value(_FakeWorkoutPlan_13(
          this,
          Invocation.method(
            #addWorkout,
            [workout],
          ),
        )),
      ) as _i20.Future<_i13.WorkoutPlan>);

  @override
  _i20.Future<void> editWorkout(_i13.WorkoutPlan? workout) => (super.noSuchMethod(
        Invocation.method(
          #editWorkout,
          [workout],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> deleteWorkout(int? id) => (super.noSuchMethod(
        Invocation.method(
          #deleteWorkout,
          [id],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<Map<String, dynamic>> fetchLogData(
    _i13.WorkoutPlan? workout,
    _i4.Exercise? base,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchLogData,
          [
            workout,
            base,
          ],
        ),
        returnValue: _i20.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i20.Future<Map<String, dynamic>>);

  @override
  _i20.Future<void> fetchAndSetRepetitionUnits() => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetRepetitionUnits,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> fetchAndSetWeightUnits() => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetWeightUnits,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> fetchAndSetUnits() => (super.noSuchMethod(
        Invocation.method(
          #fetchAndSetUnits,
          [],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<_i14.Day> addDay(
    _i14.Day? day,
    _i13.WorkoutPlan? workout,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addDay,
          [
            day,
            workout,
          ],
        ),
        returnValue: _i20.Future<_i14.Day>.value(_FakeDay_14(
          this,
          Invocation.method(
            #addDay,
            [
              day,
              workout,
            ],
          ),
        )),
      ) as _i20.Future<_i14.Day>);

  @override
  _i20.Future<void> editDay(_i14.Day? day) => (super.noSuchMethod(
        Invocation.method(
          #editDay,
          [day],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<void> deleteDay(_i14.Day? day) => (super.noSuchMethod(
        Invocation.method(
          #deleteDay,
          [day],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<_i15.Set> addSet(_i15.Set? workoutSet) => (super.noSuchMethod(
        Invocation.method(
          #addSet,
          [workoutSet],
        ),
        returnValue: _i20.Future<_i15.Set>.value(_FakeSet_15(
          this,
          Invocation.method(
            #addSet,
            [workoutSet],
          ),
        )),
      ) as _i20.Future<_i15.Set>);

  @override
  _i20.Future<void> editSet(_i15.Set? workoutSet) => (super.noSuchMethod(
        Invocation.method(
          #editSet,
          [workoutSet],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<List<_i15.Set>> reorderSets(
    List<_i15.Set>? sets,
    int? startIndex,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #reorderSets,
          [
            sets,
            startIndex,
          ],
        ),
        returnValue: _i20.Future<List<_i15.Set>>.value(<_i15.Set>[]),
      ) as _i20.Future<List<_i15.Set>>);

  @override
  _i20.Future<void> fetchComputedSettings(_i15.Set? workoutSet) => (super.noSuchMethod(
        Invocation.method(
          #fetchComputedSettings,
          [workoutSet],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<String> fetchSmartText(
    _i15.Set? workoutSet,
    _i23.Translation? exercise,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchSmartText,
          [
            workoutSet,
            exercise,
          ],
        ),
        returnValue: _i20.Future<String>.value(_i24.dummyValue<String>(
          this,
          Invocation.method(
            #fetchSmartText,
            [
              workoutSet,
              exercise,
            ],
          ),
        )),
      ) as _i20.Future<String>);

  @override
  _i20.Future<void> deleteSet(_i15.Set? workoutSet) => (super.noSuchMethod(
        Invocation.method(
          #deleteSet,
          [workoutSet],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  _i20.Future<_i16.Setting> addSetting(_i16.Setting? workoutSetting) => (super.noSuchMethod(
        Invocation.method(
          #addSetting,
          [workoutSetting],
        ),
        returnValue: _i20.Future<_i16.Setting>.value(_FakeSetting_16(
          this,
          Invocation.method(
            #addSetting,
            [workoutSetting],
          ),
        )),
      ) as _i20.Future<_i16.Setting>);

  @override
  _i20.Future<dynamic> fetchSessionData() => (super.noSuchMethod(
        Invocation.method(
          #fetchSessionData,
          [],
        ),
        returnValue: _i20.Future<dynamic>.value(),
      ) as _i20.Future<dynamic>);

  @override
  _i20.Future<_i17.WorkoutSession> addSession(_i17.WorkoutSession? session) => (super.noSuchMethod(
        Invocation.method(
          #addSession,
          [session],
        ),
        returnValue: _i20.Future<_i17.WorkoutSession>.value(_FakeWorkoutSession_17(
          this,
          Invocation.method(
            #addSession,
            [session],
          ),
        )),
      ) as _i20.Future<_i17.WorkoutSession>);

  @override
  _i20.Future<_i18.Log> addLog(_i18.Log? log) => (super.noSuchMethod(
        Invocation.method(
          #addLog,
          [log],
        ),
        returnValue: _i20.Future<_i18.Log>.value(_FakeLog_18(
          this,
          Invocation.method(
            #addLog,
            [log],
          ),
        )),
      ) as _i20.Future<_i18.Log>);

  @override
  _i20.Future<void> deleteLog(_i18.Log? log) => (super.noSuchMethod(
        Invocation.method(
          #deleteLog,
          [log],
        ),
        returnValue: _i20.Future<void>.value(),
        returnValueForMissingStub: _i20.Future<void>.value(),
      ) as _i20.Future<void>);

  @override
  void addListener(_i21.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i21.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
