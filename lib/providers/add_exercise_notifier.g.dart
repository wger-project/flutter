// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_exercise_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddExerciseNotifier)
final addExerciseProvider = AddExerciseNotifierProvider._();

final class AddExerciseNotifierProvider
    extends $NotifierProvider<AddExerciseNotifier, AddExerciseState> {
  AddExerciseNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addExerciseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addExerciseNotifierHash();

  @$internal
  @override
  AddExerciseNotifier create() => AddExerciseNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddExerciseState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddExerciseState>(value),
    );
  }
}

String _$addExerciseNotifierHash() => r'26f3eaffc36b6670d8e4069ef5813bfc71b9491e';

abstract class _$AddExerciseNotifier extends $Notifier<AddExerciseState> {
  AddExerciseState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AddExerciseState, AddExerciseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddExerciseState, AddExerciseState>,
              AddExerciseState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
