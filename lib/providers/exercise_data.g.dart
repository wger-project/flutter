// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exercises)
const exercisesProvider = ExercisesProvider._();

final class ExercisesProvider
    extends $FunctionalProvider<AsyncValue<List<Exercise>>, List<Exercise>, Stream<List<Exercise>>>
    with $FutureModifier<List<Exercise>>, $StreamProvider<List<Exercise>> {
  const ExercisesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exercisesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exercisesHash();

  @$internal
  @override
  $StreamProviderElement<List<Exercise>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Exercise>> create(Ref ref) {
    return exercises(ref);
  }
}

String _$exercisesHash() => r'3c3bf6b9c2d5d5e9ff2c7fa3776165724f006151';

@ProviderFor(exerciseCategories)
const exerciseCategoriesProvider = ExerciseCategoriesProvider._();

final class ExerciseCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExerciseCategory>>,
          List<ExerciseCategory>,
          Stream<List<ExerciseCategory>>
        >
    with $FutureModifier<List<ExerciseCategory>>, $StreamProvider<List<ExerciseCategory>> {
  const ExerciseCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<ExerciseCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ExerciseCategory>> create(Ref ref) {
    return exerciseCategories(ref);
  }
}

String _$exerciseCategoriesHash() => r'0b43e83e3b68d18ae1319bcc9f553d2fed83e3f2';

@ProviderFor(exerciseEquipment)
const exerciseEquipmentProvider = ExerciseEquipmentProvider._();

final class ExerciseEquipmentProvider
    extends
        $FunctionalProvider<AsyncValue<List<Equipment>>, List<Equipment>, Stream<List<Equipment>>>
    with $FutureModifier<List<Equipment>>, $StreamProvider<List<Equipment>> {
  const ExerciseEquipmentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseEquipmentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseEquipmentHash();

  @$internal
  @override
  $StreamProviderElement<List<Equipment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Equipment>> create(Ref ref) {
    return exerciseEquipment(ref);
  }
}

String _$exerciseEquipmentHash() => r'49e42160c8640d68fde7e9d9849f46a8cf6a10f9';

@ProviderFor(exerciseMuscles)
const exerciseMusclesProvider = ExerciseMusclesProvider._();

final class ExerciseMusclesProvider
    extends $FunctionalProvider<AsyncValue<List<Muscle>>, List<Muscle>, Stream<List<Muscle>>>
    with $FutureModifier<List<Muscle>>, $StreamProvider<List<Muscle>> {
  const ExerciseMusclesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseMusclesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseMusclesHash();

  @$internal
  @override
  $StreamProviderElement<List<Muscle>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Muscle>> create(Ref ref) {
    return exerciseMuscles(ref);
  }
}

String _$exerciseMusclesHash() => r'e283b2b2c170c136663b133764b164cd9cd4b347';
