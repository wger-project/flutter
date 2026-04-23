// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routines.dart';

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

String _$routineWeightUnitHash() => r'816e41348c3b3179084182f1cb13cd6b948ffaaa';

@ProviderFor(routineRepetitionUnit)
final routineRepetitionUnitProvider = RoutineRepetitionUnitProvider._();

final class RoutineRepetitionUnitProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RepetitionUnit>>,
          List<RepetitionUnit>,
          Stream<List<RepetitionUnit>>
        >
    with
        $FutureModifier<List<RepetitionUnit>>,
        $StreamProvider<List<RepetitionUnit>> {
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

String _$routineRepetitionUnitHash() =>
    r'ab09c8c70c4e2f6fc36cc9d1aae901aee165684a';

@ProviderFor(RoutinesRiverpod)
final routinesRiverpodProvider = RoutinesRiverpodProvider._();

final class RoutinesRiverpodProvider
    extends $AsyncNotifierProvider<RoutinesRiverpod, RoutinesState> {
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

String _$routinesRiverpodHash() => r'64ee91510d6b2e939a2584141c20a7b864905e51';

abstract class _$RoutinesRiverpod extends $AsyncNotifier<RoutinesState> {
  FutureOr<RoutinesState> build();
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

@ProviderFor(routinesRepository)
final routinesRepositoryProvider = RoutinesRepositoryProvider._();

final class RoutinesRepositoryProvider
    extends
        $FunctionalProvider<
          RoutinesRepository,
          RoutinesRepository,
          RoutinesRepository
        >
    with $Provider<RoutinesRepository> {
  RoutinesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routinesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routinesRepositoryHash();

  @$internal
  @override
  $ProviderElement<RoutinesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RoutinesRepository create(Ref ref) {
    return routinesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutinesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutinesRepository>(value),
    );
  }
}

String _$routinesRepositoryHash() =>
    r'0cdeb7e33ac45c9a1e4cdf541bf57b565033cc38';
