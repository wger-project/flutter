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
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseNotifierHash();

  @$internal
  @override
  ExerciseNotifier create() => ExerciseNotifier();
}

String _$exerciseNotifierHash() => r'4f6613f81e292dd3c74f9eebbbb20482b8da1e42';

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
