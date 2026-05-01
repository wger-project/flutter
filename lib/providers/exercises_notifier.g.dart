// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercises_notifier.dart';

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

String _$exerciseCategoriesHash() => r'38e7b439ecc9682891373930813f2d3b7dc4f794';

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

String _$exerciseEquipmentHash() => r'cceb7e47e1292a1f33f1f6378f8efaf109fa7bb3';

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

String _$exerciseMusclesHash() => r'acb72b84288ff565183581fef1b718a516e7efd4';

@ProviderFor(languages)
final languagesProvider = LanguagesProvider._();

final class LanguagesProvider
    extends $FunctionalProvider<AsyncValue<List<Language>>, List<Language>, Stream<List<Language>>>
    with $FutureModifier<List<Language>>, $StreamProvider<List<Language>> {
  LanguagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languagesHash();

  @$internal
  @override
  $StreamProviderElement<List<Language>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Language>> create(Ref ref) {
    return languages(ref);
  }
}

String _$languagesHash() => r'70c3a3cad32a953443fc0e8a9e5bb402bf2f5a6d';
