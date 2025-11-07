// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routines.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(routineWeightUnit)
const routineWeightUnitProvider = RoutineWeightUnitProvider._();

final class RoutineWeightUnitProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeightUnit>>,
          List<WeightUnit>,
          Stream<List<WeightUnit>>
        >
    with $FutureModifier<List<WeightUnit>>, $StreamProvider<List<WeightUnit>> {
  const RoutineWeightUnitProvider._()
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
const routineRepetitionUnitProvider = RoutineRepetitionUnitProvider._();

final class RoutineRepetitionUnitProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RepetitionUnit>>,
          List<RepetitionUnit>,
          Stream<List<RepetitionUnit>>
        >
    with $FutureModifier<List<RepetitionUnit>>, $StreamProvider<List<RepetitionUnit>> {
  const RoutineRepetitionUnitProvider._()
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

@ProviderFor(routinesChangeNotifier)
const routinesChangeProvider = RoutinesChangeNotifierProvider._();

final class RoutinesChangeNotifierProvider
    extends $FunctionalProvider<RoutinesProvider, RoutinesProvider, RoutinesProvider>
    with $Provider<RoutinesProvider> {
  const RoutinesChangeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routinesChangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routinesChangeNotifierHash();

  @$internal
  @override
  $ProviderElement<RoutinesProvider> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RoutinesProvider create(Ref ref) {
    return routinesChangeNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutinesProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutinesProvider>(value),
    );
  }
}

String _$routinesChangeNotifierHash() => r'95f7de1ed7184387ffbe4f8ba6e697a311ea02e1';
