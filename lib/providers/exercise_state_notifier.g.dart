// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exerciseStateReady)
const exerciseStateReadyProvider = ExerciseStateReadyProvider._();

final class ExerciseStateReadyProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  const ExerciseStateReadyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseStateReadyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseStateReadyHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return exerciseStateReady(ref);
  }
}

String _$exerciseStateReadyHash() => r'4ba35bfced32dc984ea363e2a103eb8660bb4487';

@ProviderFor(ExerciseStateNotifier)
const exerciseStateProvider = ExerciseStateNotifierProvider._();

final class ExerciseStateNotifierProvider
    extends $NotifierProvider<ExerciseStateNotifier, ExerciseState> {
  const ExerciseStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseStateNotifierHash();

  @$internal
  @override
  ExerciseStateNotifier create() => ExerciseStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExerciseState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExerciseState>(value),
    );
  }
}

String _$exerciseStateNotifierHash() => r'95653998a71d77da4e390260738a95767bb1aae1';

abstract class _$ExerciseStateNotifier extends $Notifier<ExerciseState> {
  ExerciseState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ExerciseState, ExerciseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExerciseState, ExerciseState>,
              ExerciseState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
