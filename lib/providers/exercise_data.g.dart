// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExerciseNotifier)
const exerciseProvider = ExerciseNotifierProvider._();

final class ExerciseNotifierProvider
    extends $StreamNotifierProvider<ExerciseNotifier, List<Exercise>> {
  const ExerciseNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseNotifierHash();

  @$internal
  @override
  ExerciseNotifier create() => ExerciseNotifier();
}

String _$exerciseNotifierHash() => r'897551df3c53c72427a050c9559647aa9f8b59dd';

abstract class _$ExerciseNotifier extends $StreamNotifier<List<Exercise>> {
  Stream<List<Exercise>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Exercise>>, List<Exercise>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Exercise>>, List<Exercise>>,
              AsyncValue<List<Exercise>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ExerciseCategoryNotifier)
const exerciseCategoryProvider = ExerciseCategoryNotifierProvider._();

final class ExerciseCategoryNotifierProvider
    extends $StreamNotifierProvider<ExerciseCategoryNotifier, List<ExerciseCategory>> {
  const ExerciseCategoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseCategoryNotifierHash();

  @$internal
  @override
  ExerciseCategoryNotifier create() => ExerciseCategoryNotifier();
}

String _$exerciseCategoryNotifierHash() => r'476b5cb3f50ac52ce3eda06dac6f43783c48ec31';

abstract class _$ExerciseCategoryNotifier extends $StreamNotifier<List<ExerciseCategory>> {
  Stream<List<ExerciseCategory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<ExerciseCategory>>, List<ExerciseCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ExerciseCategory>>, List<ExerciseCategory>>,
              AsyncValue<List<ExerciseCategory>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ExerciseEquipmentNotifier)
const exerciseEquipmentProvider = ExerciseEquipmentNotifierProvider._();

final class ExerciseEquipmentNotifierProvider
    extends $StreamNotifierProvider<ExerciseEquipmentNotifier, List<Equipment>> {
  const ExerciseEquipmentNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$exerciseEquipmentNotifierHash();

  @$internal
  @override
  ExerciseEquipmentNotifier create() => ExerciseEquipmentNotifier();
}

String _$exerciseEquipmentNotifierHash() => r'581494c6fd4f58e210ea1962fa48bda613c5827f';

abstract class _$ExerciseEquipmentNotifier extends $StreamNotifier<List<Equipment>> {
  Stream<List<Equipment>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Equipment>>, List<Equipment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Equipment>>, List<Equipment>>,
              AsyncValue<List<Equipment>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ExerciseMuscleNotifier)
const exerciseMuscleProvider = ExerciseMuscleNotifierProvider._();

final class ExerciseMuscleNotifierProvider
    extends $StreamNotifierProvider<ExerciseMuscleNotifier, List<Muscle>> {
  const ExerciseMuscleNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseMuscleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseMuscleNotifierHash();

  @$internal
  @override
  ExerciseMuscleNotifier create() => ExerciseMuscleNotifier();
}

String _$exerciseMuscleNotifierHash() => r'6be0b7400776f1593194fb43667acbeee8e3a4a8';

abstract class _$ExerciseMuscleNotifier extends $StreamNotifier<List<Muscle>> {
  Stream<List<Muscle>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Muscle>>, List<Muscle>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Muscle>>, List<Muscle>>,
              AsyncValue<List<Muscle>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
