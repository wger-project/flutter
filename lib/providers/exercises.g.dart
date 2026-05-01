// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercises.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Exercises)
final exercisesProvider = ExercisesProvider._();

final class ExercisesProvider extends $StreamNotifierProvider<Exercises, ExerciseState> {
  ExercisesProvider._()
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
  Exercises create() => Exercises();
}

String _$exercisesHash() => r'c54e9bbcae562bbed8de4071f4cdb6392813bb7c';

abstract class _$Exercises extends $StreamNotifier<ExerciseState> {
  Stream<ExerciseState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ExerciseState>, ExerciseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExerciseState>, ExerciseState>,
              AsyncValue<ExerciseState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(exerciseCategories)
final exerciseCategoriesProvider = ExerciseCategoriesProvider._();

final class ExerciseCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExerciseCategory>>,
          List<ExerciseCategory>,
          Stream<List<ExerciseCategory>>
        >
    with $FutureModifier<List<ExerciseCategory>>, $StreamProvider<List<ExerciseCategory>> {
  ExerciseCategoriesProvider._()
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
final exerciseEquipmentProvider = ExerciseEquipmentProvider._();

final class ExerciseEquipmentProvider
    extends
        $FunctionalProvider<AsyncValue<List<Equipment>>, List<Equipment>, Stream<List<Equipment>>>
    with $FutureModifier<List<Equipment>>, $StreamProvider<List<Equipment>> {
  ExerciseEquipmentProvider._()
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
final exerciseMusclesProvider = ExerciseMusclesProvider._();

final class ExerciseMusclesProvider
    extends $FunctionalProvider<AsyncValue<List<Muscle>>, List<Muscle>, Stream<List<Muscle>>>
    with $FutureModifier<List<Muscle>>, $StreamProvider<List<Muscle>> {
  ExerciseMusclesProvider._()
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
