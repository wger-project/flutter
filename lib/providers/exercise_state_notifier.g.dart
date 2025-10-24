// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
        isAutoDispose: true,
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

String _$exerciseStateNotifierHash() => r'c3070d53059705b03595597f099ded2b7efb5a93';

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
