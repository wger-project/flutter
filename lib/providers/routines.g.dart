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
        isAutoDispose: true,
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

String _$routineWeightUnitHash() => r'4e2e7b9903338756f5196eaa1081696a59869e86';

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
        isAutoDispose: true,
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

String _$routineRepetitionUnitHash() => r'7754a0197c3fed27feea2c6d33d5e5a5e1deab45';

@ProviderFor(RoutinesRiverpod)
final routinesRiverpodProvider = RoutinesRiverpodProvider._();

final class RoutinesRiverpodProvider extends $NotifierProvider<RoutinesRiverpod, RoutinesState> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutinesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutinesState>(value),
    );
  }
}

String _$routinesRiverpodHash() => r'7a097555c9718249a21328ac16234ef26e23c453';

abstract class _$RoutinesRiverpod extends $Notifier<RoutinesState> {
  RoutinesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RoutinesState, RoutinesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RoutinesState, RoutinesState>,
              RoutinesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(routinesRepository)
final routinesRepositoryProvider = RoutinesRepositoryProvider._();

final class RoutinesRepositoryProvider
    extends $FunctionalProvider<RoutinesRepository, RoutinesRepository, RoutinesRepository>
    with $Provider<RoutinesRepository> {
  RoutinesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routinesRepositoryProvider',
        isAutoDispose: true,
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

String _$routinesRepositoryHash() => r'866fede3b610fa71c3204c57ad004465f3e5e3fc';
