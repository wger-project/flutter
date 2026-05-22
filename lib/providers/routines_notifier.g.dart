// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routines_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(routineWeightUnit)
final routineWeightUnitProvider = RoutineWeightUnitProvider._();

final class RoutineWeightUnitProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeightUnit>>,
          List<WeightUnit>,
          Stream<List<WeightUnit>>
        >
    with $FutureModifier<List<WeightUnit>>, $StreamProvider<List<WeightUnit>> {
  RoutineWeightUnitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routineWeightUnitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routineWeightUnitHash();

  @$internal
  @override
  $StreamProviderElement<List<WeightUnit>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WeightUnit>> create(Ref ref) {
    return routineWeightUnit(ref);
  }
}

String _$routineWeightUnitHash() => r'3f40e8a6ec8dea64ecafa4715b1f64408e0d9db4';

@ProviderFor(routineRepetitionUnit)
final routineRepetitionUnitProvider = RoutineRepetitionUnitProvider._();

final class RoutineRepetitionUnitProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RepetitionUnit>>,
          List<RepetitionUnit>,
          Stream<List<RepetitionUnit>>
        >
    with $FutureModifier<List<RepetitionUnit>>, $StreamProvider<List<RepetitionUnit>> {
  RoutineRepetitionUnitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routineRepetitionUnitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routineRepetitionUnitHash();

  @$internal
  @override
  $StreamProviderElement<List<RepetitionUnit>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RepetitionUnit>> create(Ref ref) {
    return routineRepetitionUnit(ref);
  }
}

String _$routineRepetitionUnitHash() => r'de9d2c5b6e2f4df761165d6899353b3fb2cee8c6';

@ProviderFor(RoutinesRiverpod)
final routinesRiverpodProvider = RoutinesRiverpodProvider._();

final class RoutinesRiverpodProvider
    extends $StreamNotifierProvider<RoutinesRiverpod, RoutinesState> {
  RoutinesRiverpodProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routinesRiverpodProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routinesRiverpodHash();

  @$internal
  @override
  RoutinesRiverpod create() => RoutinesRiverpod();
}

String _$routinesRiverpodHash() => r'eae2b0dea699fd964bc58b218121beaca2c4cb46';

abstract class _$RoutinesRiverpod extends $StreamNotifier<RoutinesState> {
  Stream<RoutinesState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RoutinesState>, RoutinesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RoutinesState>, RoutinesState>,
              AsyncValue<RoutinesState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
